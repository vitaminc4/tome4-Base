-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newBirthDescriptor{
	type = "world",
	name = "Tutorial",
	desc =
	{
		"The tutorial will explain the basics of the game to get you started.",
	},
--	on_select = function(what)
--		setAuto("subclass", false)
--		setAuto("subrace", false)
--	end,
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "forbid",
			["Tutorial Human"] = "allow",
		},
		subrace =
		{
			__ALL__ = "forbid",
			["Tutorial Human"] = "allow",
		},
		class =
		{
			__ALL__ = "forbid",
			["Tutorial Adventurer"] = "allow",
		},
		subclass =
		{
			__ALL__ = "forbid",
			["Tutorial Adventurer"] = "allow",
		},
	},
}


-- Player worlds/campaigns
newBirthDescriptor{
	type = "world",
	name = "Maj'Eyal",
	display_name = "Maj'Eyal: The Age of Ascendancy",
	desc =
	{
		"The people of Maj'Eyal: Humans, Halflings, Elves and Dwarves.",
		"The known world has been at relative peace for over one hundred year and people are prospering again.",
		"You are an adventurer, setting out to find lost treasure and glory.",
		"But what lurks in the shadow of the world?",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
			Elf = "allow",
			Dwarf = "allow",
			Halfling = "allow",
			Undead = function() return profile.mod.allow_build.undead and "allow" or "disallow" end,
		},

		class =
		{
			__ALL__ = "allow",
			Mage = "allow",
			Divine = function() return profile.mod.allow_build.divine and "allow" or "disallow" end,
			Wilder = function() return (
				profile.mod.allow_build.wilder_summoner or
				profile.mod.allow_build.wilder_wyrmic
				) and "allow" or "disallow"
			end,
			Corrupter = function() return profile.mod.allow_build.corrupter and "allow" or "disallow" end,
			Afflicted = function() return profile.mod.allow_build.afflicted and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Orcs",
	display_name = "Orcs: The Rise to Power",
	desc =
	{
		"Baston!",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Orc = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Spydre",
	display_name = "Spydrë: Legacy of Ungoliant",
	desc =
	{
		"Spydrë is home to the essence of spiders. The mighty Ungoliant of Arda actually originating from this world.",
		"It is home to uncounted numbers of spider races, all fighting for supremacy of all the lands.",
		"Some humanoids also live there, but they are usually the prey, not the hunter.",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Ents",
	display_name = "Ents: The March of the Entwifes",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Trolls",
	display_name = "Trolls: Terror of the Woods",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Nagas",
	display_name = "Nagas: Guardians of the Tide",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Faeros",
	display_name = "Urthalath: Treason or the High Guards",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Undeads",
	display_name = "Broken Oath: The Curse of Undeath",
	desc =
	{
		"",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "disallow",
			Human = "allow",
--			Spider = function() return profile.mod.allow_build.spider and "allow" or "disallow" end,
		},
	},
}
