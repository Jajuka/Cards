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
	self.strBattleLine= tOpponent.strBattleLine
	self.strWinLine = tOpponent.strWinLine
	self.LossLine = tOpponent.LossLine 
end


function CardGamePlayer:ChooseDeck(tOpponentDeck, nDifficulty)
	-- Copy quality, except:
	-- 	10% chance for 1 lower
	--	10% chance for higher if difficulty is easy or
	--  20% chance for higher if difficulty is hard
	-- If higher, then
	--  75% chance for 1 tier higher
	--  20% chance for 2 tiers higher
	--	 5% chance for 3 tiers higher
	local arDeck = {}
	for nIndex = 1, 5 do
		local nComparisonCardId = tOpponentDeck[nIndex]
		local nQualityId = CardsData.karCards[nComparisonCardId].nQualityID
		local nDeviation = 0
		local nRandom = math.random(10)
		if nRandom == 1 then
			-- Lower quality
			nDeviation = -1
		elseif nRandom == 2 or (nRandom == 3 and nDifficulty == 1) then
			-- Higher quality
			nDeviation = 1
			nRandom = math.random(100)
			if nRandom <= 75 then
				nDeviation = 1
			elseif nRandom <= 95 then
				nDeviation = 2
			else
				nDeviation = 3
			end
		else
			-- Same quality
			nDeviation = 0
		end
		
		nQualityId = nQualityId + nDeviation
		
		if nQualityId < 1 then nQualityId = 1 end
		if nQualityId > 7 then nQualityId = 7 end	-- TODO: Not sure we really want amazing decks to end up playing against mostly artifacts, will see how it goes.
		
		-- Choose a random card of the selected quality
		local nCardId = CardsData.tByQuality[nQualityId][math.random(#CardsData.tByQuality[nQualityId])].nCardId
		arDeck[nIndex] = nCardId
	end
	self:SetDeck(arDeck)
end


function CardGamePlayer:DetermineMove( tBoard, arPlayerCards )
	-- tMove
	--	.nCardIndex
	--	.nRow
	--	.nColumn
	--	.nOwnScoreChange
	--	.nOpponentScoreChange
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
