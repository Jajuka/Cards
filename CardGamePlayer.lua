-----------------------------------------------------------------------------------------------
-- Client Lua Script for CardGamePlayerPlayer
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local GeminiPackages = _G["GeminiPackages"]   
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]

-----------------------------------------------------------------------------------------------
-- CardGamePlayer Definition
-----------------------------------------------------------------------------------------------
local CardGamePlayer = {} 
CardGamePlayer.__index = CardGamePlayer

setmetatable(CardGamePlayer, {
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
function CardGamePlayer.new( a )
	local self = setmetatable({}, CardGamePlayer)

	return self
end
 
-----------------------------------------------------------------------------------------------
-- CardGamePlayer Functions
-----------------------------------------------------------------------------------------------
function CardGamePlayer:Validate()
	if not self.arCards then
		Print("No deck is specified.")
		return false
	end
	if #self.arCards ~= 5 then
		Print("The specified deck does not contain 5 cards.")
		return false
	end
	if not self.oUnit and not self.nCreatureId then
		Print("No unit or creature is specified.")
		return false
	end
	if not self.strName then
		Print("No name specified.")
		return false
	end
	
	return true
end

function CardGamePlayer:SetDeck( tDeck )
	self.arCards =
	{
		tDeck[1],
		tDeck[2],
		tDeck[3],
		tDeck[4],
		tDeck[5],
	}
end

function CardGamePlayer:SetUnit( oUnit, strName )
	self.oUnit = oUnit
	self.nCreatureId = nil
	if strName then
		self.strName = strName
	else
		self.strName = oUnit:GetName()
	end
	self.strBattleLine= "[PH] Let's rock and/or roll!"
	self.strWinLine = "[PH] Suck it, cupcake."
	self.LossLine = "[PH] Son of a..."
end

function CardGamePlayer:SetCreatureId( nCreatureId, strName )
	self.oUnit = nil
	self.nCreatureId = nCreatureId
	if strName then
		self.strName = strName
	else
		-- TODO: Read name from the creature (haven't found a way to do so as yet).
		self.strName = nil	-- Will (deliberately) fail validation.
	end
end

function CardGamePlayer:SetOpponent( tOpponent )
	self.nCreatureId = tOpponent.nCreatureId
	self.strName = tOpponent.strName
	self.nDifficulty = tOpponent.nDifficulty
	self.nOpponentId = tOpponent.nOpponentId
end


function CardGamePlayer:ChooseDeck(tOpponentDeck, nDifficulty)
	--[[
	
	Difficulty 1 (easy)
	
	Plays best move with the caveat that it will occasionally disregard random possibilities, possibly missing good moves.
	
	50% same quality (capped at blue quality)
	20% lower quality
	25% higher quality (+1)
	 5% higher quality (+2)

	Difficulty 2 (medium)
	
	Plays best move with the caveat that it doesn't consider counter-plays and will happily leave low numbers exposed.

	50% same quality (capped at blue quality)
	10% lower quality
	25% higher quality (+1)
	10% higher quality (+2)
	 5% higher quality (+3)
	
	Difficulty 3 (hard)
	
	Plays best move taking into account a single counter-play by the opponent. If the open rule is not in play, assumes a perfect 99 card will be played by the opponent.

	50% same quality (capped at blue quality)
	10% lower quality
	25% higher quality (+1)
	10% higher quality (+2)
	 5% higher quality (+3)

	]]--
	
	-- TODO: Revamp for 3 difficulty levels.
	local arDeck = {}
	if nDifficulty == 1 then
		arDeck = self:BuildEasyDeck(tOpponentDeck)
	elseif nDifficulty == 2 then
		arDeck = self:BuildMediumDeck(tOpponentDeck)
	else
		arDeck = self:BuildHardDeck(tOpponentDeck)
	end
	self:SetDeck(arDeck)
end

function CardGamePlayer:BuildEasyDeck( tOpponentDeck )	
	-- Easy decks generally match the opponent's, with some deviation. Generally won't be higher than green quality, with the occasional blue, and the rare purple.

	-- 50% same (green)
	-- 22% -1 (white)
	-- 22% +1 (blue)
	-- 1% +2 (purple)
	
	local arDeck = {}
	for nIndex = 1, 5 do
		local nComparisonCardId = tOpponentDeck[nIndex]
		local nQualityId = CardsData.karCards[nComparisonCardId].nQualityID
		if nQualityId > 3 then nQualityId = 3 end
		local nDeviation = 0
		local nRandom = math.random(100)
		if nRandom <= 22 then
			-- Lower quality
			nDeviation = -1
		elseif nRandom <= 44 then
			-- Higher quality (+1)
			nDeviation = 1
		elseif nRandom == 100 then
			-- Higher quality (+2)
			nDeviation = 2
		else
			-- Same quality
			nDeviation = 0
		end
		
		nQualityId = nQualityId + nDeviation
		
		if nQualityId < 1 then nQualityId = 1 end
		if nQualityId > 7 then nQualityId = 7 end
		
		-- Choose a random card of the selected quality
		local nCardId = CardsData.tCardsByQuality[nQualityId][math.random(#CardsData.tCardsByQuality[nQualityId])].nCardId
		arDeck[nIndex] = nCardId
	end
	
	return arDeck
end

function CardGamePlayer:BuildMediumDeck( tOpponentDeck )	
	-- Medium decks generally match the opponent's, with some deviation. Generally won't be higher than blue quality, with the occasional purple, the rare orange, and the very rare magenta.

	-- 50% same (blue)
	-- 20% -1 (green)
	-- 20% +1 (purple)
	-- 4% +2 (orange)
	-- 1% +3 (pink)
	
	local arDeck = {}
	for nIndex = 1, 5 do
		local nComparisonCardId = tOpponentDeck[nIndex]
		local nQualityId = CardsData.karCards[nComparisonCardId].nQualityID
		if nQualityId > 4 then nQualityId = 4 end
		local nDeviation = 0
		local nRandom = math.random(100)
		if nRandom <= 20 then
			-- Lower quality
			nDeviation = -1
		elseif nRandom <= 40 then
			-- Higher quality (+1)
			nDeviation = 1
		elseif nRandom == 100 then
			-- Higher quality (+3)
			nDeviation = 3
		elseif nRandom >= 95 then
			-- Higher quality (+2)
			nDeviation = 2
		else
			-- Same quality
			nDeviation = 0
		end
		
		nQualityId = nQualityId + nDeviation
		
		if nQualityId < 1 then nQualityId = 1 end
		if nQualityId > 7 then nQualityId = 7 end
		
		-- Choose a random card of the selected quality
		local nCardId = CardsData.tCardsByQuality[nQualityId][math.random(#CardsData.tCardsByQuality[nQualityId])].nCardId
		arDeck[nIndex] = nCardId
	end
	
	return arDeck
end

function CardGamePlayer:BuildHardDeck( tOpponentDeck )	
	-- Hard decks generally match the opponent's, with some slight deviation.

	-- 59% same (blue)
	-- 20% -1 (green)
	-- 20% +1 (purple)
	-- 1% +2 (orange)
	
	local arDeck = {}
	for nIndex = 1, 5 do
		local nComparisonCardId = tOpponentDeck[nIndex]
		local nQualityId = CardsData.karCards[nComparisonCardId].nQualityID
		if nQualityId > 4 then nQualityId = 5 end
		local nDeviation = 0
		local nRandom = math.random(100)
		if nRandom <= 20 then
			-- Lower quality
			nDeviation = -1
		elseif nRandom <= 40 then
			-- Higher quality (+1)
			nDeviation = 1
		elseif nRandom == 100 then
			-- Higher quality (+3)
			nDeviation = 2
		else
			-- Same quality
			nDeviation = 0
		end
		
		nQualityId = nQualityId + nDeviation
		
		if nQualityId < 1 then nQualityId = 1 end
		if nQualityId > 7 then nQualityId = 7 end
		
		-- Choose a random card of the selected quality
		local nCardId = CardsData.tCardsByQuality[nQualityId][math.random(#CardsData.tCardsByQuality[nQualityId])].nCardId
		arDeck[nIndex] = nCardId
	end
	
	return arDeck
end



function CardGamePlayer:DetermineMove( tBoard, arPlayerCards )
	-- tMove
	--	.nCardIndex
	--	.nRow
	--	.nColumn
	--	.nOwnScoreChange
	--	.nOpponentScoreChange
	
	-- TODO: Act differently per difficulty.
	
	local tMoves = {}
	
	-- For each card
	for nCardIndex = 1, 5 do
		-- If card has not been played
		if not arPlayerCards[nCardIndex].bPlayed then
			-- Check each row/column
			for nRow = 1, 3 do
				for nColumn = 1, 3 do
					-- If not occupied, see how placing the card would affect the score
					if not tBoard[nRow][nColumn].oCard then
						local nOwnScoreChange, nOpponentScoreChange = self:SimulateMove(tBoard, arPlayerCards[nCardIndex], nRow, nColumn)
						table.insert(tMoves, { ["nCardIndex"] = nCardIndex, ["nRow"] = nRow, ["nColumn"] = nColumn, ["nOwnScoreChange"] = nOwnScoreChange, ["nOpponentScoreChange"] = nOpponentScoreChange})
					end
				end
			end
		end
	end
	
	-- If the difficulty is easy, disregard a random 10% of the moves (assuming there's at least a few valid moves).
	if self.nDifficulty == 1 and #tMoves > 3 then
		local nMovesToIgnore = math.floor(#tMoves / 4)
		for i = #tMoves, 2, -1 do -- backwards
		    local r = math.random(i) -- select a random number between 1 and i
		    tMoves[i], tMoves[r] = tMoves[r], tMoves[i] -- swap the randomly selected item to position i
		end  		
		for nIndex = 1, nMovesToIgnore do
			table.remove(tMoves)
		end
	end
	
	-- Loop through the moves found and see which we think is best.
	local tBestMove = nil
	for nIndex, tMove in pairs(tMoves) do
		-- Three options here: priritise own score increase, prioritise opponent loss, or prioritise delta. Realistically I don't believe
		-- there's any actual difference between the three.
		if tBestMove then
			if tMove.nOwnScoreChange > tBestMove.nOwnScoreChange then
				tBestMove = tMove
			end
		else
			-- If no previous best move, always choose this move as the best so far.
			tBestMove = tMove
		end
	end
	
	-- Now we have a 'best' move, look through all which score the same, and pick one of them randomly to reduce predictability.
	local tBestMoves = {}
	for nIndex, tMove in pairs(tMoves) do
		if tMove.nOwnScoreChange >= tBestMove.nOwnScoreChange then
			table.insert(tBestMoves, tMove)
		end
	end
	tBestMove = tBestMoves[math.random(#tBestMoves)]
	
	return tBestMove.nCardIndex, tBestMove.nRow, tBestMove.nColumn
end

function CardGamePlayer:SimulateMove(tBoard, oCard, nRow, nColumn)
	local nOwnScoreChange = 1	-- Score will always increase by 1 as a card is played.
	local nOpponentScoreChange = 0
	
	local oCardAbove = (function() if nRow > 1 then return tBoard[nRow - 1][nColumn].oCard else return nil end end)()
	if oCardAbove then
		-- Does the card belong to the opponent
		if oCardAbove.nSide ~= oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardAbove.nBottom < oCard.nTop then
				nOwnScoreChange = nOwnScoreChange + 1
				nOpponentScoreChange = nOpponentScoreChange - 1
			end
		end
	end
	-- Is there a card below?
	local oCardBelow = (function() if nRow < 3 then return tBoard[nRow + 1][nColumn].oCard else return nil end end)()
	if oCardBelow then
		-- Does the card belong to the opponent
		if oCardBelow.nSide ~= oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardBelow.nTop < oCard.nBottom then
				nOwnScoreChange = nOwnScoreChange + 1
				nOpponentScoreChange = nOpponentScoreChange - 1
			end
		end
	end
	
	-- Is there a card left?
	local oCardLeft = (function() if nColumn > 1 then return tBoard[nRow][nColumn - 1].oCard else return nil end end)()
	if oCardLeft then
		-- Does the card belong to the opponent
		if oCardLeft.nSide ~= oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardLeft.nRight < oCard.nLeft then
				nOwnScoreChange = nOwnScoreChange + 1
				nOpponentScoreChange = nOpponentScoreChange - 1
			end
		end
	end
	-- Is there a card right?
	local oCardRight = (function() if nColumn < 3 then return tBoard[nRow][nColumn + 1].oCard else return nil end end)()
	if oCardRight then
		-- Does the card belong to the opponent
		if oCardRight.nSide ~= oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardRight.nLeft < oCard.nRight then
				nOwnScoreChange = nOwnScoreChange + 1
				nOpponentScoreChange = nOpponentScoreChange - 1
			end
		end
	end
	
	return nOwnScoreChange, nOpponentScoreChange
end


if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["CardGamePlayer"] = CardGamePlayer
