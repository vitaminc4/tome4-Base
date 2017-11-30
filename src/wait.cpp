/*
    TE4 - T-Engine 4
    Copyright (C) 2009 - 2017 Nicolas Casalini

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Nicolas Casalini "DarkGod"
    darkgod@te4.org
*/

extern "C" {
#include "display.h"
#include "lua.h"
#include "types.h"
#include "lauxlib.h"
#include "lualib.h"
#include "core_lua.h"
#include "main.h"
#include "lua_externs.h"
}

#include "renderer-moderngl/VBO.hpp"

extern SDL_Window *window;
extern SDL_Surface *screen;

static int wait_hooked = 0;
static bool manual_ticks_enabled = FALSE;
static int waiting = 0;
static int waited_count = 0;
static int waited_count_max = 0;
static long waited_ticks = 0;
static int bkg_w, bkg_h;
static GLuint bkg_t = 0;
static int wait_draw_ref = LUA_NOREF;
static VBO *wait_vbo = NULL;

static int draw_last_frame(lua_State *L)
{
	if (!wait_vbo) return 0;

	wait_vbo->toScreen(0, 0, 0, 1, 1);
	return 0;
}

extern int requested_fps;
extern "C" void on_redraw();
static void hook_wait_display(lua_State *L, lua_Debug *ar)
{
	if (!manual_ticks_enabled) waited_count++;
	SDL_PumpEvents();

	static int last_tick = 0;
	int now = SDL_GetTicks();
	if (now - last_tick < (3000 / (requested_fps ? requested_fps : NORMALIZED_FPS))) return;
	last_tick = now;
	on_redraw();
}

extern long draw_tick_skip;
static int enable(lua_State *L)
{
	waiting++;

	// Grab currently displayed stuff
	if (waiting == 1)
	{
		waited_count = 0;
		waited_count_max = 0;
		manual_ticks_enabled = FALSE;
		waited_ticks = SDL_GetTicks();

		SDL_GL_SwapWindow(window);

		float w = screen->w;
		float h = screen->h;

		bkg_w = w;
		bkg_h = h;

		glGenTextures(1, &bkg_t);
		tglBindTexture(GL_TEXTURE_2D, bkg_t);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, bkg_w, bkg_h, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, w, h);
		printf("Make wait background texture %d : %dx%d\n", bkg_t, w, h);

		int count = 300;
		if (lua_isnumber(L, 1)) count = lua_tonumber(L, 1);
		if (!lua_gethookmask(L))
		{
			lua_sethook(L, hook_wait_display, LUA_MASKCOUNT, count);
			wait_hooked = count;
		}

		if (lua_isfunction(L, 2))
		{
			lua_pushvalue(L, 2);
			if (lua_pcall(L, 0, 1, 0)) {
				printf("Waiter error: %s\n", lua_tostring(L, -1));
			}
			wait_draw_ref = luaL_ref(L, LUA_REGISTRYINDEX);
		}

		wait_vbo = new VBO(VBOMode::STATIC);
		wait_vbo->setTexture(bkg_t);
		wait_vbo->addQuad(
			0, 0, 0, 1,
			w / screen_zoom, 0, 1, 1,
			w / screen_zoom, h / screen_zoom, 1, 0,
			0, h / screen_zoom, 0, 0,
			1, 1, 1, 1
		);

		on_redraw();
	}

	lua_pushboolean(L, waiting == 1);
	lua_pushnumber(L, waiting);
	return 2;
}

static int disable(lua_State *L)
{
	waiting--;
	if (waiting < 0) waiting = 0;
	if (!waiting)
	{
		if (bkg_t)
		{
			glDeleteTextures(1, &bkg_t);
			bkg_t = 0;
		}
		if (wait_vbo) {
			delete wait_vbo;
			wait_vbo = NULL;
		}
		if (wait_hooked) lua_sethook(L, NULL, 0, 0);
		refcleaner(wait_draw_ref); wait_draw_ref = LUA_NOREF;
		waited_ticks = SDL_GetTicks() - waited_ticks;
		printf("Wait finished, counted %d, %ld ticks\n", waited_count, waited_ticks);

		waited_count = 0;
		waited_count_max = 0;
	}
	lua_pushboolean(L, waiting > 0);
	lua_pushnumber(L, waiting);
	return 2;
}

static int enable_manual_tick(lua_State *L)
{
	if (!waiting) return 0;
	manual_ticks_enabled = lua_toboolean(L, 1);
	if (!manual_ticks_enabled) lua_sethook(L, hook_wait_display, LUA_MASKCOUNT, wait_hooked);
	else lua_sethook(L, NULL, 0, 0);
	return 0;
}

static int manual_tick(lua_State *L)
{
	if (!waiting) return 0;
	if (manual_ticks_enabled)
	{
		waited_count += lua_tonumber(L, 1);
		hook_wait_display(L, NULL);
	}
	return 0;
}

static int add_max_ticks(lua_State *L)
{
	if (!waiting) return 0;
	waited_count_max += lua_tonumber(L, 1);
	return 0;
}

static int get_ticks(lua_State *L)
{
	lua_pushnumber(L, waited_count);
	lua_pushnumber(L, waited_count_max);
	return 2;
}

static const struct luaL_Reg mainlib[] =
{
	{"drawLastFrame", draw_last_frame},
	{"enable", enable},
	{"disable", disable},
	{"enableManualTick", enable_manual_tick},
	{"manualTick", manual_tick},
	{"addMaxTicks", add_max_ticks},
	{"getTicks", get_ticks},
	{NULL, NULL},
};

int luaopen_wait(lua_State *L)
{
	luaL_openlib(L, "core.wait", mainlib, 0);
	lua_pop(L, 1);
	return 1;
}

bool draw_waiting(lua_State *L)
{
	if (!waiting) return FALSE;

	if (wait_draw_ref != LUA_NOREF)
	{
		lua_rawgeti(L, LUA_REGISTRYINDEX, wait_draw_ref);
		if (lua_pcall(L, 0, 0, 0)) {
			printf("Waiter error: %s\n", lua_tostring(L, -1));
		}
	}
	else draw_last_frame(L);

	return TRUE;
}

bool is_waiting()
{
	if (!waiting) return FALSE;
	return TRUE;
}
