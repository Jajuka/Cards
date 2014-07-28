-----------------------------------------------------------------------------------------------
-- Client Lua Script for CardGame
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]
local Card = _G["Saikou:CardsLibs"]["Card"]

-----------------------------------------------------------------------------------------------
-- CardGame Definition
-----------------------------------------------------------------------------------------------
local CardGame = {} 
CardGame.__index = CardGame

setmetatable(CardGame, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
CardGame.karGamePhases = 
{
	"Intro",
	"Player1Turn",
	"Player2Turn",
	"Player1Win",
	"Player2Win",
	"Stalemate",
}

CardGame.kDeckCardWidth = 95
CardGame.kDeckCardHeight = 115
CardGame.kDeckCardOverlapHeight = 113
CardGame.kDeckCardFlyoutWidth = 45

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function CardGame.new( a, oPlayer1, oPlayer2 )
	local self = setmetatable({}, CardGame)

	self.strPhase = nil
	self.oPlayer1 = oPlayer1
	self.oPlayer2 = oPlayer2
	self.nPlayer1Score = 5
	self.nPlayer2Score = 5
	
	-- Create timers.	
	self.tmrIntro = ApolloTimer.Create(3, true, "OnIntroCompleteTimer", self)		
	self.tmrOpponentPlayStart = ApolloTimer.Create(0.5, true, "OnOpponentPlayStart", self)
	
	self.tmrOpponentPlayStart:Stop()
		
	if not self:ValidatePlayers() then
		Print("Invalid player-states specified for a card game.")
		return
	end
	
	self.wndMain = Apollo.LoadForm("Cards.xml", "GameWindow", nil, self)
	if not self.wndMain then
		Print("Could not create game window.")
		return
	end

	self.wndMain:Show(false, true)
	
	self.wndOutcome = Apollo.LoadForm("Cards.xml", "OutcomeWindow", self.wndMain, self)
	if not self.wndOutcome then
		Print("Could not create outcome window.")
		return
	end

	self.wndOutcome:Show(false, true)
	
	return self
end
 
-----------------------------------------------------------------------------------------------
-- CardGame Functions
-----------------------------------------------------------------------------------------------
function CardGame:ValidatePlayers()
	if not self.oPlayer1 then
		Print("No player 1 specified.")
		return false
	end
	if not self.oPlayer2 then
		Print("No player 2 specified.")
		return false
	end
	if not self.oPlayer1:Validate() then
		Print("Player 1 is invalid.")
		return false
	end
	if not self.oPlayer2:Validate() then
		Print("Player 2 is invalid.")
		return false
	end
	
	return true
end

function CardGame:Initialise()
	self.nPlayer1TopOffset = 15
	self.nPlayer1LeftOffset = 15
	self.nPlayer2TopOffset = 15
	self.nPlayer2LeftOffset = 633
	self.nNumberOfCardsPlayed = 0
		
	if self.oPlayer1.oUnit then
		self.wndMain:FindChild("Player1Frame"):FindChild("Model"):SetCostume(self.oPlayer1.oUnit)
	else
		self.wndMain:FindChild("Player1Frame"):FindChild("Model"):SetCostumeToCreatureId(self.oPlayer1.nCreatureId)
	end
	if self.oPlayer2.oUnit then
		self.wndMain:FindChild("Player2Frame"):FindChild("Model"):SetCostume(self.oPlayer2.oUnit)
	else
		self.wndMain:FindChild("Player2Frame"):FindChild("Model"):SetCostumeToCreatureId(self.oPlayer2.nCreatureId)
	end
	self.wndMain:FindChild("Player1Frame"):FindChild("Name"):SetText(self.oPlayer1.strName)
	self.wndMain:FindChild("Player2Frame"):FindChild("Name"):SetText(self.oPlayer2.strName)
	self.wndMain:FindChild("Player1Frame"):FindChild("Speech"):FindChild("Text"):SetText(self.oPlayer1.strBattleLine)
	self.wndMain:FindChild("Player2Frame"):FindChild("Speech"):FindChild("Text"):SetText(self.oPlayer2.strBattleLine)
	
	-- Initialise a 2D array to represent the game board.
	self.tBoard = {}
	for iRow = 1, 3 do
	    self.tBoard[iRow] = {}
	    for iColumn = 1, 3 do
	        self.tBoard[iRow][iColumn] = { ["oCard"] = nil, ["strFlair"] = "", ["wndCell"] = self.wndMain:FindChild("Cell" .. (iRow - 1) * 3 + iColumn) }
	    end
	end
	
	-- Initialise the cells with some lookup information (this will make things easier later on)
	self.wndMain:FindChild("Cell1"):SetData( 
		{ 
			["nRow"] = 1,
			["nColumn"] = 1,
			["wndAbove"] = nil,
			["wndLeft"] = nil,
			["wndBelow"] = self.wndMain:FindChild("Cell4"),
			["wndRight"] = self.wndMain:FindChild("Cell2"),
		} )
	self.wndMain:FindChild("Cell2"):SetData( 
		{ 
			["nRow"] = 1,
			["nColumn"] = 2,
			["wndAbove"] = nil,
			["wndLeft"] = self.wndMain:FindChild("Cell1"),
			["wndBelow"] = self.wndMain:FindChild("Cell5"),
			["wndRight"] = self.wndMain:FindChild("Cell3"),
		} )
	self.wndMain:FindChild("Cell3"):SetData( 
		{ 
			["nRow"] = 1,
			["nColumn"] = 3,
			["wndAbove"] = nil,
			["wndLeft"] = self.wndMain:FindChild("Cell2"),
			["wndBelow"] = self.wndMain:FindChild("Cell6"),
			["wndRight"] = nil,
		} )
	self.wndMain:FindChild("Cell4"):SetData( 
		{ 
			["nRow"] = 2,
			["nColumn"] = 1,
			["wndAbove"] = self.wndMain:FindChild("Cell1"),
			["wndLeft"] = nil,
			["wndBelow"] = self.wndMain:FindChild("Cell7"),
			["wndRight"] = self.wndMain:FindChild("Cell5"),
		} )
	self.wndMain:FindChild("Cell5"):SetData( 
		{ 
			["nRow"] = 2,
			["nColumn"] = 2,
			["wndAbove"] = self.wndMain:FindChild("Cell2"),
			["wndLeft"] = self.wndMain:FindChild("Cell4"),
			["wndBelow"] = self.wndMain:FindChild("Cell8"),
			["wndRight"] = self.wndMain:FindChild("Cell6"),
		} )
	self.wndMain:FindChild("Cell6"):SetData( 
		{ 
			["nRow"] = 2,
			["nColumn"] = 3,
			["wndAbove"] = self.wndMain:FindChild("Cell3"),
			["wndLeft"] = self.wndMain:FindChild("Cell5"),
			["wndBelow"] = self.wndMain:FindChild("Cell9"),
			["wndRight"] = nil,
		} )
	self.wndMain:FindChild("Cell7"):SetData( 
		{ 
			["nRow"] = 3,
			["nColumn"] = 1,
			["wndAbove"] = self.wndMain:FindChild("Cell4"),
			["wndLeft"] = nil,
			["wndBelow"] = nil,
			["wndRight"] = self.wndMain:FindChild("Cell8"),
		} )
	self.wndMain:FindChild("Cell8"):SetData( 
		{ 
			["nRow"] = 3,
			["nColumn"] = 2,
			["wndAbove"] = self.wndMain:FindChild("Cell5"),
			["wndLeft"] = self.wndMain:FindChild("Cell7"),
			["wndBelow"] = nil,
			["wndRight"] = self.wndMain:FindChild("Cell9"),
		} )
	self.wndMain:FindChild("Cell9"):SetData( 
		{ 
			["nRow"] = 3,
			["nColumn"] = 3,
			["wndAbove"] = self.wndMain:FindChild("Cell6"),
			["wndLeft"] = self.wndMain:FindChild("Cell8"),
			["wndBelow"] = nil,
			["wndRight"] = nil,
		} )
	
	self:PopulateDecks()

	-- Hide the speech windows initially so they transition in.	
	self.wndMain:FindChild("Player1Frame"):FindChild("Speech"):Show(false, true)
	self.wndMain:FindChild("Player2Frame"):FindChild("Speech"):Show(false, true)
	self:SetPhase("Intro")
end


function CardGame:PopulateDecks()
	local wndContainer = self.wndMain:FindChild("Container")
	local wndPlayer1Hand = self.wndMain:FindChild("Player1Deck")
	local wndPlayer2Hand = self.wndMain:FindChild("Player2Deck")
	
	wndPlayer1Hand:DestroyChildren()
	wndPlayer2Hand:DestroyChildren()
	
	-- Create 5 cards in each hand.
	local arPlayer1Cards = {}
	arPlayer1Cards[1] = Card.new(self.oPlayer1.arCards[1], wndContainer, true, true, "Friendly", "CRB_HeaderSmall_O", self)
	arPlayer1Cards[2] = Card.new(self.oPlayer1.arCards[2], wndContainer, true, true, "Friendly", "CRB_HeaderSmall_O", self)
	arPlayer1Cards[3] = Card.new(self.oPlayer1.arCards[3], wndContainer, true, true, "Friendly", "CRB_HeaderSmall_O", self)
	arPlayer1Cards[4] = Card.new(self.oPlayer1.arCards[4], wndContainer, true, true, "Friendly", "CRB_HeaderSmall_O", self)
	arPlayer1Cards[5] = Card.new(self.oPlayer1.arCards[5], wndContainer, true, true, "Friendly", "CRB_HeaderSmall_O", self)

	local arPlayer2Cards = {}
	arPlayer2Cards[1] = Card.new(self.oPlayer2.arCards[1], wndContainer, true, true, "Hostile", "CRB_HeaderSmall_O", self)
	arPlayer2Cards[2] = Card.new(self.oPlayer2.arCards[2], wndContainer, true, true, "Hostile", "CRB_HeaderSmall_O", self)
	arPlayer2Cards[3] = Card.new(self.oPlayer2.arCards[3], wndContainer, true, true, "Hostile", "CRB_HeaderSmall_O", self)
	arPlayer2Cards[4] = Card.new(self.oPlayer2.arCards[4], wndContainer, true, true, "Hostile", "CRB_HeaderSmall_O", self)
	arPlayer2Cards[5] = Card.new(self.oPlayer2.arCards[5], wndContainer, true, true, "Hostile", "CRB_HeaderSmall_O", self)
	
	for nIndex = 1, 5 do
		local i = nIndex - 1
		arPlayer1Cards[nIndex].nIndex = nIndex
		arPlayer2Cards[nIndex].nIndex = nIndex
		arPlayer1Cards[nIndex].nSide = 1
		arPlayer2Cards[nIndex].nSide = 2
		arPlayer1Cards[nIndex].wndCard:Move(self.nPlayer1LeftOffset + 0, self.nPlayer1TopOffset + CardGame.kDeckCardOverlapHeight * i, CardGame.kDeckCardWidth, CardGame.kDeckCardHeight)
		arPlayer2Cards[nIndex].wndCard:Move(self.nPlayer2LeftOffset + CardGame.kDeckCardFlyoutWidth , self.nPlayer2TopOffset + CardGame.kDeckCardOverlapHeight * i, CardGame.kDeckCardWidth, CardGame.kDeckCardHeight)
		arPlayer1Cards[nIndex].wndCard:SetTooltip(arPlayer1Cards[nIndex].strName)
		arPlayer2Cards[nIndex].wndCard:SetTooltip(arPlayer2Cards[nIndex].strName)
	end
	
	self.arPlayer1Cards = arPlayer1Cards
	self.arPlayer2Cards = arPlayer2Cards
end

function CardGame:ShowIntro()
	--self.wndMain:FindChild("Player1Frame"):FindChild("Speech"):Show(true, false)
	--self.wndMain:FindChild("Player2Frame"):FindChild("Speech"):Show(true, false)
	
	self.tmrIntro:Start()
end

function CardGame:SetPhase(strPhase)
	self.strPhase = strPhase
	if self.strPhase == "Intro" then
		self.wndMain:FindChild("Player1DeckGlow"):SetBGColor("00ffffff")	-- 00f5bf03
		self.wndMain:FindChild("Player2DeckGlow"):SetBGColor("00ffffff")
		self.wndMain:FindChild("Player1DeckGlow"):SetOpacity(0, 0)
		self.wndMain:FindChild("Player2DeckGlow"):SetOpacity(0, 0)
		self:ShowIntro()
		self.wndMain:FindChild("Status"):SetText("Prepare for battle!")
		self.wndMain:FindChild("Status"):SetTextColor(ApolloColor.new("UI_WindowTitleYellow"))
		Sound.Play(166)	-- Challenge Begins (123 is a good alternative)
	elseif self.strPhase == "Player1Turn" then
		self.wndMain:FindChild("Player1DeckGlow"):SetBGColor("80ffffff")	-- 80f5bf03
		self.wndMain:FindChild("Player1DeckGlow"):SetOpacity(1, 2)
		self.wndMain:FindChild("Player2DeckGlow"):SetOpacity(0, 2)
		if self.oSelectedCard then
			self.wndMain:FindChild("Status"):SetText("Select a location to play the selected card, or choose another card")
		else
			self.wndMain:FindChild("Status"):SetText("Select a card to play")
		end
		self.wndMain:FindChild("Status"):SetTextColor(ApolloColor.new("DispositionFriendlyUnflagged"))
	elseif self.strPhase == "Player2Turn" then
		self.wndMain:FindChild("Player2DeckGlow"):SetBGColor("80ffffff")	-- 80f5bf03
		self.wndMain:FindChild("Player1DeckGlow"):SetOpacity(0, 2)
		self.wndMain:FindChild("Player2DeckGlow"):SetOpacity(1, 2)
		self.wndMain:FindChild("Status"):SetText("Your opponent is thinking...")
		self.wndMain:FindChild("Status"):SetTextColor(ApolloColor.new("DispositionHostile"))
		self.nOpponentTimerTicks = 0
		self.tmrOpponentPlayStart:Start()
	elseif self.strPhase == "Player1Win" then
		self.wndMain:FindChild("Player1DeckGlow"):SetOpacity(0, 0)
		self.wndMain:FindChild("Player2DeckGlow"):SetOpacity(0, 0)
		self.wndMain:FindChild("Status"):SetText("You win!")
		self.wndMain:FindChild("Status"):SetTextColor(ApolloColor.new("DispositionFriendlyUnflagged"))
		self:ShowOutcome()
	elseif self.strPhase == "Player2Win" then
		self.wndMain:FindChild("Player1DeckGlow"):SetOpacity(0, 0)
		self.wndMain:FindChild("Player2DeckGlow"):SetOpacity(0, 0)
		self.wndMain:FindChild("Status"):SetText("You lose!")
		self.wndMain:FindChild("Status"):SetTextColor(ApolloColor.new("DispositionHostile"))
		self:ShowOutcome()
	elseif self.strPhase == "Stalemate" then
		self.wndMain:FindChild("Player1DeckGlow"):SetOpacity(0, 0)
		self.wndMain:FindChild("Player2DeckGlow"):SetOpacity(0, 0)
		self.wndMain:FindChild("Status"):SetText("Draw!")
		self.wndMain:FindChild("Status"):SetTextColor(ApolloColor.new("UI_WindowTitleYellow"))
		self:ShowOutcome()
	end	
end

function CardGame:SetSelectedCard( oCard )
	assert(oCard, "A card must be specified for CardGame:SetSelectedCard.")
	
	if self.oSelectedCard and self.oSelectedCard == oCard then
		return
	end
	
	if self.oSelectedCard then
		-- Deselect the last selected card.
		local nTop = (self.oSelectedCard.nIndex - 1) * CardGame.kDeckCardOverlapHeight
		local nLeft = 0
		if self.oSelectedCard.nSide == 1 then
			nTop = nTop + self.nPlayer1TopOffset
			nLeft = nLeft + self.nPlayer1LeftOffset
		else
			nLeft = CardGame.kDeckCardFlyoutWidth
			nTop = nTop + self.nPlayer2TopOffset
			nLeft = nLeft + self.nPlayer2LeftOffset
		end
		local tLoc = WindowLocation.new({ fPoints = {0.0, 0.0, 0.0, 0.0}, nOffsets = { nLeft, nTop, nLeft + CardGame.kDeckCardWidth, nTop + CardGame.kDeckCardHeight }})
		self.oSelectedCard.wndCard:TransitionMove(tLoc, 0.2)
	end
	
	self.oSelectedCard = oCard
	Sound.Play(38)	-- Click
	
	local nTop = (oCard.nIndex - 1) * CardGame.kDeckCardOverlapHeight
	local nLeft = CardGame.kDeckCardFlyoutWidth
	if self.oSelectedCard.nSide == 1 then
		nTop = nTop + self.nPlayer1TopOffset
		nLeft = nLeft + self.nPlayer1LeftOffset
	else
		nLeft = 0
		nTop = nTop + self.nPlayer2TopOffset
		nLeft = nLeft + self.nPlayer2LeftOffset
	end
	local tLoc = WindowLocation.new({ fPoints = {0.0, 0.0, 0.0, 0.0}, nOffsets = { nLeft, nTop, nLeft + CardGame.kDeckCardWidth, nTop + CardGame.kDeckCardHeight}})
	self.oSelectedCard.wndCard:TransitionMove(tLoc, 0.2)
	self.oSelectedCard.wndCard:ToFront()
end

function CardGame:PlayCard(wndCell)
	-- Is the cell already occupied?
	if wndCell:GetData().oCard ~= nil then
		Sound.Play(Sound.PlayUICraftingCoordinateMiss)
		return
	end

	-- Move (and rescale) the card to the cell's location
	local tData = wndCell:GetData()
	
	local tLoc = WindowLocation.new({ fPoints = {0.0, 0.0, 0.0, 0.0}, nOffsets = { 180 + (tData.nColumn - 1) * 140, 15 + (tData.nRow - 1) * 180, 180 + (tData.nColumn) * 140, 15 + (tData.nRow) * 180}})
	self.oSelectedCard.wndCard:TransitionMove(tLoc, 0.2)
	
	-- Store the card in the window's data table and board array.
	tData.oCard = self.oSelectedCard
	tData.oCard.bPlayed = true
	
	self.tBoard[tData.nRow][tData.nColumn].oCard = tData.oCard
	self.tBoard[tData.nRow][tData.nColumn].wndCell = wndCell
	
	self.oSelectedCard = nil
	self.nNumberOfCardsPlayed = self.nNumberOfCardsPlayed + 1
	
	local nFlipped = 0
	
	-- Flip any adjacent cards which fail the numbers checks
	-- Is there a card above?
	local oCardAbove = (function() if tData.nRow > 1 then return self.tBoard[tData.nRow - 1][tData.nColumn].oCard else return nil end end)()
	if oCardAbove then
		-- Does the card belong to the opponent
		if oCardAbove.nSide ~= tData.oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardAbove.nBottom < tData.oCard.nTop then
				self:FlipCard(tData.nRow - 1, tData.nColumn)
				nFlipped = nFlipped + 1
			end
		end
	end
	-- Is there a card below?
	local oCardBelow = (function() if tData.nRow < 3 then return self.tBoard[tData.nRow + 1][tData.nColumn].oCard else return nil end end)()
	if oCardBelow then
		-- Does the card belong to the opponent
		if oCardBelow.nSide ~= tData.oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardBelow .nTop < tData.oCard.nBottom then
				self:FlipCard(tData.nRow + 1, tData.nColumn)
				nFlipped = nFlipped + 1
			end
		end
	end
	
	-- Is there a card left?
	local oCardLeft = (function() if tData.nColumn > 1 then return self.tBoard[tData.nRow][tData.nColumn - 1].oCard else return nil end end)()
	if oCardLeft then
		-- Does the card belong to the opponent
		if oCardLeft.nSide ~= tData.oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardLeft.nRight < tData.oCard.nLeft then
				self:FlipCard(tData.nRow, tData.nColumn - 1)
				nFlipped = nFlipped + 1
			end
		end
	end
	-- Is there a card right?
	local oCardRight = (function() if tData.nColumn < 3 then return self.tBoard[tData.nRow][tData.nColumn + 1].oCard else return nil end end)()
	if oCardRight then
		-- Does the card belong to the opponent
		if oCardRight.nSide ~= tData.oCard.nSide then
			-- Is the value lower than the card we placed?
			if oCardRight.nLeft < tData.oCard.nRight then
				self:FlipCard(tData.nRow, tData.nColumn + 1)
				nFlipped = nFlipped + 1
			end
		end
	end

	-- Play a sound if card(s) were flipped
	if nFlipped > 0 then
		Sound.Play(Sound.PlayUICraftingCoordinateHit)
	end
	
	-- Update the score
	self:UpdateScore()
	
	-- TODO: If it was a great move (2+ cards flipped), show some banter between players
	
	-- Check whether the game has ended, or set the phase to the next player's turn
	if self.nNumberOfCardsPlayed < 9 then
		-- Game can continue
		if self.strPhase ==	"Player1Turn" then
			self:SetPhase("Player2Turn")
		else
			self:SetPhase("Player1Turn")
		end
	else
		-- Game has finished
		if self.nPlayer1Score > self.nPlayer2Score then
			self:SetPhase("Player1Win")
		elseif self.nPlayer1Score < self.nPlayer2Score then
			self:SetPhase("Player2Win")
		else
			self:SetPhase("Stalemate")
		end
	end
end

function CardGame:FlipCard(nRow, nColumn)
	local tData = self.tBoard[nRow][nColumn]
	if tData.oCard.nSide == 1 then
		self.nPlayer1Score = self.nPlayer1Score - 1
		self.nPlayer2Score = self.nPlayer2Score + 1
		tData.oCard:SetOwner(2)
	else
		self.nPlayer1Score = self.nPlayer1Score + 1
		self.nPlayer2Score = self.nPlayer2Score - 1
		tData.oCard:SetOwner(1)
	end
end

function CardGame:UpdateScore()
	self.wndMain:FindChild("Player1Score"):SetText(self.nPlayer1Score)
	self.wndMain:FindChild("Player2Score"):SetText(self.nPlayer2Score)
end

function CardGame:ShowOutcome()
	local arLoserCards = nil
	
	-- TODO: Play a sound
	Sound.Play(216)
	
	if self.strPhase == "Player1Win" then
		self.wndOutcome:FindChild("Victory"):Show(true, true)
		self.wndOutcome:FindChild("Defeat"):Show(false, true)
		self.wndOutcome:FindChild("Stalemate"):Show(false, true)
		self.wndOutcome:FindChild("Prompt"):SetText("You have earned one of your opponents cards; select the one you wish to take.")
		self.wndOutcome:FindChild("Prompt2"):SetText("")
		arLoserCards = self.arPlayer2Cards
		self.wndOutcome:FindChild("Accept"):Enable(false)
	elseif self.strPhase == "Player2Win" then
		self.wndOutcome:FindChild("Victory"):Show(false, true)
		self.wndOutcome:FindChild("Defeat"):Show(true, true)
		self.wndOutcome:FindChild("Stalemate"):Show(false, true)
		self.wndOutcome:FindChild("Prompt"):SetText("Your opponent has earned one of your cards and is choosing which to take.")
		self.wndOutcome:FindChild("Prompt2"):SetText("")
		arLoserCards = self.arPlayer1Cards
		self.wndOutcome:FindChild("Accept"):Enable(false)
	else
		self.wndOutcome:FindChild("Victory"):Show(false, true)
		self.wndOutcome:FindChild("Defeat"):Show(false, true)
		self.wndOutcome:FindChild("Stalemate"):Show(true, true)
		self.wndOutcome:FindChild("Prompt"):SetText("The game ended in a draw, neither player may select a card.")
		self.wndOutcome:FindChild("Prompt2"):SetText("")
		self.wndOutcome:FindChild("Accept"):Enable(true)
	end
	
	if arLoserCards then
		self.arLoserCards = {}
		for nIndex = 1, 5 do
			local wndCardContainer = self.wndOutcome:FindChild("Card" .. nIndex)
			local oCard = Card.new(arLoserCards[nIndex].nCardId, wndCardContainer, true, true, nil, nil, self)
			oCard.bIsLoserSelect = true
			table.insert(self.arLoserCards, oCard)
		end
	end
	self.wndOutcome:Show(true, false)
	self.tmrOutcomeOpponentDelay = ApolloTimer.Create(2, false, "OnOutcomeOpponentDelayTimer", self)
	self.tmrOutcomeOpponentDelay:Start()
end

function CardGame:OnOutcomeOpponentDelayTimer()
	if self.strPhase == "Player2Win" then
		local oCard = self.arLoserCards[math.random(#self.arLoserCards)]
		self.oSelectedLoserCard = oCard
		self.oSelectedLoserCard:SetOwner(2)
		self.wndOutcome:FindChild("Accept"):Enable(true)
		self.wndOutcome:FindChild("Prompt2"):SetText(string.format("Your opponent has selected #%03d, %s", self.oSelectedLoserCard.nNumber, self.oSelectedLoserCard.strName))
		Sound.Play(Sound.PlayUICraftingCoordinateHit)
		Event_FireGenericEvent("Saikou:Cards_BattleComplete", { ["strResult"] = "Lose", ["nCardId"] = self.oSelectedLoserCard.nCardId } ) 
	end	
end

-----------------------------------------------------------------------------------------------
-- Card Events
-----------------------------------------------------------------------------------------------
function CardGame:OnCardClick( wndHandler, wndControl, eMouseButton )
	local oCard = wndControl:GetData()
	
	if oCard.bIsLoserSelect then
		if oCard.bAnimating then
			return
		end

		if self.oSelectedLoserCard then
			if self.oSelectedLoserCard.bAnimating then
				return
			end
			self.oSelectedLoserCard:SetOwner(nil)
		end
		self.oSelectedLoserCard = oCard
		self.oSelectedLoserCard:SetOwner(1)
		self.wndOutcome:FindChild("Accept"):Enable(true)
		self.wndOutcome:FindChild("Prompt2"):SetText(string.format("You have selected #%03d, %s", self.oSelectedLoserCard.nNumber, self.oSelectedLoserCard.strName))
		Sound.Play(Sound.PlayUICraftingCoordinateHit)
	else		
		-- If the clicked card has been played, do nothing
		if oCard.bPlayed == true then
			if self.oSelectedCard then
				Sound.Play(Sound.PlayUICraftingCoordinateMiss)	
			end
			return
		end
	
		if self.strPhase ==	"Player1Turn" then
			-- Determine which card was clicked.
			if oCard.nSide == 1 then
				-- Set the card as selected.
				self:SetSelectedCard(oCard)
			end
		end
	end
end


-----------------------------------------------------------------------------------------------
-- Timer Events
-----------------------------------------------------------------------------------------------
function CardGame:OnIntroCompleteTimer()
	self.tmrIntro:Stop()
	self.wndMain:FindChild("Player1Frame"):FindChild("Speech"):Show(false, false)
	self.wndMain:FindChild("Player2Frame"):FindChild("Speech"):Show(false, false)
	-- Randomly decide who goes first.
	local nPlayerTurn = math.random(2)
	if nPlayerTurn == 1 then
		self:SetPhase("Player1Turn")
	else
		self:SetPhase("Player2Turn")
	end
end

function CardGame:OnOpponentPlayStart()
	self.tmrOpponentPlayStart:Stop()
	self.nOpponentTimerTicks = self.nOpponentTimerTicks + 1
	
	local nRandom = math.random(1, self.nOpponentTimerTicks)
	
	if nRandom == 1 then
		self.tmrOpponentPlayStart:Start()
	elseif nRandom == 2 then
		local arUnplayedCards = {}
		for nIndex = 1, 5 do
			if not self.arPlayer2Cards[nIndex].bPlayed then
				table.insert(arUnplayedCards, self.arPlayer2Cards[nIndex])
			end
		end
		local nCard = math.random(#arUnplayedCards)
		self:SetSelectedCard(arUnplayedCards[nCard])
		self.tmrOpponentPlayStart:Start()
	else
		local nCardIndex, nRow, nColumn = self.oPlayer2:DetermineMove(self.tBoard, self.arPlayer2Cards)
		self:SetSelectedCard(self.arPlayer2Cards[nCardIndex])
		local wndCell = self.tBoard[nRow][nColumn].wndCell
		self:PlayCard(wndCell)
	end
end


-----------------------------------------------------------------------------------------------
-- GameBoard Events
-----------------------------------------------------------------------------------------------
function CardGame:OnBoardCellClick( wndHandler, wndControl, eMouseButton )
	if self.strPhase == "Player1Turn" and self.oSelectedCard then
		self:PlayCard(wndControl)
	end
	if self.strPhase == "Player2Turn" and self.oSelectedCard then
		self:PlayCard(wndControl)
	end
end

function CardGame:OnBoardCellMouseEnter( wndHandler, wndControl )
	if wndHandler == wndControl and (self.strPhase == "Player1Turn" and self.oSelectedCard) or (self.strPhase == "Player2Turn" and self.oSelectedCard) then
		wndControl:SetBGColor("ffffffff")
		wndControl:FindChild("Icon"):SetBGColor("ffffffff")
	end
end

function CardGame:OnBoardCellMouseExit( wndHandler, wndControl )
	if wndHandler == wndControl then
		wndControl:SetBGColor("ff808080")
		wndControl:FindChild("Icon"):SetBGColor("ff808080")
	end
end

---------------------------------------------------------------------------------------------------
-- OutcomeWindow Functions
---------------------------------------------------------------------------------------------------

function CardGame:OnOutcomeAcceptButton( wndHandler, wndControl, eMouseButton )
	self.wndOutcome:Destroy()
	self.wndOutcome = nil
	self.wndMain:Destroy()
	self.wndMain = nil
	
	if self.oSelectedLoserCard then
		-- Only fire the event for Player1 victory, as it will already have been fired for Player2 victory.
		if self.strPhase == "Player1Win" then
			Event_FireGenericEvent("Saikou:Cards_BattleComplete", { ["strResult"] = "Win", ["nCardId"] = self.oSelectedLoserCard.nCardId } ) 
		end
	end
end



if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["CardGame"] = CardGame
