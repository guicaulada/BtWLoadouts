--[[
    Instance handling code

    Dungeon Difficulty ids:
        1:  Normal
        2:  Heroic
        23: Mythic
        8:  Mythic Keystone

    Raid Difficulty ids:
        17: Flex LFR
        14: Flex Normal
        15: Flex Heroic
        16: Mythic
]]

local _,Internal = ...
local L = Internal.L or {}

local format = string.format
local select = select
local pairs = pairs
local GetAffixInfo = C_ChallengeMode.GetAffixInfo
local GetInstanceInfo = GetInstanceInfo
local GetAreaInfo = C_Map.GetAreaInfo

local dungeonDifficultiesAll = {1,2,23,8};
local raidDifficultiesAll = {17,14,15,16};
-- local raidDifficultiesAll = {3,4,5,6,79,14,15,16,17,33};
local instanceDifficulties = {
	[1763] = dungeonDifficultiesAll, -- Atal'Dazar
	[1841] = dungeonDifficultiesAll, -- The Underrot
	[1877] = dungeonDifficultiesAll, -- Temple of Sethraliss
	[1594] = dungeonDifficultiesAll, -- The MOTHERLODE!!
	[1762] = dungeonDifficultiesAll, -- Kings' Rest
	[1754] = dungeonDifficultiesAll, -- Freehold
	[1864] = dungeonDifficultiesAll, -- Shrine of the Storm
	[1771] = dungeonDifficultiesAll, -- Tol Dagor
	[1862] = dungeonDifficultiesAll, -- Waycrest Manor
	[1822] = dungeonDifficultiesAll, -- Siege of Boralus
	[2097] = {23},					 -- Operation: Mechagon

	[1861] = raidDifficultiesAll,	 -- Uldir
	[2070] = raidDifficultiesAll,	 -- Battle of Dazar'alor
	[2096] = raidDifficultiesAll,	 -- Crucible of Storms
	[2164] = raidDifficultiesAll,	 -- The Eternal Palace
};
Internal.dungeonDifficultiesAll = dungeonDifficultiesAll;
Internal.raidDifficultiesAll = raidDifficultiesAll;
local dungeonInfo = {
	{
		name = L["Classic"],
		instances = {
		},
	},
	{
		name = L["TBC"],
		instances = {
		},
	},
	{
		name = L["Wrath"],
		instances = {
		},
	},
	{
		name = L["Cata"],
		instances = {
		},
	},
	{
		name = L["Panda"],
		instances = {
		},
	},
	{
		name = L["WoD"],
		instances = {
		},
	},
	{
		name = L["Legion"],
		instances = {
		},
	},
	{
		name = L["Battle For Azeroth"],
		instances = {
			1763,
			1841,
			1877,
			1594,
			1762,
			1754,
			1864,
			1771,
			1862,
			1822,
			2097,
		},
	}
};
local raidInfo = {
	{
		name = L["Classic"],
		instances = {
		},
	},
	{
		name = L["TBC"],
		instances = {
		},
	},
	{
		name = L["Wrath"],
		instances = {
		},
	},
	{
		name = L["Cata"],
		instances = {
		},
	},
	{
		name = L["Panda"],
		instances = {
		},
	},
	{
		name = L["WoD"],
		instances = {
		},
	},
	{
		name = L["Legion"],
		instances = {
		},
	},
	{
		name = L["Battle For Azeroth"],
		instances = {
			1861, -- Uldir
			2070, -- Battle for Dazar'alor
			2096, -- Crucible of Storms
			2164, -- Eternal Palace
		},
	}
};
-- List of bosses within an instance
local instanceBosses = {
	[1763] = { -- Atal'Dazar
		2082, -- Priestess Alun'za
		2036, -- Vol'kaal
		2083, -- Rezan
		2030, -- Yazma
	},
	[1754] = { -- Freehold
		2102, -- Skycap'n Kragg
		2093, -- Council o' Captains
		2094, -- Ring of Booty
		2095, -- Harlan Sweete
	},
	[1762] = { -- Kings' Rest
		2165, -- The Golden Serpent
		2171, -- Mchimba the Embalmer
		2170, -- The Council of Tribes
		2172, -- Dazar, The First King
	},
	[1864] = { -- Shrine of the Storm
		2153, -- Aqu'sirr
		2154, -- Tidesage Council
		2155, -- Lord Stormsong
		2156, -- Vol'zith the Whisperer
	},
	[1822] = { -- Siege of Boralus
		2132, -- Chopper Redhook
		2133, -- Sergeant Bainbridge
		2173, -- Dread Captain Lockwood
		2134, -- Hadal Darkfathom
		2140, -- Viq'Goth
	},
	[1877] = { -- Temple of Sethraliss
		2142, -- Adderis and Aspix
		2143, -- Merektha
		2144, -- Galvazzt
		2145, -- Avatar of Sethraliss
	},
	[1594] = { -- The MOTHERLODE!!
		2109, -- Coin-Operated Crowd Pummeler
		2114, -- Azerokk
		2115, -- Rixxa Fluxflame
		2116, -- Mogul Razdunk
	},
	[1841] = { -- The Underrot
		2157, -- Elder Leaxa
		2131, -- Cragmaw the Infested
		2130, -- Sporecaller Zancha
		2158, -- Unbound Abomination
	},
	[1771] = { -- Tol Dagor
		2097, -- The Sand Queen
		2098, -- Jes Howlis
		2099, -- Knight Captain Valyri
		2096, -- Overseer Korgus
	},
	[1862] = { -- Waycrest Manor
		2125, -- Heartsbane Triad
		2126, -- Soulbound Goliath
		2127, -- Raal the Gluttonous
		2128, -- Lord and Lady Waycrest
		2129, -- Gorak Tul
	},
	[2097] = { -- Operation: Mechagon
		2357, -- King Gobbamak
		2358, -- Gunker
		2360, -- Trixie & Naeno
		2355, -- HK-8 Aerial Oppression Unit
		2336, -- Tussle Tonks
		2339, -- K.U.-J.0.
		2348, -- Machinist's Garden
		2331, -- King Mechagon
	},

	[1861] = { -- Uldir
		2168, -- Taloc
		2167, -- MOTHER
		2146, -- Fetid Devourer
		2169, -- Zek'voz, Herald of N'zoth
		2166, -- Vectis
		2195, -- Zul, Reborn
		2194, -- Mythrax the Unraveler
		2147, -- G'huun
	},
	[2070] = { -- Battle of Dazar'alor
		2333, -- Champion of the Light
		2323, -- Jadefire Masters
		2325, -- Grong, the Jungle Lord
		2342, -- Opulence
		2330, -- Conclave of the Chosen
		2335, -- King Rastakhan
		2334, -- High Tinker Mekkatorque
		2337, -- Stormwall Blockade
		2343, -- Lady Jaina Proudmoore
	},
	[2096] = { -- Crucible of Storms
		2328, -- The Restless Cabal
		2332, -- Uu'nat, Harbinger of the Void
	},
	[2164] = { -- The Eternal Palace
		2352, -- Abyssal Commander Sivara
		2347, -- Blackwater Behemoth
		2353, -- Radiance of Azshara
		2354, -- Lady Ashvane
		2351, -- Orgozoa
		2359, -- The Queen's Court
		2349, -- Za'qul, Harbinger of Ny'alotha
		2361, -- Queen Azshara
	},
};
-- A map of npc ids to boss ids, this might not be the bosses npc id,
-- just something that signifies the boss
local npcIDToBossID = {
	-- Shrine of the Storm
	[134056] = 2153, -- Aqu'sirr
	[134063] = 2154, -- Tidesage Council
	[134058] = 2154, -- Tidesage Council
	[134060] = 2155, -- Lord Stormsong
	[134069] = 2156, -- Vol'zith the Whisperer

	-- The Eternal Palace
	[155899] = 2353, -- Radiance of Azshara
	[155900] = 2353, -- Radiance of Azshara
	[155859] = 2353, -- Radiance of Azshara
	[152364] = 2353, -- Radiance of Azshara

	[152236] = 2354, -- Lady Ashvane
};
-- Although area ids are unique we map them with instance ids so we can translate
-- area names by instance. We translate them because we cant get the area id where
-- the player is so we map area names to area ids and compare with the minimap text
local InstanceAreaIDToBossID = {
	[1822] = {
		[9984] = 2132,
	},
	[2097] = { -- Operation: Mechagon
		[11389] = 2358, -- Gunker
		[11388] = 2357, -- King Gobbamak
		[11387] = 2360, -- Trixie & Naeno
		[11390] = 2355, -- HK-8 Aerial Oppression Unit
		[10497] = 2336, -- Tussle Tonks
		-- [] = 2339, -- K.U.-J.0.
		-- [] = 2348, -- Machinist's Garden
		-- [] = 2331, -- King Mechagon
	},
	[1754] = { -- Freehold
		[9640] = 2102, -- Skycap'n Kragg
		[10039] = 2093, -- Council o' Captains
		[9639] = 2094, -- Ring of Booty
		[10040] = 2095, -- Harlan Sweete
	},
};
-- This is for bosses that have their own unique world map
local uiMapIDToBossID = {
	-- Operation: Mechagon
	[1491] = 2336, -- Tussle Tonks
	[1494] = 2339, -- K.U.-J.0.

	-- The Eternal Palace
	[1512] = 2352, -- Abyssal Commander Sivara
	[1514] = 2347, -- Blackwater Behemoth
	[1517] = 2351, -- Orgozoa
	[1518] = 2359, -- The Queen's Court
	[1519] = 2349, -- Za'qul, Harbinger of Ny'alotha
	[1520] = 2361, -- Queen Azshara
};
Internal.instanceDifficulties = instanceDifficulties;
Internal.dungeonInfo = dungeonInfo;
Internal.raidInfo = raidInfo;
Internal.instanceBosses = instanceBosses;
Internal.npcIDToBossID = npcIDToBossID;
Internal.InstanceAreaIDToBossID = InstanceAreaIDToBossID;
Internal.uiMapIDToBossID = uiMapIDToBossID;

function Internal.GetAffixesName(affixesID)
	local names = {};
	local icons = {};
	while affixesID > 0 do
		local affixID = bit.band(affixesID, 0xFF);
		affixesID = bit.rshift(affixesID, 8);

		local name, _, icon = GetAffixInfo(affixID);
		names[#names+1] = name;
		icons[#icons+1] = format("|T%d:18:18:0:0|t %s", icon, name);
	end

	return affixesID, table.concat(names, " "), table.concat(icons, ", ");
end
local function GetAffixesInfo(...)
	local id = 0;
	local names = {};
	local icons = {};
	for i=1,select('#', ...) do
		local affixID = select(i, ...);
		local name, _, icon = GetAffixInfo(affixID);

		id = bit.bor(bit.rshift(id, 8), bit.lshift(affixID, 24));
		names[#names+1] = name;
		icons[#icons+1] = format("|T%d:18:18:0:0|t %s", icon, name);
	end
	return {
		id = id,
		name = table.concat(names, ", "),
		fullName = table.concat(icons, ", "),
	};
end
Internal.GetAffixesInfo = GetAffixesInfo;
local affixRotation = {
	GetAffixesInfo(10, 7, 12, 119), -- Fortified, 	Bolstering, Grievous, 	Beguiling
	GetAffixesInfo(9, 6, 13, 119), 	-- Tyrannical, 	Raging, 	Explosive, 	Beguiling
	GetAffixesInfo(10, 8, 12, 119), -- Fortified, 	Sanguine, 	Grievous, 	Beguiling
	GetAffixesInfo(9, 5, 3, 119), 	-- Tyrannical, 	Teeming, 	Volcanic, 	Beguiling
	GetAffixesInfo(10, 7, 2, 119), 	-- Fortified, 	Bolstering, Skittish, 	Beguiling
	GetAffixesInfo(9, 11, 4, 119), 	-- Tyrannical, 	Bursting, 	Necrotic, 	Beguiling
	GetAffixesInfo(10, 8, 14, 119),	-- Fortified, 	Sanguine, 	Quaking, 	Beguiling
	GetAffixesInfo(9, 7, 13, 119), 	-- Tyrannical, 	Bolstering, Explosive, 	Beguiling
	GetAffixesInfo(10, 11, 3, 119),	-- Fortified, 	Bursting, 	Volcanic, 	Beguiling
	GetAffixesInfo(9, 6, 4, 119),	-- Tyrannical, 	Raging, 	Necrotic, 	Beguiling
	GetAffixesInfo(10, 5, 14, 119),	-- Fortified, 	Teeming, 	Quaking, 	Beguiling
	GetAffixesInfo(9, 11, 2, 119),	-- Tyrannical, 	Bursting, 	Skittish, 	Beguiling
};
function Internal.AffixRotation()
    return ipairs(affixRotation)
end

local areaNameToIDMap = {};
Internal.areaNameToIDMap = areaNameToIDMap;
_G['BtWLoadoutsAreaMap'] = areaNameToIDMap; -- @TODO Remove

-- Updates areaNameToIDMap with localized area name to area id
function Internal.UpdateAreaMap()
	local instanceID = select(8, GetInstanceInfo());
	if instanceID and InstanceAreaIDToBossID[instanceID] then
		areaNameToIDMap[instanceID] = areaNameToIDMap[instanceID] or {};
		local map = areaNameToIDMap[instanceID];
		for areaID in pairs(InstanceAreaIDToBossID[instanceID]) do
			local areaName = GetAreaInfo(areaID);
			if areaName then
				map[areaName] = areaID;
			end
		end
	end
end
