-----------------------------------------------------------------------------------------------
-- Client Lua Script for CardsData
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Card Definition
-----------------------------------------------------------------------------------------------
local CardsData = {} 
CardsData.__index = CardsData

setmetatable(CardsData, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- Card back sprite name.
CardsData.kstrCardBackSprite = "CardsSprites:CardBack" 
 
-- Table containing definitions for glow colours.
CardsData.karGlowColours =
{
	["Friendly"] = CColor.new(0.0156, 0.5215, 0.8196, 1),
	["Hostile"] = CColor.new(0.9086, 0.0078, 0.1647, 1),
}

CardsData.karQuality =
{
	[1] = { strName = "Inferior", strSprite = "BK3:UI_BK3_ItemQualityGrey" },
	[2] = { strName = "Average", strSprite = "BK3:UI_BK3_ItemQualityWhite" },
	[3] = { strName = "Good", strSprite = "BK3:UI_BK3_ItemQualityGreen" },
	[4] = { strName = "Excellent", strSprite = "BK3:UI_BK3_ItemQualityBlue" },
	[5] = { strName = "Superb", strSprite = "BK3:UI_BK3_ItemQualityPurple" },
	[6] = { strName = "Legendary", strSprite = "BK3:UI_BK3_ItemQualityOrange" },
	[7] = { strName = "Artifact", strSprite = "BK3:UI_BK3_ItemQualityMagenta" },
}

-- Defined card IDs
CardsData.knCardIdAurin = 107
CardsData.knCardIdCassian = 89
CardsData.knCardIdChua = 90
CardsData.knCardIdDraken = 91
CardsData.knCardIdGranok = 108
CardsData.knCardIdHuman = 109
CardsData.knCardIdMechari = 92
CardsData.knCardIdMordesh = 110
CardsData.knCardIdExplorer = 120
CardsData.knCardIdScientist = 121
CardsData.knCardIdSettler = 122
CardsData.knCardIdSoldier = 123

CardsData.knCardIdEngineer = 9
CardsData.knCardIdEsper = 10
CardsData.knCardIdMedic = 11
CardsData.knCardIdSpellslinger = 12
CardsData.knCardIdStalker = 13
CardsData.knCardIdWarrior = 14

-- Table containing definitions for each card.
CardsData.karCards =
{
	[1] = { nCardId = 1, nNumber = 1, strCategory = "Adventures", strName = "Hycrest Insurrection", nQualityID = 4, nTop = 4, nRight = 6, nBottom = 6, nLeft = 2, strFlair = "", strSprite = "CardsSprites:001_Hycrest" },
	[2] = { nCardId = 2, nNumber = 2, strCategory = "Adventures", strName = "Riot in the Void", nQualityID = 4, nTop = 5, nRight = 2, nBottom = 7, nLeft = 4, strFlair = "", strSprite = "CardsSprites:002_RiotVoid" },
	[3] = { nCardId = 3, nNumber = 3, strCategory = "Adventures", strName = "War of the Wilds", nQualityID = 4, nTop = 4, nRight = 8, nBottom = 5, nLeft = 1, strFlair = "", strSprite = "CardsSprites:003_WarWilds" },
	[4] = { nCardId = 4, nNumber = 4, strCategory = "Adventures", strName = "The Siege of Tempest Refuge", nQualityID = 4, nTop = 5, nRight = 6, nBottom = 4, nLeft = 3, strFlair = "", strSprite = "CardsSprites:004_SiegeTempestRefuge" },
	[5] = { nCardId = 5, nNumber = 5, strCategory = "Adventures", strName = "Crimelords of Whitevale", nQualityID = 4, nTop = 3, nRight = 7, nBottom = 2, nLeft = 6, strFlair = "", strSprite = "CardsSprites:005_CrimelordsWhitevale" },
	[6] = { nCardId = 6, nNumber = 6, strCategory = "Adventures", strName = "The Malgrave Trail", nQualityID = 4, nTop = 5, nRight = 3, nBottom = 7, nLeft = 3, strFlair = "", strSprite = "CardsSprites:006_MalgraveTrail" },
	[7] = { nCardId = 7, nNumber = 7, strCategory = "Battlegrounds", strName = "Walatiki Temple", nQualityID = 4, nTop = 5, nRight = 3, nBottom = 6, nLeft = 4, strFlair = "", strSprite = "CardsSprites:007_Walatiki" },
	[8] = { nCardId = 8, nNumber = 8, strCategory = "Battlegrounds", strName = "Halls of the Bloodsworn", nQualityID = 4, nTop = 1, nRight = 7, nBottom = 3, nLeft = 7, strFlair = "", strSprite = "CardsSprites:008_Bloodsworn" },
	[9] = { nCardId = 9, nNumber = 9, strCategory = "Classes", strName = "Engineer", nQualityID = 3, nTop = 7, nRight = 3, nBottom = 3, nLeft = 2, strFlair = "", strSprite = "CardsSprites:009_Engineer" },
	[10] = { nCardId = 10, nNumber = 10, strCategory = "Classes", strName = "Esper", nQualityID = 3, nTop = 5, nRight = 7, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:010_Esper" },
	[11] = { nCardId = 11, nNumber = 11, strCategory = "Classes", strName = "Medic", nQualityID = 3, nTop = 3, nRight = 3, nBottom = 7, nLeft = 2, strFlair = "", strSprite = "CardsSprites:011_Medic" },
	[12] = { nCardId = 12, nNumber = 12, strCategory = "Classes", strName = "Spellslinger", nQualityID = 3, nTop = 2, nRight = 5, nBottom = 1, nLeft = 7, strFlair = "", strSprite = "CardsSprites:012_Spellslinger" },
	[13] = { nCardId = 13, nNumber = 13, strCategory = "Classes", strName = "Stalker", nQualityID = 3, nTop = 7, nRight = 2, nBottom = 4, nLeft = 2, strFlair = "", strSprite = "CardsSprites:013_Stalker" },
	[14] = { nCardId = 14, nNumber = 14, strCategory = "Classes", strName = "Warrior", nQualityID = 3, nTop = 3, nRight = 3, nBottom = 2, nLeft = 7, strFlair = "", strSprite = "CardsSprites:014_Warrior" },
	[15] = { nCardId = 15, nNumber = 15, strCategory = "Creatures", strName = "Augmented", nQualityID = 2, nTop = 3, nRight = 3, nBottom = 1, nLeft = 5, strFlair = "", strSprite = "CardsSprites:015_Augmented" },
	[16] = { nCardId = 16, nNumber = 16, strCategory = "Creatures", strName = "Augmentor", nQualityID = 2, nTop = 6, nRight = 4, nBottom = 1, nLeft = 1, strFlair = "Logic", strSprite = "CardsSprites:016_Augmentor" },
	[17] = { nCardId = 17, nNumber = 17, strCategory = "Creatures", strName = "BattleBot", nQualityID = 2, nTop = 6, nRight = 3, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:017_BattleBot" },
	[18] = { nCardId = 18, nNumber = 18, strCategory = "Creatures", strName = "Boulderback", nQualityID = 2, nTop = 3, nRight = 1, nBottom = 2, nLeft = 6, strFlair = "Earth", strSprite = "CardsSprites:018_Boulderback" },
	[19] = { nCardId = 19, nNumber = 19, strCategory = "Creatures", strName = "Buzzbing", nQualityID = 2, nTop = 7, nRight = 2, nBottom = 1, nLeft = 2, strFlair = "", strSprite = "CardsSprites:019_Buzzbing" },
	[20] = { nCardId = 20, nNumber = 20, strCategory = "Creatures", strName = "Canimid", nQualityID = 2, nTop = 4, nRight = 5, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:020_Canimid" },
	[21] = { nCardId = 21, nNumber = 21, strCategory = "Creatures", strName = "Chompacabra", nQualityID = 2, nTop = 5, nRight = 2, nBottom = 4, nLeft = 1, strFlair = "", strSprite = "CardsSprites:021_Chompacabra" },
	[22] = { nCardId = 22, nNumber = 22, strCategory = "Creatures", strName = "Dagun", nQualityID = 2, nTop = 1, nRight = 7, nBottom = 2, nLeft = 2, strFlair = "", strSprite = "CardsSprites:022_Dagun" },
	[23] = { nCardId = 23, nNumber = 23, strCategory = "Creatures", strName = "Darkspur", nQualityID = 2, nTop = 2, nRight = 8, nBottom = 1, nLeft = 1, strFlair = "", strSprite = "CardsSprites:023_Darkspur" },
	[24] = { nCardId = 24, nNumber = 24, strCategory = "Creatures", strName = "Dreg", nQualityID = 2, nTop = 2, nRight = 4, nBottom = 3, nLeft = 3, strFlair = "", strSprite = "CardsSprites:024_Dreg" },
	[25] = { nCardId = 25, nNumber = 25, strCategory = "Creatures", strName = "Drifter", nQualityID = 2, nTop = 2, nRight = 3, nBottom = 2, nLeft = 5, strFlair = "", strSprite = "CardsSprites:025_Drifter" },
	[26] = { nCardId = 26, nNumber = 26, strCategory = "Creatures", strName = "Elemental", nQualityID = 2, nTop = 3, nRight = 2, nBottom = 2, nLeft = 5, strFlair = "", strSprite = "CardsSprites:026_Elemental" },
	[27] = { nCardId = 27, nNumber = 27, strCategory = "Creatures", strName = "Falkrin", nQualityID = 2, nTop = 5, nRight = 1, nBottom = 5, nLeft = 1, strFlair = "Air", strSprite = "CardsSprites:027_Falkrin" },
	[28] = { nCardId = 28, nNumber = 28, strCategory = "Creatures", strName = "Freebot", nQualityID = 2, nTop = 4, nRight = 5, nBottom = 1, nLeft = 2, strFlair = "Logic", strSprite = "CardsSprites:028_Freebot" },
	[29] = { nCardId = 29, nNumber = 29, strCategory = "Creatures", strName = "Garr", nQualityID = 2, nTop = 7, nRight = 1, nBottom = 3, nLeft = 1, strFlair = "", strSprite = "CardsSprites:029_Garr" },
	[30] = { nCardId = 30, nNumber = 30, strCategory = "Creatures", strName = "Giant", nQualityID = 2, nTop = 4, nRight = 1, nBottom = 2, nLeft = 5, strFlair = "", strSprite = "CardsSprites:030_Giant" },
	[31] = { nCardId = 31, nNumber = 31, strCategory = "Creatures", strName = "Girrok", nQualityID = 2, nTop = 2, nRight = 7, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:031_Girrok" },
	[32] = { nCardId = 32, nNumber = 32, strCategory = "Creatures", strName = "Gorganoth", nQualityID = 2, nTop = 2, nRight = 1, nBottom = 1, nLeft = 8, strFlair = "", strSprite = "CardsSprites:032_Gorganoth" },
	[33] = { nCardId = 33, nNumber = 33, strCategory = "Creatures", strName = "Gronyx", nQualityID = 2, nTop = 4, nRight = 1, nBottom = 3, nLeft = 4, strFlair = "Earth", strSprite = "CardsSprites:033_Gronyx" },
	[34] = { nCardId = 34, nNumber = 34, strCategory = "Creatures", strName = "Heynar", nQualityID = 2, nTop = 4, nRight = 2, nBottom = 1, nLeft = 5, strFlair = "", strSprite = "CardsSprites:034_Heynar" },
	[35] = { nCardId = 35, nNumber = 35, strCategory = "Creatures", strName = "Hookfoot", nQualityID = 2, nTop = 2, nRight = 2, nBottom = 3, nLeft = 5, strFlair = "", strSprite = "CardsSprites:035_Hookfoot" },
	[36] = { nCardId = 36, nNumber = 36, strCategory = "Creatures", strName = "Ikthian", nQualityID = 2, nTop = 1, nRight = 8, nBottom = 2, nLeft = 1, strFlair = "Water", strSprite = "CardsSprites:036_Ikthian" },
	[37] = { nCardId = 37, nNumber = 37, strCategory = "Creatures", strName = "[Ikthian Brawler]", nQualityID = 2, nTop = 2, nRight = 3, nBottom = 6, nLeft = 1, strFlair = "", strSprite = "CardsSprites:037_IkthianBrawler" },
	[38] = { nCardId = 38, nNumber = 38, strCategory = "Creatures", strName = "Kurg", nQualityID = 2, nTop = 5, nRight = 4, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:038_Kurg" },
	[39] = { nCardId = 39, nNumber = 39, strCategory = "Creatures", strName = "Longsnout", nQualityID = 2, nTop = 1, nRight = 2, nBottom = 1, nLeft = 8, strFlair = "", strSprite = "CardsSprites:039_Longsnout" },
	[40] = { nCardId = 40, nNumber = 40, strCategory = "Creatures", strName = "Malverine", nQualityID = 2, nTop = 5, nRight = 3, nBottom = 2, nLeft = 2, strFlair = "", strSprite = "CardsSprites:040_Malverine" },
	[41] = { nCardId = 41, nNumber = 41, strCategory = "Creatures", strName = "Mammodin", nQualityID = 2, nTop = 4, nRight = 3, nBottom = 1, nLeft = 4, strFlair = "", strSprite = "CardsSprites:041_Mammodin" },
	[42] = { nCardId = 42, nNumber = 42, strCategory = "Creatures", strName = "Moodie", nQualityID = 2, nTop = 1, nRight = 1, nBottom = 4, nLeft = 6, strFlair = "", strSprite = "CardsSprites:042_Moodie" },
	[43] = { nCardId = 43, nNumber = 43, strCategory = "Creatures", strName = "Murgh", nQualityID = 2, nTop = 2, nRight = 4, nBottom = 1, nLeft = 5, strFlair = "", strSprite = "CardsSprites:043_Murgh" },
	[44] = { nCardId = 44, nNumber = 44, strCategory = "Creatures", strName = "Orbitog", nQualityID = 2, nTop = 4, nRight = 4, nBottom = 1, nLeft = 3, strFlair = "", strSprite = "CardsSprites:044_Orbitog" },
	[45] = { nCardId = 45, nNumber = 45, strCategory = "Creatures", strName = "Osun", nQualityID = 2, nTop = 1, nRight = 1, nBottom = 6, nLeft = 4, strFlair = "", strSprite = "CardsSprites:045_Osun" },
	[46] = { nCardId = 46, nNumber = 46, strCategory = "Creatures", strName = "Pell", nQualityID = 2, nTop = 2, nRight = 6, nBottom = 1, nLeft = 3, strFlair = "", strSprite = "CardsSprites:046_Pell" },
	[47] = { nCardId = 47, nNumber = 47, strCategory = "Creatures", strName = "Probe", nQualityID = 2, nTop = 1, nRight = 6, nBottom = 1, nLeft = 4, strFlair = "Logic", strSprite = "CardsSprites:047_Probe" },
	[48] = { nCardId = 48, nNumber = 48, strCategory = "Creatures", strName = "Protector", nQualityID = 2, nTop = 7, nRight = 2, nBottom = 2, nLeft = 1, strFlair = "Logic", strSprite = "CardsSprites:048_Protector" },
	[49] = { nCardId = 49, nNumber = 49, strCategory = "Creatures", strName = "Pumera", nQualityID = 2, nTop = 5, nRight = 4, nBottom = 1, nLeft = 2, strFlair = "", strSprite = "CardsSprites:049_Pumera" },
	[50] = { nCardId = 50, nNumber = 50, strCategory = "Creatures", strName = "Ravenok", nQualityID = 2, nTop = 3, nRight = 2, nBottom = 3, nLeft = 4, strFlair = "", strSprite = "CardsSprites:050_Ravenok" },
	[51] = { nCardId = 51, nNumber = 51, strCategory = "Creatures", strName = "Razortail", nQualityID = 2, nTop = 4, nRight = 1, nBottom = 1, nLeft = 6, strFlair = "", strSprite = "CardsSprites:051_Razortail" },
	[52] = { nCardId = 52, nNumber = 52, strCategory = "Creatures", strName = "Razortusk", nQualityID = 2, nTop = 2, nRight = 5, nBottom = 3, nLeft = 2, strFlair = "Water", strSprite = "CardsSprites:052_Razortusk" },
	[53] = { nCardId = 53, nNumber = 53, strCategory = "Creatures", strName = "Roan", nQualityID = 2, nTop = 2, nRight = 1, nBottom = 3, nLeft = 6, strFlair = "", strSprite = "CardsSprites:053_Roan" },
	[54] = { nCardId = 54, nNumber = 54, strCategory = "Creatures", strName = "Rockhorde", nQualityID = 2, nTop = 3, nRight = 4, nBottom = 2, nLeft = 3, strFlair = "", strSprite = "CardsSprites:054_Rockhorde" },
	[55] = { nCardId = 55, nNumber = 55, strCategory = "Creatures", strName = "Rootbrute", nQualityID = 2, nTop = 2, nRight = 1, nBottom = 7, nLeft = 2, strFlair = "", strSprite = "CardsSprites:055_Rootbrute" },
	[56] = { nCardId = 56, nNumber = 56, strCategory = "Creatures", strName = "Scrab", nQualityID = 2, nTop = 6, nRight = 1, nBottom = 4, nLeft = 1, strFlair = "", strSprite = "CardsSprites:056_Scrab" },
	[57] = { nCardId = 57, nNumber = 57, strCategory = "Creatures", strName = "Skeech", nQualityID = 2, nTop = 5, nRight = 1, nBottom = 1, nLeft = 5, strFlair = "", strSprite = "CardsSprites:057_Skeech" },
	[58] = { nCardId = 58, nNumber = 58, strCategory = "Creatures", strName = "Snoglug", nQualityID = 2, nTop = 5, nRight = 5, nBottom = 1, nLeft = 1, strFlair = "", strSprite = "CardsSprites:058_Snoglug" },
	[59] = { nCardId = 59, nNumber = 59, strCategory = "Creatures", strName = "Spider", nQualityID = 2, nTop = 1, nRight = 3, nBottom = 6, nLeft = 2, strFlair = "", strSprite = "CardsSprites:059_Spider" },
	[60] = { nCardId = 60, nNumber = 60, strCategory = "Creatures", strName = "Spiderbot", nQualityID = 2, nTop = 1, nRight = 5, nBottom = 3, nLeft = 3, strFlair = "Logic", strSprite = "CardsSprites:060_Spiderbot" },
	[61] = { nCardId = 61, nNumber = 61, strCategory = "Creatures", strName = "Spiderling", nQualityID = 2, nTop = 3, nRight = 1, nBottom = 3, nLeft = 5, strFlair = "", strSprite = "CardsSprites:061_Spiderling" },
	[62] = { nCardId = 62, nNumber = 62, strCategory = "Creatures", strName = "Squirg", nQualityID = 2, nTop = 8, nRight = 2, nBottom = 1, nLeft = 1, strFlair = "", strSprite = "CardsSprites:062_Squirg" },
	[63] = { nCardId = 63, nNumber = 63, strCategory = "Creatures", strName = "Stag", nQualityID = 2, nTop = 5, nRight = 1, nBottom = 2, nLeft = 4, strFlair = "", strSprite = "CardsSprites:063_Stag" },
	[64] = { nCardId = 64, nNumber = 64, strCategory = "Creatures", strName = "Steamglider", nQualityID = 2, nTop = 3, nRight = 3, nBottom = 2, nLeft = 4, strFlair = "", strSprite = "CardsSprites:064_Steamglider" },
	[65] = { nCardId = 65, nNumber = 65, strCategory = "Creatures", strName = "Stemdragon", nQualityID = 2, nTop = 6, nRight = 1, nBottom = 2, nLeft = 3, strFlair = "", strSprite = "CardsSprites:065_Stemdragon" },
	[66] = { nCardId = 66, nNumber = 66, strCategory = "Creatures", strName = "Strain", nQualityID = 2, nTop = 4, nRight = 4, nBottom = 2, nLeft = 2, strFlair = "", strSprite = "CardsSprites:066_Strain" },
	[67] = { nCardId = 67, nNumber = 67, strCategory = "Creatures", strName = "Stumpkin", nQualityID = 2, nTop = 5, nRight = 2, nBottom = 1, nLeft = 4, strFlair = "", strSprite = "CardsSprites:067_Stumpkin" },
	[68] = { nCardId = 68, nNumber = 68, strCategory = "Creatures", strName = "Terminite", nQualityID = 2, nTop = 5, nRight = 3, nBottom = 3, nLeft = 1, strFlair = "", strSprite = "CardsSprites:068_Terminite" },
	[69] = { nCardId = 69, nNumber = 69, strCategory = "Creatures", strName = "Torine", nQualityID = 2, nTop = 3, nRight = 2, nBottom = 1, nLeft = 6, strFlair = "", strSprite = "CardsSprites:069_Torine" },
	[70] = { nCardId = 70, nNumber = 70, strCategory = "Creatures", strName = "Vulcarrion", nQualityID = 2, nTop = 7, nRight = 1, nBottom = 1, nLeft = 3, strFlair = "Air", strSprite = "CardsSprites:070_Vulcarrion" },
	[71] = { nCardId = 71, nNumber = 71, strCategory = "Creatures", strName = "Yeti", nQualityID = 2, nTop = 6, nRight = 2, nBottom = 1, nLeft = 3, strFlair = "", strSprite = "CardsSprites:071_Yeti" },
	[72] = { nCardId = 72, nNumber = 72, strCategory = "Critters", strName = "Cubig", nQualityID = 1, nTop = 3, nRight = 3, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:072_Cubig" },
	[73] = { nCardId = 73, nNumber = 73, strCategory = "Critters", strName = "Frizlet", nQualityID = 1, nTop = 1, nRight = 1, nBottom = 1, nLeft = 6, strFlair = "", strSprite = "CardsSprites:073_Frizlet" },
	[74] = { nCardId = 74, nNumber = 74, strCategory = "Critters", strName = "Jabbit", nQualityID = 1, nTop = 1, nRight = 5, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:074_Jabbit" },
	[75] = { nCardId = 75, nNumber = 75, strCategory = "Critters", strName = "Rowsdowser", nQualityID = 1, nTop = 2, nRight = 4, nBottom = 1, nLeft = 2, strFlair = "", strSprite = "CardsSprites:075_Rowsdowser" },
	[76] = { nCardId = 76, nNumber = 76, strCategory = "Critters", strName = "Slank", nQualityID = 1, nTop = 2, nRight = 4, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:076_Slank" },
	[77] = { nCardId = 77, nNumber = 77, strCategory = "Critters", strName = "Splorg", nQualityID = 1, nTop = 2, nRight = 2, nBottom = 3, nLeft = 2, strFlair = "", strSprite = "CardsSprites:077_Splorg" },
	[78] = { nCardId = 78, nNumber = 78, strCategory = "Critters", strName = "Veggie", nQualityID = 1, nTop = 3, nRight = 1, nBottom = 4, nLeft = 1, strFlair = "", strSprite = "CardsSprites:078_Veggie" },
	[79] = { nCardId = 79, nNumber = 79, strCategory = "Critters", strName = "Vind", nQualityID = 1, nTop = 4, nRight = 3, nBottom = 1, nLeft = 1, strFlair = "", strSprite = "CardsSprites:079_Vind" },
	[80] = { nCardId = 80, nNumber = 80, strCategory = "Dominion", strName = "The Dominion", nQualityID = 4, nTop = 6, nRight = 3, nBottom = 3, nLeft = 6, strFlair = "", strSprite = "CardsSprites:080_Dominion" },
	[81] = { nCardId = 81, nNumber = 81, strCategory = "Dominion", strName = "Agent Lex", nQualityID = 4, nTop = 5, nRight = 3, nBottom = 4, nLeft = 6, strFlair = "", strSprite = "CardsSprites:081_AgentLex" },
	[82] = { nCardId = 82, nNumber = 82, strCategory = "Dominion", strName = "Artemis Zin", nQualityID = 4, nTop = 2, nRight = 4, nBottom = 8, nLeft = 4, strFlair = "", strSprite = "CardsSprites:082_ArtemisZin" },
	[83] = { nCardId = 83, nNumber = 83, strCategory = "Dominion", strName = "Corrigan Doon", nQualityID = 4, nTop = 4, nRight = 3, nBottom = 2, nLeft = 9, strFlair = "", strSprite = "CardsSprites:083_CorriganDoon" },
	[84] = { nCardId = 84, nNumber = 84, strCategory = "Dominion", strName = "Emperor Myrcalus", nQualityID = 4, nTop = 12, nRight = 1, nBottom = 3, nLeft = 2, strFlair = "", strSprite = "CardsSprites:084_EmperorMyrcalus" },
	[85] = { nCardId = 85, nNumber = 85, strCategory = "Dominion", strName = "General Kezrek Warbringer", nQualityID = 4, nTop = 4, nRight = 1, nBottom = 9, nLeft = 4, strFlair = "", strSprite = "CardsSprites:085_KezrekWarbringer" },
	[86] = { nCardId = 86, nNumber = 86, strCategory = "Dominion", strName = "Malvolio Portius", nQualityID = 4, nTop = 1, nRight = 8, nBottom = 7, nLeft = 2, strFlair = "", strSprite = "CardsSprites:086_MalvolioPortius" },
	[87] = { nCardId = 87, nNumber = 87, strCategory = "Dominion", strName = "Mondo Zax", nQualityID = 4, nTop = 10, nRight = 3, nBottom = 2, nLeft = 3, strFlair = "", strSprite = "CardsSprites:087_MondoZax" },
	[88] = { nCardId = 88, nNumber = 88, strCategory = "Dominion", strName = "Toric Antevian", nQualityID = 4, nTop = 3, nRight = 7, nBottom = 5, nLeft = 3, strFlair = "", strSprite = "CardsSprites:088_ToricAntevian" },
	[89] = { nCardId = 89, nNumber = 89, strCategory = "Dominion", strName = "Cassian", nQualityID = 3, nTop = 4, nRight = 4, nBottom = 4, nLeft = 3, strFlair = "", strSprite = "CardsSprites:089_Cassian" },
	[90] = { nCardId = 90, nNumber = 90, strCategory = "Dominion", strName = "Chua", nQualityID = 3, nTop = 3, nRight = 4, nBottom = 7, nLeft = 1, strFlair = "", strSprite = "CardsSprites:090_Chua" },
	[91] = { nCardId = 91, nNumber = 91, strCategory = "Dominion", strName = "Draken", nQualityID = 3, nTop = 7, nRight = 6, nBottom = 1, nLeft = 1, strFlair = "", strSprite = "CardsSprites:091_Draken" },
	[92] = { nCardId = 92, nNumber = 92, strCategory = "Dominion", strName = "Mechari", nQualityID = 3, nTop = 6, nRight = 5, nBottom = 1, nLeft = 3, strFlair = "", strSprite = "CardsSprites:092_Mechari" },
	[93] = { nCardId = 93, nNumber = 93, strCategory = "Dominion", strName = "Dominion Warbot", nQualityID = 2, nTop = 3, nRight = 5, nBottom = 2, nLeft = 2, strFlair = "", strSprite = "CardsSprites:093_DominionWarbot" },
	[94] = { nCardId = 94, nNumber = 94, strCategory = "Dungeons", strName = "Stormtalon's Lair", nQualityID = 5, nTop = 3, nRight = 3, nBottom = 8, nLeft = 7, strFlair = "", strSprite = "CardsSprites:094_StormtalonsLair" },
	[95] = { nCardId = 95, nNumber = 95, strCategory = "Dungeons", strName = "Kel Vorath", nQualityID = 5, nTop = 5, nRight = 3, nBottom = 5, nLeft = 8, strFlair = "", strSprite = "CardsSprites:095_KelVorath" },
	[96] = { nCardId = 96, nNumber = 96, strCategory = "Dungeons", strName = "Skullcano", nQualityID = 5, nTop = 3, nRight = 8, nBottom = 6, nLeft = 4, strFlair = "", strSprite = "CardsSprites:096_Skullcano" },
	[97] = { nCardId = 97, nNumber = 97, strCategory = "Dungeons", strName = "Sanctuary of the Swordmaiden", nQualityID = 5, nTop = 8, nRight = 4, nBottom = 4, nLeft = 5, strFlair = "", strSprite = "CardsSprites:097_SanctuarySwordmaiden" },
	[98] = { nCardId = 98, nNumber = 98, strCategory = "Exiles", strName = "The Exiles", nQualityID = 4, nTop = 3, nRight = 6, nBottom = 6, nLeft = 3, strFlair = "", strSprite = "CardsSprites:098_Exiles" },
	[99] = { nCardId = 99, nNumber = 99, strCategory = "Exiles", strName = "Avra \"The Widow\" Darkos", nQualityID = 4, nTop = 7, nRight = 7, nBottom = 1, nLeft = 3, strFlair = "", strSprite = "CardsSprites:099_AvraDarkos" },
	[100] = { nCardId = 100, nNumber = 100, strCategory = "Exiles", strName = "Deadeye Brightland", nQualityID = 4, nTop = 3, nRight = 3, nBottom = 3, nLeft = 9, strFlair = "", strSprite = "CardsSprites:100_DeadeyeBrightland" },
	[101] = { nCardId = 101, nNumber = 101, strCategory = "Exiles", strName = "Dorian Walker", nQualityID = 4, nTop = 1, nRight = 8, nBottom = 2, nLeft = 7, strFlair = "", strSprite = "CardsSprites:101_DorianWalker" },
	[102] = { nCardId = 102, nNumber = 102, strCategory = "Exiles", strName = "Durek Stonebreaker", nQualityID = 4, nTop = 5, nRight = 5, nBottom = 3, nLeft = 5, strFlair = "", strSprite = "CardsSprites:102_DurekStonebreaker" },
	[103] = { nCardId = 103, nNumber = 103, strCategory = "Exiles", strName = "Judge Kain", nQualityID = 4, nTop = 3, nRight = 4, nBottom = 5, nLeft = 6, strFlair = "", strSprite = "CardsSprites:103_JudgeKain" },
	[104] = { nCardId = 104, nNumber = 104, strCategory = "Exiles", strName = "Kit Brinny", nQualityID = 4, nTop = 8, nRight = 2, nBottom = 5, nLeft = 3, strFlair = "", strSprite = "CardsSprites:104_KitBrinny" },
	[105] = { nCardId = 105, nNumber = 105, strCategory = "Exiles", strName = "Queen Myala Everstar", nQualityID = 4, nTop = 4, nRight = 6, nBottom = 5, nLeft = 3, strFlair = "", strSprite = "CardsSprites:105_QueenMyalaEverstar" },
	[106] = { nCardId = 106, nNumber = 106, strCategory = "Exiles", strName = "Victor Lazarin", nQualityID = 4, nTop = 4, nRight = 5, nBottom = 5, nLeft = 4, strFlair = "", strSprite = "CardsSprites:106_VictorLazarin" },
	[107] = { nCardId = 107, nNumber = 107, strCategory = "Exiles", strName = "Aurin", nQualityID = 3, nTop = 2, nRight = 2, nBottom = 8, nLeft = 3, strFlair = "", strSprite = "CardsSprites:107_Aurin" },
	[108] = { nCardId = 108, nNumber = 108, strCategory = "Exiles", strName = "Granok", nQualityID = 3, nTop = 8, nRight = 2, nBottom = 3, nLeft = 2, strFlair = "", strSprite = "CardsSprites:108_Granok" },
	[109] = { nCardId = 109, nNumber = 109, strCategory = "Exiles", strName = "Human", nQualityID = 3, nTop = 2, nRight = 5, nBottom = 6, nLeft = 2, strFlair = "", strSprite = "CardsSprites:109_Human" },
	[110] = { nCardId = 110, nNumber = 110, strCategory = "Exiles", strName = "Mordesh", nQualityID = 3, nTop = 3, nRight = 4, nBottom = 2, nLeft = 6, strFlair = "", strSprite = "CardsSprites:110_Mordresh" },
	[111] = { nCardId = 111, nNumber = 111, strCategory = "Exiles", strName = "Exile Warbot", nQualityID = 2, nTop = 6, nRight = 2, nBottom = 2, nLeft = 2, strFlair = "", strSprite = "CardsSprites:111_ExileWarbot" },
	[112] = { nCardId = 112, nNumber = 112, strCategory = "Other", strName = "Drusera", nQualityID = 6, nTop = 6, nRight = 6, nBottom = 6, nLeft = 6, strFlair = "Life", strSprite = "CardsSprites:112_Drusera" },
	[113] = { nCardId = 113, nNumber = 113, strCategory = "Other", strName = "Marshal Yatish", nQualityID = 4, nTop = 8, nRight = 2, nBottom = 7, nLeft = 1, strFlair = "", strSprite = "CardsSprites:113_MarshalYatish" },
	[114] = { nCardId = 114, nNumber = 114, strCategory = "Other", strName = "Megadroid", nQualityID = 4, nTop = 2, nRight = 2, nBottom = 12, nLeft = 2, strFlair = "Logic", strSprite = "CardsSprites:114_Megadroid" },
	[115] = { nCardId = 115, nNumber = 115, strCategory = "Other", strName = "Nexus", nQualityID = 7, nTop = 9, nRight = 8, nBottom = 9, nLeft = 1, strFlair = "", strSprite = "CardsSprites:115_Nexus" },
	[116] = { nCardId = 116, nNumber = 116, strCategory = "Other", strName = "Phineas T Rotostar", nQualityID = 4, nTop = 2, nRight = 4, nBottom = 11, nLeft = 1, strFlair = "", strSprite = "CardsSprites:116_Protostar" },
	[117] = { nCardId = 117, nNumber = 117, strCategory = "Other", strName = "The Caretaker", nQualityID = 5, nTop = 1, nRight = 9, nBottom = 2, nLeft = 9, strFlair = "Logic", strSprite = "CardsSprites:117_Caretaker" },
	[118] = { nCardId = 118, nNumber = 118, strCategory = "Other", strName = "The Entity", nQualityID = 6, nTop = 14, nRight = 2, nBottom = 6, nLeft = 2, strFlair = "Fusion", strSprite = "CardsSprites:118_Entity" },
	[119] = { nCardId = 119, nNumber = 119, strCategory = "Other", strName = "Tresayne Toria", nQualityID = 4, nTop = 3, nRight = 6, nBottom = 2, nLeft = 7, strFlair = "", strSprite = "CardsSprites:119_Tresayne Toria" },
	[120] = { nCardId = 120, nNumber = 120, strCategory = "Paths", strName = "Explorer", nQualityID = 2, nTop = 4, nRight = 2, nBottom = 2, nLeft = 4, strFlair = "", strSprite = "CardsSprites:120_Explorer" },
	[121] = { nCardId = 121, nNumber = 121, strCategory = "Paths", strName = "Scientist", nQualityID = 2, nTop = 1, nRight = 5, nBottom = 1, nLeft = 5, strFlair = "", strSprite = "CardsSprites:121_Scientist" },
	[122] = { nCardId = 122, nNumber = 122, strCategory = "Paths", strName = "Settler", nQualityID = 2, nTop = 2, nRight = 3, nBottom = 4, nLeft = 3, strFlair = "", strSprite = "CardsSprites:122_Settler" },
	[123] = { nCardId = 123, nNumber = 123, strCategory = "Paths", strName = "Soldier", nQualityID = 2, nTop = 3, nRight = 3, nBottom = 3, nLeft = 3, strFlair = "", strSprite = "CardsSprites:123_Soldier" },
	[124] = { nCardId = 124, nNumber = 124, strCategory = "Raids", strName = "Genetic Archives", nQualityID = 6, nTop = 12, nRight = 5, nBottom = 4, nLeft = 3, strFlair = "", strSprite = "CardsSprites:124_GeneticArchives" },
	[125] = { nCardId = 125, nNumber = 125, strCategory = "Raids", strName = "Datascape", nQualityID = 6, nTop = 2, nRight = 8, nBottom = 10, nLeft = 4, strFlair = "", strSprite = "CardsSprites:125_Datascape" },
	[126] = { nCardId = 126, nNumber = 126, strCategory = "Shiphand", strName = "Outpost M-13", nQualityID = 3, nTop = 7, nRight = 5, nBottom = 2, nLeft = 1, strFlair = "", strSprite = "CardsSprites:126_OutpostM13" },
	[127] = { nCardId = 127, nNumber = 127, strCategory = "Shiphand", strName = "Salvage Rights", nQualityID = 3, nTop = 3, nRight = 2, nBottom = 3, nLeft = 7, strFlair = "", strSprite = "CardsSprites:127_SalvageRights" },
	[128] = { nCardId = 128, nNumber = 128, strCategory = "Shiphand", strName = "Rage Logic", nQualityID = 3, nTop = 1, nRight = 7, nBottom = 5, nLeft = 2, strFlair = "", strSprite = "CardsSprites:128_RageLogic" },
	[129] = { nCardId = 129, nNumber = 129, strCategory = "Shiphand", strName = "Space Madness", nQualityID = 3, nTop = 3, nRight = 2, nBottom = 7, nLeft = 3, strFlair = "", strSprite = "CardsSprites:129_SpaceMadness" },
	[130] = { nCardId = 130, nNumber = 130, strCategory = "Shiphand", strName = "Void Hunter", nQualityID = 3, nTop = 3, nRight = 7, nBottom = 1, nLeft = 4, strFlair = "", strSprite = "CardsSprites:130_VoidHunter" },
	[131] = { nCardId = 131, nNumber = 131, strCategory = "Shiphand", strName = "The Gauntlet", nQualityID = 3, nTop = 2, nRight = 4, nBottom = 2, nLeft = 7, strFlair = "", strSprite = "CardsSprites:131_TheGauntlet" },
	[132] = { nCardId = 132, nNumber = 132, strCategory = "Transport", strName = "Gambler's Ruin", nQualityID = 4, nTop = 7, nRight = 4, nBottom = 2, nLeft = 5, strFlair = "Fire", strSprite = "CardsSprites:132_GamblersRuin" },
	[133] = { nCardId = 133, nNumber = 133, strCategory = "Transport", strName = "Destiny", nQualityID = 4, nTop = 4, nRight = 5, nBottom = 6, nLeft = 3, strFlair = "Logic", strSprite = "CardsSprites:133_Destiny" },
	[134] = { nCardId = 134, nNumber = 134, strCategory = "Transport", strName = "Piglet", nQualityID = 3, nTop = 2, nRight = 6, nBottom = 4, nLeft = 3, strFlair = "", strSprite = "CardsSprites:134_Piglet" },
	[135] = { nCardId = 135, nNumber = 135, strCategory = "Transport", strName = "Taxi", nQualityID = 2, nTop = 2, nRight = 3, nBottom = 3, nLeft = 4, strFlair = "", strSprite = "CardsSprites:135_Taxi" },
	[136] = { nCardId = 136, nNumber = 136, strCategory = "Transport", strName = "Unknown 1", nQualityID = 3, nTop = 6, nRight = 3, nBottom = 2, nLeft = 4, strFlair = "", strSprite = "CardsSprites:136_Unknown1" },
	[137] = { nCardId = 137, nNumber = 137, strCategory = "Transport", strName = "Unknown 2", nQualityID = 3, nTop = 2, nRight = 3, nBottom = 4, nLeft = 6, strFlair = "", strSprite = "CardsSprites:137_Unknown2" },
	[138] = { nCardId = 138, nNumber = 138, strCategory = "World Bosses", strName = "Defensive Protocol Unit", nQualityID = 3, nTop = 6, nRight = 2, nBottom = 3, nLeft = 4, strFlair = "", strSprite = "CardsSprites:138_DefensiveProtocolUnit" },
	[139] = { nCardId = 139, nNumber = 139, strCategory = "World Bosses", strName = "Doomthorn the Ancient", nQualityID = 3, nTop = 3, nRight = 1, nBottom = 6, nLeft = 5, strFlair = "", strSprite = "CardsSprites:139_DoomthornAncient" },
	[140] = { nCardId = 140, nNumber = 140, strCategory = "World Bosses", strName = "Grendelus the Guardian", nQualityID = 3, nTop = 1, nRight = 4, nBottom = 7, nLeft = 3, strFlair = "", strSprite = "CardsSprites:140_GrendelusGuardian" },
	[141] = { nCardId = 141, nNumber = 141, strCategory = "World Bosses", strName = "Hellrose Bowl", nQualityID = 3, nTop = 1, nRight = 3, nBottom = 5, nLeft = 6, strFlair = "", strSprite = "CardsSprites:141_HellroseBowl" },
	[142] = { nCardId = 142, nNumber = 142, strCategory = "World Bosses", strName = "Hoarding Stemdragon", nQualityID = 3, nTop = 4, nRight = 7, nBottom = 1, nLeft = 3, strFlair = "", strSprite = "CardsSprites:142_HoardingStemdragon" },
	[143] = { nCardId = 143, nNumber = 143, strCategory = "World Bosses", strName = "King Honeygrave", nQualityID = 3, nTop = 4, nRight = 4, nBottom = 3, nLeft = 4, strFlair = "", strSprite = "CardsSprites:143_KingHoneygrave" },
	[144] = { nCardId = 144, nNumber = 144, strCategory = "World Bosses", strName = "Kraggar", nQualityID = 3, nTop = 2, nRight = 4, nBottom = 6, nLeft = 3, strFlair = "", strSprite = "CardsSprites:144_Kraggar" },
	[145] = { nCardId = 145, nNumber = 145, strCategory = "World Bosses", strName = "Metal Maw", nQualityID = 3, nTop = 3, nRight = 5, nBottom = 5, nLeft = 2, strFlair = "", strSprite = "CardsSprites:145_MetalMaw" },
	[146] = { nCardId = 146, nNumber = 146, strCategory = "World Bosses", strName = "Metal Maw Prime", nQualityID = 3, nTop = 2, nRight = 5, nBottom = 2, nLeft = 6, strFlair = "", strSprite = "CardsSprites:146_MetalMawPrime" },
	[147] = { nCardId = 147, nNumber = 147, strCategory = "Zones", strName = "Thayd", nQualityID = 4, nTop = 4, nRight = 5, nBottom = 4, nLeft = 5, strFlair = "", strSprite = "CardsSprites:147_Thayd" },
	[148] = { nCardId = 148, nNumber = 148, strCategory = "Zones", strName = "Ilium", nQualityID = 4, nTop = 5, nRight = 4, nBottom = 5, nLeft = 4, strFlair = "", strSprite = "CardsSprites:148_Ilium" },
	[149] = { nCardId = 149, nNumber = 149, strCategory = "Zones", strName = "Algoroc", nQualityID = 3, nTop = 3, nRight = 3, nBottom = 4, nLeft = 5, strFlair = "Earth", strSprite = "CardsSprites:149_Algoroc" },
	[150] = { nCardId = 150, nNumber = 150, strCategory = "Zones", strName = "Celestion", nQualityID = 3, nTop = 5, nRight = 4, nBottom = 5, nLeft = 1, strFlair = "Life", strSprite = "CardsSprites:150_Celestion" },
	[151] = { nCardId = 151, nNumber = 151, strCategory = "Zones", strName = "Deradune", nQualityID = 3, nTop = 3, nRight = 2, nBottom = 6, nLeft = 4, strFlair = "Earth", strSprite = "CardsSprites:151_Deradune" },
	[152] = { nCardId = 152, nNumber = 152, strCategory = "Zones", strName = "Ellevar", nQualityID = 3, nTop = 3, nRight = 4, nBottom = 4, nLeft = 4, strFlair = "", strSprite = "CardsSprites:152_Ellevar" },
	[153] = { nCardId = 153, nNumber = 153, strCategory = "Zones", strName = "Galeras", nQualityID = 3, nTop = 4, nRight = 3, nBottom = 3, nLeft = 5, strFlair = "", strSprite = "CardsSprites:153_Galeras" },
	[154] = { nCardId = 154, nNumber = 154, strCategory = "Zones", strName = "Auroria", nQualityID = 3, nTop = 2, nRight = 6, nBottom = 5, nLeft = 2, strFlair = "", strSprite = "CardsSprites:154_Auroria" },
	[155] = { nCardId = 155, nNumber = 155, strCategory = "Zones", strName = "Whitevale", nQualityID = 3, nTop = 7, nRight = 2, nBottom = 3, nLeft = 3, strFlair = "", strSprite = "CardsSprites:155_Whitevale" },
	[156] = { nCardId = 156, nNumber = 156, strCategory = "Zones", strName = "Farside", nQualityID = 3, nTop = 9, nRight = 2, nBottom = 2, nLeft = 2, strFlair = "", strSprite = "CardsSprites:156_Farside" },
	[157] = { nCardId = 157, nNumber = 157, strCategory = "Zones", strName = "Wilderrun", nQualityID = 3, nTop = 3, nRight = 5, nBottom = 3, nLeft = 4, strFlair = "Life", strSprite = "CardsSprites:157_Wilderrun" },
	[158] = { nCardId = 158, nNumber = 158, strCategory = "Zones", strName = "Malgrave", nQualityID = 3, nTop = 5, nRight = 2, nBottom = 2, nLeft = 6, strFlair = "Fire", strSprite = "CardsSprites:158_Malgrave" },
	[159] = { nCardId = 159, nNumber = 159, strCategory = "Zones", strName = "Grimvault", nQualityID = 3, nTop = 5, nRight = 4, nBottom = 2, nLeft = 4, strFlair = "Fusion", strSprite = "CardsSprites:159_Grimvault" },
	[160] = { nCardId = 160, nNumber = 160, strCategory = "Zones", strName = "Crimson Badlands", nQualityID = 3, nTop = 4, nRight = 1, nBottom = 9, nLeft = 1, strFlair = "", strSprite = "CardsSprites:160_CrimsonBadlands" },
	[161] = { nCardId = 161, nNumber = 161, strCategory = "Zones", strName = "Northern Wastes", nQualityID = 3, nTop = 7, nRight = 1, nBottom = 5, nLeft = 2, strFlair = "Water", strSprite = "CardsSprites:161_NorthernWastes" },
	[162] = { nCardId = 162, nNumber = 162, strCategory = "Zones", strName = "Blighthaven", nQualityID = 3, nTop = 2, nRight = 8, nBottom = 3, nLeft = 2, strFlair = "Life", strSprite = "CardsSprites:162_Blighthaven" },
}

-- Table containing cards categorised by quality.
CardsData.tByQuality = {}

-- Table containing definitions for each opponent that can be challenged.
CardsData.karOpponents =
{
	{ nCreatureId = 21370, nLevel = 99, strType = "Exile", 		strRace = "Human", 		strName = "Deadeye Brightland",			nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 20018, nLevel = 99, strType = "Exile", 		strRace = "Aurin", 		strName = "Supervisor Wicksprout",		nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 19720, nLevel = 99, strType = "Exile", 		strRace = "Aurin", 		strName = "Sera Melfield",				nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 57071, nLevel = 99, strType = "Exile", 		strRace = "Human", 		strName = "Kit Brinny",					nStrength = 0,
		strBattleLine = "Ah'm just so excited, I think I might just wet mah britches! ...Uh oh.",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 33911, nLevel = 99, strType = "Exile", 		strRace = "Granok", 	strName = "Chef Theok",					nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "Whatever, I didn't like your ears anyway." },
	{ nCreatureId = 21863, nLevel = 99, strType = "Exile", 		strRace = "Human", 		strName = "Krag Studrok", 				nStrength = 0,
		strBattleLine = "Honey, are you ready for Krag Studrok to ROCK your world?!",
		strWinLine = "",
		strLossLine = "Whatever, I didn't like your ears anyway." },
	{ nCreatureId = 24142, nLevel = 99, strType = "Neutral", 	strRace = "Human", 		strName = "Bride Kamala",				nStrength = 0,
		strBattleLine = "Oh my! Kamala is so excited!",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 25413, nLevel = 99, strType = "Neutral", 	strRace = "Human", 		strName = "Young Migisi",				nStrength = 1,
		strBattleLine = "This is going to be tricky, you have to be trickier!",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 25026, nLevel = 99, strType = "Dominion", 	strRace = "Draken", 	strName = "Huntress Kezzia",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 53245, nLevel = 99, strType = "Exile", 		strRace = "Aurin", 		strName = "Queen Myala Everstar",		nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 24937, nLevel = 99, strType = "Exile", 		strRace = "Mordesh", 	strName = "Victor Lazarin",				nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 16715, nLevel = 99, strType = "Exile", 		strRace = "Granok", 	strName = "Sergeant Trogdan",			nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 26027, nLevel = 99, strType = "Neutral", 	strRace = "Protostar", 	strName = "Prime Executive",			nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 26138, nLevel = 99, strType = "Exile", 		strRace = "Protostar", 	strName = "Protostar Employee",			nStrength = 0,
		strBattleLine = "Play profitably.",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 26161, nLevel = 99, strType = "Neutral", 	strRace = "Pell", 		strName = "High Priest Rain-Caller",	nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 19754, nLevel = 99, strType = "Exile", 		strRace = "Granok", 	strName = "Brewmaster Grok",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 20027, nLevel = 99, strType = "Exile", 		strRace = "?", 			strName = "Grollo the Butcher",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 20052, nLevel = 99, strType = "Exile", 		strRace = "Ekose", 		strName = "Smoky Soka",					nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 32708, nLevel = 99, strType = "Exile", 		strRace = "Mordesh", 	strName = "Harrower Krimzon",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 34505, nLevel = 99, strType = "Exile", 		strRace = "Mordesh", 	strName = "Anthropologist Liev",		nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 23532, nLevel = 99, strType = "Neutral", 	strRace = "Ekose", 		strName = "Captain Milo",				nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 40636, nLevel = 99, strType = "Dominion", 	strRace = "Cassian", 	strName = "Malvolio Portius",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "Ohhh, not again." },
	{ nCreatureId = 40636, nLevel = 99, strType = "Exile", 		strRace = "Aurin", 		strName = "Melashi Soulclover",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "I am very, very upset right now." },
	{ nCreatureId = 37913, nLevel = 99, strType = "Exile", 		strRace = "Mordesh", 	strName = "Sergeant Dominik",			nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "You are quite capable in the ways of combat, %s. Good work." },
	{ nCreatureId = 41471, nLevel = 99, strType = "Dominion", 	strRace = "Mechari", 	strName = "Axis Pheydra",				nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 32857, nLevel = 99, strType = "Dominion", 	strRace = "Cassian", 	strName = "Emperor Myrcalus",			nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 11484, nLevel = 99, strType = "Dominion", 	strRace = "Chua", 		strName = "Mondo Zax",					nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 24418, nLevel = 99, strType = "Dominion", 	strRace = "Chua", 		strName = "Minion Togor",				nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 32852, nLevel = 99, strType = "Dominion", 	strRace = "Cassian", 	strName = "Varonia Cazalon",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 56913, nLevel = 99, strType = "Dominion", 	strRace = "Cassian", 	strName = "Lord Aluviel",				nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 52520, nLevel = 99, strType = "Dominion", 	strRace = "Mechari", 	strName = "Scientist Trinix",			nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 26081, nLevel = 99, strType = "Dominion", 	strRace = "Draken", 	strName = "Kevo",						nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 24158, nLevel = 99, strType = "Dominion", 	strRace = "Draken", 	strName = "Kezrek Warbringer",			nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 10399, nLevel = 99, strType = "Dominion", 	strRace = "Mechari", 	strName = "Agent Lex",					nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 25378, nLevel = 99, strType = "Dominion", 	strRace = "Chua", 		strName = "Researcher Zum",				nStrength = 1,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
	{ nCreatureId = 24208, nLevel = 99, strType = "Dominion", 	strRace = "Chua", 		strName = "Arachnologist Borango",		nStrength = 0,
		strBattleLine = "",
		strWinLine = "",
		strLossLine = "" },
}

-----------------------------------------------------------------------------------------------
-- CardsData functions.
-----------------------------------------------------------------------------------------------

-- Categorise cards by various parameters (such as quality) to facilitate easier picking later on (e.g. choosing a random epic card).
function CardsData.Categorise()
	for iIndex, tCard in pairs(CardsData.karCards) do
		if tCard.nQualityID then
			if not CardsData.tByQuality[tCard.nQualityID] then
				CardsData.tByQuality[tCard.nQualityID] = {}
			end
			table.insert(CardsData.tByQuality[tCard.nQualityID], tCard)
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Temporary debugging stuff
-----------------------------------------------------------------------------------------------
function CardsData.Print_r (t, indent, done)
	if type(t) == "table" then
		done = done or {}
		indent = indent or ''
		local nextIndent -- Storage for next indentation value
		for key, value in pairs (t) do
			if type (value) == "table" and not done [value] then
				nextIndent = nextIndent or
				(indent .. string.rep(' ',string.len(tostring (key))+2))
				-- Shortcut conditional allocation
				done [value] = true
				Print (indent .. "[" .. tostring (key) .. "] => Table {");
				Print  (nextIndent .. "{");
				CardsData.Print_r (value, nextIndent .. string.rep(' ',2), done)
				Print  (nextIndent .. "}");
			else
				Print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
			end
		end
	else
		Print  (t);
	end
end


-----------------------------------------------------------------------------------------------
-- GeminiPackages support.
-----------------------------------------------------------------------------------------------
if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["CardsData"] = CardsData
