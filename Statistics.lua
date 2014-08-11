-----------------------------------------------------------------------------------------------
-- Client Lua Script for Statistics
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]

-----------------------------------------------------------------------------------------------
-- Statistics Definition
-----------------------------------------------------------------------------------------------
local Statistics = {} 
Statistics.__index = Statistics

setmetatable(Statistics, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
 
-----------------------------------------------------------------------------------------------
-- Statistics Functions
-----------------------------------------------------------------------------------------------
function Statistics.Initialise( tStatistics, tCollection )
	Statistics.tStatistics = tStatistics
	Statistics.tCollection = tCollection
end

function Statistics.Calculate()
	local nUniqueOpponentsEncountered = 0
	local nUniqueOpponentsDefeated = 0
	for _ in pairs(Statistics.tStatistics.arOpponentsEncountered or {}) do nUniqueOpponentsEncountered = nUniqueOpponentsEncountered + 1 end
	for _ in pairs(Statistics.tStatistics.arOpponentsDefeated or {}) do nUniqueOpponentsDefeated = nUniqueOpponentsDefeated + 1 end
	local arFlipsByYou = Statistics.tStatistics.arFlipsByYou or {}
	local arFlipsByOpponent = Statistics.tStatistics.arFlipsByOpponent or {}
	local arDifficultyGamesWon = Statistics.tStatistics.arDifficultyGamesWon or {}
	local arDifficultyGamesLost = Statistics.tStatistics.arDifficultyGamesLost or {}
	local arDifficultyGamesDrawn = Statistics.tStatistics.arDifficultyGamesDrawn or {}
	local strAverageWinningScore = nil
	local strAverageLosingScore = nil
	local strAverageOverallScore = nil
	if Statistics.tStatistics.fAverageWinScore then strAverageWinningScore = string.format("%.2f", Statistics.tStatistics.fAverageWinScore) end
	if Statistics.tStatistics.fAverageLossScore then strAverageLosingScore = string.format("%.2f", Statistics.tStatistics.fAverageLossScore) end
	if Statistics.tStatistics.fAverageOverallScore then strAverageOverallScore = string.format("%.2f", Statistics.tStatistics.fAverageOverallScore) end
	local strMostEncounteredOpponent = nil
	local nMostEncounteredOpponentId = nil
	local nMostEncounteredOpponentCount = 0
	for nId, nCount in pairs(Statistics.tStatistics.arOpponentsEncountered or {}) do
		if nCount > nMostEncounteredOpponentCount then
			nMostEncounteredOpponentId = nId
			nMostEncounteredOpponentCount = nCount
		end
	end
	if nMostEncounteredOpponentId then
		strMostEncounteredOpponent = string.format("%s (x%d)", CardsData.tOpponentsById[nMostEncounteredOpponentId].strName, nMostEncounteredOpponentCount)
	end
	local strMostDefeatedOpponent = nil
	local nMostDefeatedOpponentId = nil
	local nMostDefeatedOpponentCount = 0
	for nId, nCount in pairs(Statistics.tStatistics.arOpponentsDefeated or {}) do
		if nCount > nMostDefeatedOpponentCount then
			nMostDefeatedOpponentId = nId
			nMostDefeatedOpponentCount = nCount
		end
	end
	if nMostDefeatedOpponentId then
		strMostDefeatedOpponent = string.format("%s (x%d)", CardsData.tOpponentsById[nMostDefeatedOpponentId].strName, nMostDefeatedOpponentCount)
	end
	local strMostDefeatedByOpponent = nil
	local nMostDefeatedByOpponentId = nil
	local nMostDefeatedByOpponentCount = 0
	for nId, nCount in pairs(Statistics.tStatistics.arOpponentsDefeatedBy or {}) do
		if nCount > nMostDefeatedByOpponentCount then
			nMostDefeatedByOpponentId = nId
			nMostDefeatedByOpponentCount = nCount
		end
	end
	if nMostDefeatedByOpponentId then
		strMostDefeatedByOpponent = string.format("%s (x%d)", CardsData.tOpponentsById[nMostDefeatedByOpponentId].strName, nMostDefeatedByOpponentCount)
	end
	Statistics.AddCollectionUpdated()
	
	return
	{
		nCardsFoundFromKills = Statistics.tStatistics.nCardsFoundFromKills,
		nCardsWonInGames = Statistics.tStatistics.nCardsWonInGames,
		nCardsLostInGames = Statistics.tStatistics.nCardsLostInGames,
		nUniqueCardsOwned = Statistics.tStatistics.nUniqueCardsOwned,
		nMostUniqueCardsOwned = Statistics.tStatistics.nMostUniqueCardsOwned,
		arFlipsByYou = arFlipsByYou,
		arFlipsByOpponent = arFlipsByOpponent,
		arDifficultyGamesWon = arDifficultyGamesWon,
		arDifficultyGamesLost = arDifficultyGamesLost,
		arDifficultyGamesDrawn = arDifficultyGamesDrawn,
		nTotalGamesPlayed = Statistics.tStatistics.nTotalGamesPlayed,
		nTotalGamesWon = Statistics.tStatistics.nTotalGamesWon,
		nTotalGamesLost = Statistics.tStatistics.nTotalGamesLost,
		nTotalGamesDrawn = Statistics.tStatistics.nTotalGamesDrawn,
		nBestWinningScore = Statistics.tStatistics.nBestWinningScore,
		nWorstLosingScore = Statistics.tStatistics.nWorstLosingScore,
		strAverageWinningScore = strAverageWinningScore,
		strAverageLosingScore = strAverageLosingScore,
		strAverageOverallScore = strAverageOverallScore,
		nUniqueOpponentsEncountered = nUniqueOpponentsEncountered,
		nUniqueOpponentsDefeated = nUniqueOpponentsDefeated,
		strMostEncounteredOpponent = strMostEncounteredOpponent,
		strMostDefeatedOpponent = strMostDefeatedOpponent,
		strMostDefeatedByOpponent = strMostDefeatedByOpponent,
	}
end

function Statistics.Populate( wndMain, tCalculated, strPlayerName )
	if not tCalculated then tCalculated = Statistics.Calculate() end

	wndMain:FindChild("CardsFoundFromKills"):SetText(tCalculated.nCardsFoundFromKills or 0)
	wndMain:FindChild("CardsWonFromGames"):SetText(tCalculated.nCardsWonInGames or 0)
	wndMain:FindChild("CardsLostInGames"):SetText(tCalculated.nCardsLostInGames or 0)
	wndMain:FindChild("UniqueCardsOwned"):SetText(tCalculated.nUniqueCardsOwned or 0)
	wndMain:FindChild("MostUniqueCardsOwned"):SetText(tCalculated.nMostUniqueCardsOwned or 0)
	wndMain:FindChild("YouCardsFlipped"):SetText(tCalculated.arFlipsByYou[0] or 0)
	wndMain:FindChild("YouFlipped1"):SetText(tCalculated.arFlipsByYou[1] or 0)
	wndMain:FindChild("YouFlipped2"):SetText(tCalculated.arFlipsByYou[2] or 0)
	wndMain:FindChild("YouFlipped3"):SetText(tCalculated.arFlipsByYou[3] or 0)
	wndMain:FindChild("YouFlipped4"):SetText(tCalculated.arFlipsByYou[4] or 0)
	wndMain:FindChild("OpponentFlipped"):SetText(tCalculated.arFlipsByOpponent[0] or 0)
	wndMain:FindChild("OpponentFlipped1"):SetText(tCalculated.arFlipsByOpponent[1] or 0)
	wndMain:FindChild("OpponentFlipped2"):SetText(tCalculated.arFlipsByOpponent[2] or 0)
	wndMain:FindChild("OpponentFlipped3"):SetText(tCalculated.arFlipsByOpponent[3] or 0)
	wndMain:FindChild("OpponentFlipped4"):SetText(tCalculated.arFlipsByOpponent[4] or 0)
	wndMain:FindChild("EasyGamesWon"):SetText(tCalculated.arDifficultyGamesWon[1] or 0)
	wndMain:FindChild("EasyGamesLost"):SetText(tCalculated.arDifficultyGamesLost[1] or 0)
	wndMain:FindChild("EasyGamesDrawn"):SetText(tCalculated.arDifficultyGamesDrawn[1] or 0)
	wndMain:FindChild("MediumGamesWon"):SetText(tCalculated.arDifficultyGamesWon[2] or 0)
	wndMain:FindChild("MediumGamesLost"):SetText(tCalculated.arDifficultyGamesLost[2] or 0)
	wndMain:FindChild("MediumGamesDrawn"):SetText(tCalculated.arDifficultyGamesDrawn[2] or 0)
	wndMain:FindChild("HardGamesWon"):SetText(tCalculated.arDifficultyGamesWon[3] or 0)
	wndMain:FindChild("HardGamesLost"):SetText(tCalculated.arDifficultyGamesLost[3] or 0)
	wndMain:FindChild("HardGamesDrawn"):SetText(tCalculated.arDifficultyGamesDrawn[3] or 0)
	wndMain:FindChild("TotalGamesPlayed"):SetText(tCalculated.nTotalGamesPlayed or 0)
	wndMain:FindChild("TotalGamesWon"):SetText(tCalculated.nTotalGamesWon or 0)
	wndMain:FindChild("TotalGamesLost"):SetText(tCalculated.nTotalGamesLost or 0)
	wndMain:FindChild("TotalGamesDrawn"):SetText(tCalculated.nTotalGamesDrawn or 0)
	wndMain:FindChild("TotalGamesAbandoned"):SetText((tCalculated.nTotalGamesPlayed or 0) - ((tCalculated.nTotalGamesWon or 0) + (tCalculated.nTotalGamesLost or 0) + (tCalculated.nTotalGamesDrawn or 0)))
	wndMain:FindChild("BestWinningScore"):SetText(tCalculated.nBestWinningScore or "-")
	wndMain:FindChild("WorstLosingScore"):SetText(tCalculated.nWorstLosingScore or "-")
	wndMain:FindChild("AverageWinningScore"):SetText(tCalculated.strAverageWinningScore or "-")
	wndMain:FindChild("AverageLosingScore"):SetText(tCalculated.strAverageLosingScore or "-")
	wndMain:FindChild("AverageOverallScore"):SetText(tCalculated.strAverageOverallScore or "-")
	wndMain:FindChild("UniqueOpponentsEncountered"):SetText(string.format("%d of %d (%0.f%%)", tCalculated.nUniqueOpponentsEncountered, #CardsData.karOpponents, tCalculated.nUniqueOpponentsEncountered / #CardsData.karOpponents * 100))
	wndMain:FindChild("UniqueOpponentsDefeated"):SetText(string.format("%d of %d (%0.f%%)", tCalculated.nUniqueOpponentsDefeated, #CardsData.karOpponents, tCalculated.nUniqueOpponentsDefeated / #CardsData.karOpponents * 100))
	wndMain:FindChild("MostEncountered"):SetText(tCalculated.strMostEncounteredOpponent or "-")
	wndMain:FindChild("MostDefeated"):SetText(tCalculated.strMostDefeatedOpponent or "-")
	wndMain:FindChild("MostDefeatedBy"):SetText(tCalculated.strMostDefeatedByOpponent or "-")
	
	if strPlayerName then
		wndMain:FindChild("Title"):SetText("Cards Statistics for " .. strPlayerName)
	else
		wndMain:FindChild("Title"):SetText("Cards Statistics")
	end
end

function Statistics.AddGamePlayed( nDifficulty )
	assert(nDifficulty, "A difficulty must be provided.")
	Statistics.tStatistics.nTotalGamesPlayed = (Statistics.tStatistics.nTotalGamesPlayed or 0) + 1
	if not Statistics.tStatistics.arDifficultyGamesPlayed then Statistics.tStatistics.arDifficultyGamesPlayed = {} end
	Statistics.tStatistics.arDifficultyGamesPlayed[nDifficulty] = (Statistics.tStatistics.arDifficultyGamesPlayed[nDifficulty] or 0) + 1
end

function Statistics.AddGameWon( nDifficulty, nScore )
	assert(nDifficulty, "A difficulty must be provided.")
	assert(nScore, "A score must be provided.")
	Statistics.tStatistics.nTotalGamesWon = (Statistics.tStatistics.nTotalGamesWon or 0) + 1
	if not Statistics.tStatistics.arDifficultyGamesWon then Statistics.tStatistics.arDifficultyGamesWon = {} end
	Statistics.tStatistics.arDifficultyGamesWon[nDifficulty] = (Statistics.tStatistics.arDifficultyGamesWon[nDifficulty] or 0) + 1
	Statistics.AddScore(1, nScore)
end

function Statistics.AddGameLost( nDifficulty, nScore )
	assert(nDifficulty, "A difficulty must be provided.")
	assert(nScore, "A score must be provided.")
	Statistics.tStatistics.nTotalGamesLost = (Statistics.tStatistics.nTotalGamesLost or 0) + 1
	if not Statistics.tStatistics.arDifficultyGamesLost then Statistics.tStatistics.arDifficultyGamesLost = {} end
	Statistics.tStatistics.arDifficultyGamesLost[nDifficulty] = (Statistics.tStatistics.arDifficultyGamesLost[nDifficulty] or 0) + 1
	Statistics.AddScore(-1, nScore)
end

function Statistics.AddGameDrawn( nDifficulty )
	assert(nDifficulty, "A difficulty must be provided.")
	Statistics.tStatistics.nTotalGamesDrawn = (Statistics.tStatistics.nTotalGamesDrawn or 0) + 1
	if not Statistics.tStatistics.arDifficultyGamesDrawn then Statistics.tStatistics.arDifficultyGamesDrawn = {} end
	Statistics.tStatistics.arDifficultyGamesDrawn[nDifficulty] = (Statistics.tStatistics.arDifficultyGamesDrawn[nDifficulty] or 0) + 1
	Statistics.AddScore(0, 5)
end

function Statistics.AddScore( nOutcome, nScore )
	assert(nOutcome, "An outcome must be provided.")
	assert(nScore, "A score must be provided.")
	
	-- Adjust the average
	Statistics.tStatistics.nScoreCounter = (Statistics.tStatistics.nScoreCounter or 0) + 1
	Statistics.tStatistics.fAverageOverallScore = ((Statistics.tStatistics.fAverageOverallScore or 0) * (Statistics.tStatistics.nScoreCounter - 1) + nScore) / Statistics.tStatistics.nScoreCounter

	-- Store winning score if it's a better one than before
	if nOutcome > 0 then
		if nScore > (Statistics.tStatistics.nBestWinningScore or 0) then Statistics.tStatistics.nBestWinningScore = nScore end
		-- Adjust the average of wins
		Statistics.tStatistics.nScoreCounterWin = (Statistics.tStatistics.nScoreCounterWin or 0) + 1
		Statistics.tStatistics.fAverageWinScore = ((Statistics.tStatistics.fAverageWinScore or 0) * (Statistics.tStatistics.nScoreCounterWin - 1) + nScore) / Statistics.tStatistics.nScoreCounterWin 
	end
	
	-- Store losing score if it's a worse one than before
	if nOutcome < 0 then
		if nScore < (Statistics.tStatistics.nWorstLosingScore or 10) then Statistics.tStatistics.nWorstLosingScore = nScore end
		-- Adjust the average of losses
		Statistics.tStatistics.nScoreCounterLoss = (Statistics.tStatistics.nScoreCounterLoss or 0) + 1
		Statistics.tStatistics.fAverageLossScore = ((Statistics.tStatistics.fAverageLossScore or 0) * (Statistics.tStatistics.nScoreCounterLoss - 1) + nScore) / Statistics.tStatistics.nScoreCounterLoss
	end
end

function Statistics.AddCardFoundFromKill()
	Statistics.tStatistics.nCardsFoundFromKills = (Statistics.tStatistics.nCardsFoundFromKills or 0) + 1
	Statistics.AddCollectionUpdated()
end

function Statistics.AddCardWonInGame()
	Statistics.tStatistics.nCardsWonInGames = (Statistics.tStatistics.nCardsWonInGames or 0) + 1
	Statistics.AddCollectionUpdated()
end

function Statistics.AddCardLostInGame()
	Statistics.tStatistics.nCardsLostInGames = (Statistics.tStatistics.nCardsLostInGames or 0) + 1
	Statistics.AddCollectionUpdated()
end

function Statistics.AddCardsFlippedByPlayer( nCount )
	assert(nCount, "A count of how many cards were flipped must be provided.")
	assert(nCount >= 0 and nCount < 10, "The count of how many cards flipped must be between 0 and 9.")
	if not Statistics.tStatistics.arFlipsByYou then Statistics.tStatistics.arFlipsByYou = {} end
	Statistics.tStatistics.arFlipsByYou[nCount] = (Statistics.tStatistics.arFlipsByYou[nCount] or 0) + 1
end

function Statistics.AddCardsFlippedByOpponent( nCount )
	assert(nCount, "A count of how many cards were flipped must be provided.")
	assert(nCount >=0 and nCount < 10, "The count of how many cards flipped must be between 0 and 9.")
	if not Statistics.tStatistics.arFlipsByOpponent then Statistics.tStatistics.arFlipsByOpponent = {} end
	Statistics.tStatistics.arFlipsByOpponent[nCount] = (Statistics.tStatistics.arFlipsByOpponent[nCount] or 0) + 1
end

function Statistics.AddOpponentEncountered( nOpponentId )
	assert(nOpponentId, "An opponent must be provided.")
	assert(CardsData.tOpponentsById[nOpponentId], "The given opponent is invalid.")
	if not Statistics.tStatistics.arOpponentsEncountered then Statistics.tStatistics.arOpponentsEncountered = {} end
	Statistics.tStatistics.arOpponentsEncountered[nOpponentId] = (Statistics.tStatistics.arOpponentsEncountered[nOpponentId] or 0) + 1
end

function Statistics.AddOpponentDefeated( nOpponentId )
	assert(nOpponentId, "An opponent must be provided.")
	assert(CardsData.tOpponentsById[nOpponentId], "The given opponent is invalid.")
	if not Statistics.tStatistics.arOpponentsDefeated then Statistics.tStatistics.arOpponentsDefeated = {} end
	Statistics.tStatistics.arOpponentsDefeated[nOpponentId] = (Statistics.tStatistics.arOpponentsDefeated[nOpponentId] or 0) + 1
end

function Statistics.AddOpponentDefeatedBy( nOpponentId )
	assert(nOpponentId, "An opponent must be provided.")
	assert(CardsData.tOpponentsById[nOpponentId], "The given opponent is invalid.")
	if not Statistics.tStatistics.arOpponentsDefeatedBy then Statistics.tStatistics.arOpponentsDefeatedBy = {} end
	Statistics.tStatistics.arOpponentsDefeatedBy[nOpponentId] = (Statistics.tStatistics.arOpponentsDefeatedBy[nOpponentId] or 0) + 1
end

function Statistics.AddCollectionUpdated()
	local nUniqueOwned = 0
	for nIndex, nCard in pairs(Statistics.tCollection) do
		if type(nCard) == "number" and nCard > 0 then
			nUniqueOwned = nUniqueOwned + 1
		end
	end
	Statistics.tStatistics.nUniqueCardsOwned = nUniqueOwned 
	if nUniqueOwned > (Statistics.tStatistics.nMostUniqueCardsOwned or 0) then
		Statistics.tStatistics.nMostUniqueCardsOwned = nUniqueOwned
	end
end


if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["Statistics"] = Statistics
