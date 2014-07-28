-----------------------------------------------------------------------------------------------
-- Client Lua Script for Deck
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local GeminiPackages = _G["GeminiPackages"]   
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]
local Card = _G["Saikou:CardsLibs"]["Card"]

-----------------------------------------------------------------------------------------------
-- DeckDefinition
-----------------------------------------------------------------------------------------------
local Deck = {} 
Deck.__index = Deck

setmetatable(Deck, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Deck.new()
	local self = setmetatable({}, Deck)

	self.wndMain = Apollo.LoadForm(CardsData.xmlDoc, "DeckWindow", nil, self)
	assert(self.wndMain, "Failed to create deck window.")
	
	self.wndMain:Show(false, true)
	
	-- Initialise the categories.
	self.tCollection = {}
	self.tCategorised = {}
	self.arwndCategories  = {}
	self.tDeck = {}
	
	local wndCardList= self.wndMain:FindChild("CardList")
	wndCardList:DestroyChildren()
	
	self.nNextCardId = 1
	self.tmrInit = ApolloTimer.Create(0, true, "OnInitialiseTimer", self)		
	self.tmrInit:Start()
	
	return self
end

function Deck:Initialise( tCollection, tDeck )
	assert(tCollection ~= nil, "Deck class requires a collection parameter to the constructor.")
	assert(tDeck ~= nil, "Deck class requires a deck parameter to the constructor.")
	self.tCollection = tCollection
	self.tDeck = -- Copy rather than use the passed reference to allow cancellation.
	{
		tDeck[1],
		tDeck[2],
		tDeck[3],
		tDeck[4],
		tDeck[5],
	}
	
	self:PopulateDeck()
end

function Deck:PopulateCategories()
	self:AddCategory("All", (self.strCategory == "All"))

	-- TEMP: This is a mess, need to see if there's a cleaner way to do this.
	local tSorted = {}
	for iIndex, tCategory in pairs(self.tCategorised) do
		table.insert(tSorted, tCategory.strCategory)
	end
	table.sort(tSorted)

	local tSortedFull = {}
	for iIndex, strCategory in pairs(tSorted) do
		table.insert(tSortedFull, self.tCategorised[strCategory])
	end

	for iIndex, tCategory in pairs(tSortedFull) do
		self:AddCategory(tCategory.strCategory, self.strCategory == tCategory.strCategory)
	end
end

function Deck:OnInitialiseTimer()
	-- Create the next card.
	self.wndMain:FindChild("Loading"):FindChild("Progress"):SetText(string.format("Loading cards, %.0f%% complete", self.nNextCardId / #CardsData.karCards * 100))
	
	local bAdded = false
	repeat
		if CardsData.karCards[self.nNextCardId] and CardsData.karCards[self.nNextCardId].nNumber then
			if self.tCollection[self.nNextCardId] then
				local wndItem, oCard = self:CreateCard(self.nNextCardId, true)	
				if not self.tCategorised[oCard.strCategory] then
					self.tCategorised[oCard.strCategory] = { ["strCategory"] = oCard.strCategory, ["tCards"] = {}, ["nOwned"] = nil, ["nUniqueOwned"] = nil }
				end
				table.insert(self.tCategorised[oCard.strCategory].tCards, { ["oCard"] = oCard, ["wndItem"] = wndItem } )
				bAdded = true
			end
		end
		self.nNextCardId = self.nNextCardId + 1
	until bAdded or self.nNextCardId > #CardsData.karCards
	
	
	if self.nNextCardId > #CardsData.karCards then
		self.strCategory = "All"
		self:PopulateCategories()
		self.nNextCardId = 0
		self.tmrInit:Stop()
		self:CalculateOwned()
		self:PopulateCategory()
		self.wndMain:FindChild("Loading"):Show(false, false)
		self:DeckChanged()
	end
end

function Deck:CalculateOwned(strCategory)
	-- Determine how many we own in each category and overall.
	if strCategory then
		local tCategory = self.tCategorised[strCategory]
		assert(tCategory, "Could not find a matching category table for " .. strCategory)
		assert(tCategory, "Category table for " .. strCategory .. " contains no cards.")
		tCategory.nUniqueOwned = 0
		tCategory.nOwned = 0
		for nIndex, tCard in pairs(tCategory.tCards) do
			if self.tCollection[tCard.oCard.nCardId] and self.tCollection[tCard.oCard.nCardId] > 0 then
				tCategory.nUniqueOwned = tCategory.nUniqueOwned + 1
				tCategory.nOwned = tCategory.nOwned + self.tCollection[tCard.oCard.nCardId]
			end
		end
		self:AddCategory(tCategory.strCategory)
	else
		for nCategoryIndex, tCategory in pairs(self.tCategorised) do
			self:CalculateOwned(tCategory.strCategory)
		end
		
		-- Now do the "all" category.
		local nAllUniqueOwned = 0
		local nAllOwned = 0
		for nIndex, tCategory in pairs(self.tCategorised) do
			nAllUniqueOwned = nAllUniqueOwned + tCategory.nUniqueOwned
			nAllOwned = nAllOwned + tCategory.nOwned
		end
		self:AddCategory("All")
	end
end

function Deck:AddCategory(strCategory, bSelected)
	if self.arwndCategories[strCategory] then
		local wndItem = self.arwndCategories[strCategory]
		if wndItem then
			wndItem:FindChild("Progress"):SetText("")
		end
	else
		local wndCategoryList = self.wndMain:FindChild("CategoryList")
		local wndItem = Apollo.LoadForm(CardsData.xmlDoc, "CollectionCategoryListItem", wndCategoryList, self)
		self.arwndCategories[strCategory] = wndItem
		wndItem:FindChild("Text"):SetText(strCategory)
		wndItem:FindChild("Progress"):SetText("")
		wndItem:SetData(strCategory)
		wndCategoryList:ArrangeChildrenVert(0)
		if bSelected then
			self.strCategory = strCategory
			self.wndSelectedCategory = wndItem
			wndItem:SetCheck(true)
		end
	end
end

function Deck:SetCategory(wndItem)
	Print("SetCategory")
	self.wndSelectedCategory = wndItem
	self.strCategory = wndItem:GetData()
	if self.nNextCardId == 0 then
		self:PopulateCategory()
	end
end

function Deck:PopulateCategory(bNoRearrange)
	Print("PopulateCategory " .. self.strCategory)
	local wndCardList = self.wndMain:FindChild("CardList")
	
	local bShowOwnedOnly = true
	
	for nCategoryIndex, tCategory in pairs(self.tCategorised) do
		for nCardIndex, tCard in pairs(tCategory.tCards) do
			if self.strCategory == "All" or tCategory.strCategory == self.strCategory then
				local bOwned = (self.tCollection[tCard.oCard.nCardId] and self.tCollection[tCard.oCard.nCardId] > 0)
				local nInDeck = 0
				for nIndex = 1, 5 do
					if self.tDeck[nIndex] and self.tDeck[nIndex] == tCard.oCard.nCardId then
						nInDeck = nInDeck + 1
					end
				end
				if self.tCollection[tCard.oCard.nCardId] - nInDeck < 0 then
					-- Deck is invalid, so clear it and re-populate.
					self.tDeck = {}
					self:PopulateCategory(bNoRearrange)
					self:PopulateDeck()
					return
				end
				if self.tCollection[tCard.oCard.nCardId] - nInDeck == 0 then
					bOwned = false
				end
				if bOwned then
					tCard.wndItem:SetOpacity(1)
					tCard.wndItem:FindChild("Name"):SetFont("CRB_HeaderSmall_O")
					tCard.wndItem:FindChild("NumberOwned"):SetText("x " .. self.tCollection[tCard.oCard.nCardId] - nInDeck)
					tCard.wndItem:FindChild("NumberOwned"):SetTooltip("You own " .. self.tCollection[tCard.oCard.nCardId] - nInDeck.. " copies of this card.")
				else
					tCard.wndItem:SetOpacity(0.2)
					tCard.wndItem:FindChild("NumberOwned"):SetText("")
					tCard.wndItem:FindChild("NumberOwned"):SetTooltip("")
				end
				tCard.oCard:SetOwned(bOwned)
				--if bShowOwnedOnly then
					--tCard.wndItem:Show(bOwned, true)
				--else
				if self.tCollection[tCard.oCard.nCardId] and self.tCollection[tCard.oCard.nCardId] > 0 then
					tCard.wndItem:Show(true, true)
				end
				--end
			else
				tCard.wndItem:Show(false, true)
			end
		end
	end
	
	if not bNoRearrange then
		wndCardList:ArrangeChildrenTiles(0)
	end
end

function Deck:CreateCard(nCardId, bDeferLayout)
	local wndCardList = self.wndMain:FindChild("CardList")
	local wndItem = Apollo.LoadForm(CardsData.xmlDoc, "CollectionCardListItem", wndCardList, self)
	wndItem:Show(false, true)

	local wndCardContainer = wndItem:FindChild("CardContainer")
	local oCard = Card.new(nCardId, wndCardContainer, true, true)

	-- Set the properties of the item to those of the card.
	wndItem:FindChild("ID"):SetText(string.format("#%03d", oCard.nNumber))
	wndItem:FindChild("ID"):SetTooltip("Card number " .. string.format("%03d", oCard.nNumber))
	wndItem:FindChild("Name"):SetText(oCard.strName)
	wndItem:FindChild("Quality"):SetSprite(CardsData.karQuality[oCard.nQualityID].strSprite)
	wndItem:FindChild("Quality"):SetTooltip("This card is '" .. CardsData.karQuality[oCard.nQualityID].strName .. "' quality")
	wndItem:FindChild("Category"):SetText(oCard.strCategory)
	wndItem:FindChild("NumberOwned"):SetText("x?")
	
	if not bDeferLayout then
		wndCardList:ArrangeChildrenTiles(0)
	end
	
	return wndItem, oCard
end

function Deck:PopulateDeck()
	for nIndex = 1, 5 do
		local nCardId = self.tDeck[nIndex]
		-- If there's a valid card ID at the location.
		if nCardId then
			-- Check that the deck can actually contain this card.
			local bCanContain = true
			-- Simple check - are there cards in the collection?
			if self.tCollection[nCardId] > 0 then
				-- More in-depth check - does the collection contain enough cards to account for this one, and any in previous deck slots?
				local nUsedPreviouslyInDeck = 0
				for nPreviousIndex = 1, nIndex - 1 do
					if self.tDeck[nPreviousIndex] and self.tDeck[nPreviousIndex] == nCardId then
						nUsedPreviouslyInDeck = nUsedPreviouslyInDeck + 1
					end
				end
				if self.tCollection[nCardId] < nUsedPreviouslyInDeck + 1 then
					bCanContain = false
				end
			else
				bCanContain = false
			end
			if not bCanContain then
				self.tDeck[nIndex] = nil
			end
			
			if self.tDeck[nIndex] then
				local wndCardContainer = self.wndMain:FindChild("Card" .. nIndex)
				local oCard = Card.new(self.tDeck[nIndex], wndCardContainer, true, true, nil, nil, self)
				oCard.nDeckIndex = nIndex
			end
		end
	end
end

function Deck:AddCardToDeck( nCardId )
	for nIndex = 1, 5 do
		if not self.tDeck[nIndex] then
		
			-- Check that the deck can actually contain this card.
			local bCanContain = true
			-- Simple check - are there cards in the collection?
			if self.tCollection[nCardId] > 0 then
				-- More in-depth check - does the collection contain enough cards to account for this one, and any in other deck slots?
				local nUsedPreviouslyInDeck = 0
				for nPreviousIndex = 1, 5 do
					if self.tDeck[nPreviousIndex] and self.tDeck[nPreviousIndex] == nCardId then
						nUsedPreviouslyInDeck = nUsedPreviouslyInDeck + 1
					end
				end
				if self.tCollection[nCardId] < nUsedPreviouslyInDeck + 1 then
					bCanContain = false
				end
			else
				bCanContain = false
			end
			if not bCanContain then
				return
			end
				
			self.tDeck[nIndex] = nCardId
			local wndCardContainer = self.wndMain:FindChild("Card" .. nIndex)
			local oCard = Card.new(nCardId, wndCardContainer, true, true, nil, nil, self)
			oCard.nDeckIndex = nIndex
			Sound.Play(101)
			break
		end
	end
	self:PopulateCategory(true)
	self:DeckChanged()
end

function Deck:RemoveCardFromDeck( oCard )
	self.tDeck[oCard.nDeckIndex] = nil
	oCard.wndCard:Destroy()
	
	self:PopulateCategory(true)
	self:DeckChanged()
	Sound.Play(102)
end

function Deck:GetDeck()
	return self.tDeck
end

function Deck:DeckChanged()
	local nCardsInDeck = 0
	for nIndex = 1, 5 do
		if self.tDeck[nIndex] then
			nCardsInDeck = nCardsInDeck + 1
		end
	end
	if nCardsInDeck < 5 then
		self.wndMain:FindChild("Information"):SetText("You still need to choose " .. (5 - nCardsInDeck) .. " cards.")
		self.wndMain:FindChild("Accept"):Enable(false)
	else
		self.wndMain:FindChild("Information"):SetText("Your deck is ready, press the battle button to begin.")
		self.wndMain:FindChild("Accept"):Enable(true)
	end
end

---------------------------------------------------------------------------------------------------
-- DeckWindow Events
---------------------------------------------------------------------------------------------------

function Deck:OnDeckCloseButton( wndHandler, wndControl, eMouseButton )
	self.wndMain:Destroy()
	self.wndMain = nil
end

function Deck:OnCollectionCategoryListItemCheck( wndHandler, wndControl, eMouseButton )
	self:SetCategory(wndControl)
end

function Deck:OnCardClick( wndHandler, wndControl, eMouseButton )
	local oCard = wndControl:GetData()
	if oCard.nDeckIndex then
		-- Card clicked was in the deck.
		self:RemoveCardFromDeck(oCard)
	else
		-- Card clicked was in the list.
		self:AddCardToDeck(oCard.nCardId)
	end
end

function Deck:OnBattleButton()
	Event_FireGenericEvent("Saikou:Cards_BattleStart", self.tDeck) 
end

if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["Deck"] = Deck
