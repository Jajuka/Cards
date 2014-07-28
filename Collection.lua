-----------------------------------------------------------------------------------------------
-- Client Lua Script for Collection
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local GeminiPackages = _G["GeminiPackages"]   
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]
local Card = _G["Saikou:CardsLibs"]["Card"]

-----------------------------------------------------------------------------------------------
-- CollectionDefinition
-----------------------------------------------------------------------------------------------
local Collection = {} 
Collection.__index = Collection

setmetatable(Collection, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Collection.new()
	local self = setmetatable({}, Collection)

	self.wndMain = Apollo.LoadForm("Cards.xml", "CollectionWindow", nil, self)
	assert(self.wndMain, "Failed to create collection window.")
	
	self.wndMain:Show(false, true)
	
	-- Initialise the categories.
	self.tCollection = {}
	self.tCategorised = {}
	self.arwndCategories  = {}
	self.nOpenToCardId = nil
	
	--for iIndex, tCard in pairs(karCards) do
	local wndCardList= self.wndMain:FindChild("CardList")
	wndCardList:DestroyChildren()
	
	self.wndMain:FindChild("ShowOwnedOnly"):Enable(false)

	self.nNextCardId = 1
	self.tmrInit = ApolloTimer.Create(0, true, "OnInitialiseTimer", self)		
	self.tmrInit:Start()
	
	return self
end

function Collection:Initialise( tCollection, nOpenToCardId  )
	assert(tCollection ~= nil, "Collection class requires a collection parameter to the constructor.")
	self.tCollection = tCollection
	self.nOpenToCardId = nOpenToCardId
end

function Collection:PopulateCategories()
	self:AddCategory("All", #CardsData.karCards, (self.strCategory == "All"))

	-- TEMP: This is a mess, need to see if there's a cleaner way to do this.
	local tSorted = {}
	for iIndex, tCategory in pairs(self.tCategorised) do
		table.insert(tSorted, tCategory.strCategory)
	end
	table.sort(tSorted)

	local tSortedFull = {}
	for iIndex, strCategory in pairs(tSorted) do
		table.insert(tSortedFull , self.tCategorised[strCategory])
	end

	for iIndex, tCategory in pairs(tSortedFull) do
		self:AddCategory(tCategory.strCategory, #tCategory.tCards, self.strCategory == tCategory.strCategory)
	end
end

function Collection:OnInitialiseTimer()
	for nIndex = 1, 3 do
		-- Create the next card.
		self.wndMain:FindChild("Loading"):FindChild("Progress"):SetText(string.format("Loading cards, %.0f%% complete", self.nNextCardId / #CardsData.karCards * 100))
		
		-- Handles gaps in the card list.
		if CardsData.karCards[self.nNextCardId] and CardsData.karCards[self.nNextCardId].nNumber then
			local wndItem, oCard = self:CreateCard(self.nNextCardId, true)	
			if not self.tCategorised[oCard.strCategory] then
				self.tCategorised[oCard.strCategory] = { ["strCategory"] = oCard.strCategory, ["tCards"] = {}, ["nOwned"] = nil, ["nUniqueOwned"] = nil }
			end
			table.insert(self.tCategorised[oCard.strCategory].tCards, { ["oCard"] = oCard, ["wndItem"] = wndItem } )
		end
		
		self.nNextCardId = self.nNextCardId + 1

		if self.nNextCardId > #CardsData.karCards then
			break
		end
	end
	if self.nNextCardId > #CardsData.karCards then
		if self.nOpenToCardId then
			self.strCategory = CardsData.karCards[self.nOpenToCardId].strCategory
		else
			self.strCategory = "All"
		end
		self:PopulateCategories()
		self.nNextCardId = 0
		self.tmrInit:Stop()
		self:CalculateOwned()
		self:PopulateCategory()
		self.nOpenToCardId = nil
		self.wndMain:FindChild("Loading"):Show(false, false)
		self.wndMain:FindChild("ShowOwnedOnly"):Enable(true)
	end
end

function Collection:CalculateOwned(strCategory)
	-- Determine how many we own in each category and overall.
	if strCategory then
		local tCategory = self.tCategorised[strCategory]
		tCategory.nUniqueOwned = 0
		tCategory.nOwned = 0
		for nIndex, tCard in pairs(tCategory.tCards) do
			if self.tCollection[tCard.oCard.nCardId] and self.tCollection[tCard.oCard.nCardId] > 0 then
				tCategory.nUniqueOwned = tCategory.nUniqueOwned + 1
				tCategory.nOwned = tCategory.nOwned + self.tCollection[tCard.oCard.nCardId]
			end
		end
		self:AddCategory(tCategory.strCategory, tCategory.nUniqueOwned / #tCategory.tCards)
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
		self:AddCategory("All", nAllOwned / #CardsData.karCards)
		self.wndMain:FindChild("OverallCompletionPercentage"):SetText(string.format("%.0f%%", nAllUniqueOwned / #CardsData.karCards * 100))
		self.wndMain:FindChild("UniqueCards"):SetText(nAllUniqueOwned .. " of " .. #CardsData.karCards)
		self.wndMain:FindChild("TotalCards"):SetText(nAllOwned)
	end
end

function Collection:SetCategory(wndItem)	
	self.wndSelectedCategory = wndItem
	self.strCategory = wndItem:GetData()
	if self.nNextCardId == 0 then
		self:PopulateCategory()
	end
end

function Collection:PopulateCategory(bNoRearrange)
	local wndCardList = self.wndMain:FindChild("CardList")
	local wndOpenToCard = nil
	
	local bShowOwnedOnly = self.wndMain:FindChild("ShowOwnedOnly"):IsChecked()
	
	for nCategoryIndex, tCategory in pairs(self.tCategorised) do
		for nCardIndex, tCard in pairs(tCategory.tCards) do
			if self.strCategory == "All" or tCategory.strCategory == self.strCategory then
				local bOwned = (self.tCollection[tCard.oCard.nCardId] and self.tCollection[tCard.oCard.nCardId] > 0)
				local bWasOwned = (self.tCollection[tCard.oCard.nCardId] and self.tCollection[tCard.oCard.nCardId] == 0)
				if bOwned then
					tCard.wndItem:SetOpacity(1)
					tCard.wndItem:FindChild("Name"):SetFont("CRB_HeaderSmall_O")
					tCard.wndItem:FindChild("NumberOwned"):SetText("x " .. self.tCollection[tCard.oCard.nCardId])
					tCard.wndItem:FindChild("NumberOwned"):SetTooltip("You own " .. self.tCollection[tCard.oCard.nCardId] .. " copies of this card.")
				else
					tCard.wndItem:SetOpacity(0.2)
					if bWasOwned then
						tCard.wndItem:FindChild("Name"):SetFont("CRB_HeaderSmall_O")
					else
						tCard.wndItem:FindChild("Name"):SetFont("CRB_AlienSmall")
					end
					tCard.wndItem:FindChild("NumberOwned"):SetText("")
					tCard.wndItem:FindChild("NumberOwned"):SetTooltip("")
				end
				tCard.oCard:SetOwned(bOwned)
				if bShowOwnedOnly then
					tCard.wndItem:Show(bOwned, true)
				else
					tCard.wndItem:Show(true, true)
				end
			else
				tCard.wndItem:Show(false, true)
			end
			if self.nOpenToCardId and self.nOpenToCardId == tCard.oCard.nCardId then
				wndOpenToCard = tCard.wndItem
			end
		end
	end
	
	if not bNoRearrange then
		wndCardList:ArrangeChildrenTiles(0)
		if self.nOpenToCardId and wndOpenToCard then
			wndCardList:EnsureChildVisible(wndOpenToCard)
		end
	end
end

function Collection:AddCategory(strCategory, fPercentCollected, bSelected)
	if self.arwndCategories[strCategory] then
		local wndItem = self.arwndCategories[strCategory]
		if wndItem then
			wndItem:FindChild("Progress"):SetText(string.format("%.0f%%", math.floor(fPercentCollected * 100)))
		end
	else
		local wndCategoryList = self.wndMain:FindChild("CategoryList")
		local wndItem = Apollo.LoadForm("Cards.xml", "CollectionCategoryListItem", wndCategoryList, self)
		self.arwndCategories[strCategory] = wndItem
		wndItem:FindChild("Text"):SetText(strCategory)
		wndItem:FindChild("Progress"):SetText(string.format("%.0f%%", math.floor(fPercentCollected * 100)))
		wndItem:SetData(strCategory)
		wndCategoryList:ArrangeChildrenVert(0)
		if bSelected then
			self.strCategory = strCategory
			self.wndSelectedCategory = wndItem
			wndItem:SetCheck(true)
		end
	end
end

function Collection:CreateCard(nCardId, bDeferLayout)
	local wndCardList = self.wndMain:FindChild("CardList")
	local wndItem = Apollo.LoadForm("Cards.xml", "CollectionCardListItem", wndCardList, self)
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

---------------------------------------------------------------------------------------------------
-- CollectionWindow Events
---------------------------------------------------------------------------------------------------

function Collection:OnCollectionCloseButton( wndHandler, wndControl, eMouseButton )
	self.wndMain:Destroy()
	self.wndMain = nil
end

function Collection:OnCollectionCategoryListItemCheck( wndHandler, wndControl, eMouseButton )
	self:SetCategory(wndControl)
end

function Collection:OnShowOwnedOnlyChecked( wndHandler, wndControl, eMouseButton )
	self:PopulateCategory()
end

function Collection:OnShowOwnedOnlyUnchecked( wndHandler, wndControl, eMouseButton )
	self:PopulateCategory()
end

if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["Collection"] = Collection
