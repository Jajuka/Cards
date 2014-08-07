-----------------------------------------------------------------------------------------------
-- Client Lua Script for Cards
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- Cards Module Definition
-----------------------------------------------------------------------------------------------
local Cards = {} 
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]
local Card = _G["Saikou:CardsLibs"]["Card"]
local Statistics = _G["Saikou:CardsLibs"]["Statistics"]
local CardGamePlayer = _G["Saikou:CardsLibs"]["CardGamePlayer"]
local CardGame = _G["Saikou:CardsLibs"]["CardGame"]
local Collection = _G["Saikou:CardsLibs"]["Collection"]
local Deck = _G["Saikou:CardsLibs"]["Deck"]

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Cards:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	self.tLootQueue = {}
	self.tCollection = {}
	self.tDeck = {}
    return o
end

function Cards:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
function Cards:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Cards", {"Saikou:Cards_MiniButton", "", "CardsSprites:MiniButton"}) 
end

-----------------------------------------------------------------------------------------------
-- Cards OnLoad
-----------------------------------------------------------------------------------------------
function Cards:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Cards.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	Apollo.LoadSprites("CardsSprites.xml")
end

-----------------------------------------------------------------------------------------------
-- Cards OnDocLoaded
-----------------------------------------------------------------------------------------------
function Cards:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
		CardsData.xmlDoc = self.xmlDoc
		
	    self.wndMenu = Apollo.LoadForm(self.xmlDoc, "MenuWindow", nil, self)
		if self.wndMenu == nil then
			Apollo.AddAddonErrorText(self, "Could not load the menu window.")
			return
		end		
	    self.wndMenu:Show(false, true)
				
	    self.wndOpponent = Apollo.LoadForm(self.xmlDoc, "OpponentWindow", nil, self)
		if self.wndOpponent == nil then
			Apollo.AddAddonErrorText(self, "Could not load the opponent window.")
			return
		end		
	    self.wndOpponent:Show(false, true)
				
		self.wndStatistics = Apollo.LoadForm(CardsData.xmlDoc, "StatisticsWindow", nil, self)
		if not self.wndStatistics then
			Print("Could not create statistics window.")
			return
		end	
		self.wndStatistics:Show(false, true)
	
		-- Register handlers for events, slash commands and timer, etc.
		Apollo.RegisterSlashCommand("cards", "OnSlashCommand", self)
		--Apollo.RegisterSlashCommand("lootcard", "OnTestLootSlashCommand", self)
		--Apollo.RegisterSlashCommand("cardstest", "OnTestTargetSlashCommand", self)
		Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
		Apollo.RegisterEventHandler("Saikou:Cards_MiniButton", "OnSlashCommand", self)
		Apollo.RegisterEventHandler("Saikou:Cards_BattleStart", "OnBattleStart", self)
		Apollo.RegisterEventHandler("Saikou:Cards_BattleComplete", "OnBattleComplete", self)
			
		-- Register event handlers.
		Apollo.RegisterEventHandler("CombatLogDamage", "OnCombatLogDamage", self)
		
		-- Create timers.
        self.tmrLootCardAnimate = ApolloTimer.Create(0.01, true, "OnLootCardAnimateTimer", self)		

		-- Perform other initialisation.
		self.tStatistics = self.tStatistics or {}	-- Ensure this isn't null as the reference must be passed to the statistics singleton.
		Statistics.Initialise(self.tStatistics, self.tCollection, self)
		CardsData.Initialise()
		self:InitLootFrame()
		
	end
end

-----------------------------------------------------------------------------------------------
-- Cards Functions
-----------------------------------------------------------------------------------------------

-- on SlashCommand "/cards"
function Cards:OnSlashCommand( command, args )
	local bForceRegenerate = false
	if args == "reset" then
		bForceRegenerate = true
	end
	self:InitialiseDefaultCollection(bForceRegenerate)
	self.wndMenu:Invoke() -- show the window
end

-- on SlashCommand "/lootcard"
function Cards:OnTestLootSlashCommand( command, args )
	-- Loot a random number of random cards.	
	local nCards = math.random(1, 10)
	for iIndex = 1, nCards do
		local tCard = self:ChooseRandomQualityCard()
		if tCard then
			self:LootCard(tCard.nCardId)
		end
	end
end

-- on SlashCommand "/test"
function Cards:OnTestTargetSlashCommand()
end

function Cards:LootCard(nCardId)
	if self:AddCardToCollection(nCardId) then
		table.insert(self.tLootQueue, nCardId)
		self.tmrLootCardAnimate:Start()
		Statistics.AddCardFoundFromKill()	
	end
end


function Cards:OnCombatLogDamage(tEventArgs)
	if tEventArgs.bTargetKilled then
		local unitCaster = tEventArgs.unitCaster
		local unitTarget = tEventArgs.unitTarget
		-- Both unitCaster and unitTarget can be null rarely (fall damage deaths maybe?) so play safe.
		if unitCaster and unitCaster:IsThePlayer() and unitTarget and not unitTarget:IsThePlayer() then
			--Print("You killed " .. unitTarget:GetName())
			local nFactionID  = unitTarget:GetFaction()
			if math.random(1, 100) == 63 then
				local tCard = self:ChooseRandomQualityCard()
				if tCard then
					self:LootCard(tCard.nCardId)
				end
			end
		end
	end
end

function Cards:ChooseRandomQualityCard()
	local nRoll = math.random(1, 1000)
	local tList = nil
	if nRoll <= 300 then
		tList = CardsData.tCardsByQuality[1]
	elseif nRoll <= 700 then
		tList = CardsData.tCardsByQuality[2]
	elseif nRoll <= 900 then
		tList = CardsData.tCardsByQuality[3]
	elseif nRoll <= 970 then
		tList = CardsData.tCardsByQuality[4]
	elseif nRoll <= 990 then
		tList = CardsData.tCardsByQuality[5]
	elseif nRoll <= 998 then
		tList = CardsData.tCardsByQuality[6]
	else
		tList = CardsData.tCardsByQuality[7]
	end
	
	local tCard = tList[math.random(#tList)]
	return tCard
end

function Cards:InitialiseDefaultCollection( bForceRegenerate )
	if (not self.tCollection.bIsInitialised) or bForceRegenerate then
		local oPlayer = GameLib.GetPlayerUnit()
		-- Depending on what part of the loading sequence calls this, there may not be a player unit yet, so check first.
		if oPlayer then
			self.tCollection = {}
			self.tCollection.bIsInitialised = true
			self.tDeck = {}
			if bForceRegenerate then
				self.tStatistics = {}
				Statistics.Initialise(self.tStatistics, self.tCollection)
			end
		
			-- Set up some default cards (5 random critters, 3 creatures, the path the player has, the player's class and the race the character is playing).
			local kMinimumCritterCard = 72
			local kMaximumCritterCard = 79
			local kMinimumCreatureCard = 15
			local kMaximumCreatureCard = 71
		
			for iIndex = 1, 5 do
				self:AddCardToCollection(math.random(kMinimumCritterCard, kMaximumCritterCard))
			end
			for iIndex = 1, 3 do
				self:AddCardToCollection(math.random(kMinimumCreatureCard, kMaximumCreatureCard ))
			end
			
			local eRace = oPlayer:GetRaceId()
			local eFaction = oPlayer:GetFaction()
			local ePath = oPlayer:GetPlayerPathType()
			local eClass = oPlayer:GetClassId()
			
			-- Give the player a path card that matches their path.
			if ePath == PlayerPathLib.PlayerPathType_Explorer then
				self:AddCardToCollection(CardsData.knCardIdExplorer)
			elseif ePath == PlayerPathLib.PlayerPathType_Scientist then
				self:AddCardToCollection(CardsData.knCardIdScientist)
			elseif ePath == PlayerPathLib.PlayerPathType_Settler then
				self:AddCardToCollection(CardsData.knCardIdSettler)
			elseif ePath == PlayerPathLib.PlayerPathType_Soldier then
				self:AddCardToCollection(CardsData.knCardIdSoldier)
			end
			
			-- Give the player a race card that matches their race.
			if eRace == GameLib.CodeEnumRace.Human then
				if eFaction == Unit.CodeEnumFaction.DominionPlayer then
					self:AddCardToCollection(CardsData.knCardIdCassian)
				else
					self:AddCardToCollection(CardsData.knCardIdHuman)
				end
			elseif eRace == GameLib.CodeEnumRace.Aurin then
				self:AddCardToCollection(CardsData.knCardIdAurin)
			elseif eRace == GameLib.CodeEnumRace.Chua then
				self:AddCardToCollection(CardsData.knCardIdChua)
			elseif eRace == GameLib.CodeEnumRace.Draken then
				self:AddCardToCollection(CardsData.knCardIdDraken)
			elseif eRace == GameLib.CodeEnumRace.Granok then
				self:AddCardToCollection(CardsData.knCardIdGranok)
			elseif eRace == GameLib.CodeEnumRace.Mechari then
				self:AddCardToCollection(CardsData.knCardIdMechari)
			elseif eRace == GameLib.CodeEnumRace.Mordesh then
				self:AddCardToCollection(CardsData.knCardIdMordesh)
			end
			
			-- Give the player a class card that matches their class.
			if eClass == GameLib.CodeEnumClass.Engineer then
				self:AddCardToCollection(CardsData.knCardIdEngineer)
			elseif eClass == GameLib.CodeEnumClass.Esper then
				self:AddCardToCollection(CardsData.knCardIdEsper)
			elseif eClass == GameLib.CodeEnumClass.Medic then
				self:AddCardToCollection(CardsData.knCardIdMedic)
			elseif eClass == GameLib.CodeEnumClass.Spellslinger then
				self:AddCardToCollection(CardsData.knCardIdSpellslinger)
			elseif eClass == GameLib.CodeEnumClass.Stalker then
				self:AddCardToCollection(CardsData.knCardIdStalker)
			elseif eClass == GameLib.CodeEnumClass.Warrior then
				self:AddCardToCollection(CardsData.knCardIdWarrior)
			end
		end
	end
end

function Cards:InitLootFrame()
	-- Create the loot container, and hide it.
	self.wndLootWindow = Apollo.LoadForm(self.xmlDoc, "LootWindow", nil, self)
	if not self.wndLootWindow then
		Apollo.AddAddonErrorText(self, "Could not load the card loot window for some reason.")
	end
	self.wndLootWindow:Show(false, true)
end

function Cards:AddCardToCollection(nCardId)
	if self.tCollection[nCardId] then
		if self.tCollection[nCardId] < 9 then
			self.tCollection[nCardId] = self.tCollection[nCardId] + 1
			ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Loot, string.format("You gained another card #%03d, %s.", CardsData.karCards[nCardId].nNumber, CardsData.karCards[nCardId].strName), "")
		else
			-- Cannot add as already have 9 of the card.
			return false
		end
	else
		ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Loot, string.format("You gained card #%03d, %s.", CardsData.karCards[nCardId].nNumber, CardsData.karCards[nCardId].strName), "")
		self.tCollection[nCardId] = 1
	end
	if self.oCollection and self.oCollection.wndMain then
		self.oCollection:CalculateOwned()
		self.oCollection:PopulateCategory(true)
	end
	
	return true
end

function Cards:RemoveCardFromCollection(nCardId)
	if self.tCollection[nCardId] then
		if self.tCollection[nCardId] > 0 then
			self.tCollection[nCardId] = self.tCollection[nCardId] - 1
			ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Loot, string.format("You forfeited card #%03d, %s.", CardsData.karCards[nCardId].nNumber, CardsData.karCards[nCardId].strName), "")
		else
			-- Cannot remove as already have 0 of the card.
			return false
		end
	end
	
	if self.oCollection and self.oCollection.wndMain then
		self.oCollection:CalculateOwned()
		self.oCollection:PopulateCategory(true)
	end
end



-----------------------------------------------------------------------------------------------
-- MenuWindow Functions
-----------------------------------------------------------------------------------------------

function Cards:OnMenuWindowCloseButton()
	self.wndMenu:Close() -- hide the window
end

function Cards:OnMenuWindowHelpButton()
end

function Cards:OnMenuChallengeButton( wndHandler, wndControl, eMouseButton )
	self.wndMenu:Show(false)
	-- TODO: Implement hard opponent.
	self.wndOpponent:FindChild("Hard"):Enable(false)
	self.wndOpponent:FindChild("Hard"):SetOpacity(0.2)
	self.wndOpponent:Invoke()
end

function Cards:OnBattleStart( tArgs )
	-- Store the chosen deck.
	self.tDeck = tArgs
	
	self.oDeck.wndMain:Destroy()
	self.oDeck = nil
	
	if self.oGame then
		if self.oGame.wndMain then
			self.oGame.wndMain:Destroy()
		end
		self.oGame = nil
	end
	
	local oPlayer1 = CardGamePlayer:new()
	local oPlayer2 = CardGamePlayer:new()
	
	oPlayer1:SetUnit(GameLib.GetPlayerUnit())
	oPlayer1:SetDeck(self.tDeck)
	
	local tOpponent = CardsData.tOpponentsByDifficulty[self.nOpponentDifficulty][math.random(#CardsData.tOpponentsByDifficulty[self.nOpponentDifficulty])]
	
	oPlayer2:SetOpponent(tOpponent)
	oPlayer2:ChooseDeck(self.tDeck, self.nOpponentDifficulty)
	
	self.oGame = CardGame:new(oPlayer1, oPlayer2, self.tCollection)
	self.oGame:Initialise()
	self.oGame.wndMain:Invoke()
end

function Cards:OnBattleComplete( tArgs )
	if tArgs.strResult == "Win" then
		self:AddCardToCollection(tArgs.nCardId)
	elseif tArgs.strResult == "Lose" then
		self:RemoveCardFromCollection(tArgs.nCardId)
	end
end

function Cards:OnMenuCollectionButton( wndHandler, wndControl, eMouseButton )
	if self.oCollection and not self.oCollection.wndMain then
		self.oCollection = nil
	end
	if not self.oCollection then
		self.oCollection = Collection:new()
	end
	self.oCollection:Initialise(self.tCollection)
	self.oCollection.wndMain:Invoke()
end

function Cards:OnMenuStatisticsButton( wndHandler, wndControl, eMouseButton )
	Statistics.Populate(self.wndStatistics)
	self.wndMenu:Show(false)
	self.wndStatistics:Show(true)
end

function Cards:OnMenuTutorialButton( wndHandler, wndControl, eMouseButton )
end

-----------------------------------------------------------------------------------
-- Timer Functions
---------------------------------------------------------------------------------------------------

function Cards:OnLootCardAnimateTimer()
	if self.tAnimatedCard then
		local nClippedValue = math.mod(self.nLootCardAnimationValue, 100)
		local fLootCardAnimationSine = math.cos( nClippedValue / 100 * 6.28318530718)

		local nLeft = 35 - (math.abs(fLootCardAnimationSine) * 70 / 2)
		local nRight = nLeft + math.abs(fLootCardAnimationSine) * 70
		self.tAnimatedCard.wndCard:SetAnchorOffsets(nLeft, 0, nRight, 80)
		
		if fLootCardAnimationSine > 0 then
			self.tAnimatedCard.wndCard:FindChild("Image"):SetSprite(self.tAnimatedCard.strBack)
		else
			self.tAnimatedCard.wndCard:FindChild("Image"):SetSprite(self.tAnimatedCard.strFront)
		end
		
		if self.nLootCardAnimationValue < 1 then
			self.tAnimatedCard.wndCard:SetOpacity(1, 5)
			self.tAnimatedCard.wndCard:Show(true)
		end
		
		if self.nLootCardAnimationValue > 300 then
			self.tAnimatedCard.wndCard:SetOpacity(0, 5)
		end
		
		local fOSClock = os.clock()
		self.nLootCardAnimationValue = self.nLootCardAnimationValue + ((fOSClock - self.fLastOSClock) * 100)
		self.fLastOSClock = fOSClock
				
		if self.nLootCardAnimationValue > 350 then
			self.nLootCardAnimationValue = 0
			self.tAnimatedCard.wndCard:Show(false)
			self.tAnimatedCard.wndCard:Destroy()
			self.tAnimatedCard.wndCard = nil
			self.tAnimatedCard = nil
			self.wndLootWindow:Show(false)
		end
	else
		-- Is there anything in the queue?
		if #self.tLootQueue > 0 then
			local nCardId = self.tLootQueue[1]
			table.remove(self.tLootQueue, 1)
			
			-- Create a card within the loot container
			local wndContainer = self.wndLootWindow:FindChild("CardContainer")
			local oCard = Card.new(nCardId, wndContainer, false)
			
			self.tAnimatedCard = oCard
			self.nLootCardAnimationValue = 0

			self.fLastOSClock = os.clock()
					
			self.wndLootWindow:Show(true)
			self.tmrLootCardAnimate:Start()
			Sound.Play(Sound.PlayUICraftingSuccess)
		else
			self.tmrLootCardAnimate:Stop()
		end
	end
end

---------------------------------------------------------------------------------------------------
-- LootWindow Functions
---------------------------------------------------------------------------------------------------

function Cards:OnLootWindowCardClick( wndHandler, wndControl, eMouseButton )
	if eMouseButton == GameLib.CodeEnumInputMouse.Left then
		if self.oCollection and not self.oCollection.wndMain then
			self.oCollection = nil
		end
		if not self.oCollection then
			self.oCollection = Collection:new()
		end
		self.oCollection:Initialise(self.tCollection, self.tAnimatedCard.nCardId)
		self.oCollection.wndMain:Invoke()
	end
end

---------------------------------------------------------------------------------------------------
-- Load/Save Functions
---------------------------------------------------------------------------------------------------
function Cards:OnSave( eLevel )
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account then return end
	return
	{
		tCollection = self.tCollection,
		tDeck = self.tDeck,
		tStatistics = self.tStatistics 
	}
end

function Cards:OnRestore( eLevel, tSavedData )
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account then return end
	if tSavedData.tCollection then
		self.tCollection = tSavedData.tCollection 
	end
	if tSavedData.tDeck then
		self.tDeck = tSavedData.tDeck 
	end
	if tSavedData.tStatistics then
		self.tStatistics = tSavedData.tStatistics
	end
end

---------------------------------------------------------------------------------------------------
-- Deck Functions
---------------------------------------------------------------------------------------------------

function Cards:BuildDeck()
	if self.oDeck then
		if self.oDeck.wndMain then
			self.oDeck.wndMain:Destroy()
		end
		self.oDeck = nil
	end
	
	self.oDeck = Deck:new()
	self.oDeck:Initialise(self.tCollection, self.tDeck)
	self.oDeck.wndMain:Invoke()
end

---------------------------------------------------------------------------------------------------
-- OpponentWindow Functions
---------------------------------------------------------------------------------------------------

function Cards:OnOpponentEasyButtonClick( wndHandler, wndControl, eMouseButton )
	self.wndOpponent:Show(false)
	self.nOpponentDifficulty = 1
	self:BuildDeck()
end

function Cards:OnOpponentMediumButtonClick( wndHandler, wndControl, eMouseButton )
	self.wndOpponent:Show(false)
	self.nOpponentDifficulty = 2
	self:BuildDeck()
end

function Cards:OnOpponentHardButtonClick( wndHandler, wndControl, eMouseButton )
	self.wndOpponent:Show(false)
	self.nOpponentDifficulty = 3
	self:BuildDeck()
end

function Cards:OnOpponentWindowCloseButton( wndHandler, wndControl, eMouseButton )
	self.wndOpponent:Show(false)
end

---------------------------------------------------------------------------------------------------
-- StatisticsWindow Functions
---------------------------------------------------------------------------------------------------

function Cards:OnStatisticsWindowCloseButton( wndHandler, wndControl, eMouseButton )
	self.wndStatistics:Show(false)
end

-----------------------------------------------------------------------------------------------
-- Cards Instance
-----------------------------------------------------------------------------------------------
if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end

local CardsInst = Cards:new()
CardsInst:Init()

return Cards



