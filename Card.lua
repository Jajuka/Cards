-----------------------------------------------------------------------------------------------
-- Client Lua Script for Card
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]

-----------------------------------------------------------------------------------------------
-- Card Definition
-----------------------------------------------------------------------------------------------
local Card = {} 
Card.__index = Card

setmetatable(Card, {
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
-- nCardId			The ID and key of the card in the karCards table. Note this can differ from the ID number of a card.
-- wndParent		The parent window the card should be created in, if a visual card is required.
-- bShowNumbers		If true, the card will display numbers, otherwise the numbers will be hidden. Has no effect if no parent window is specified.
-- bVisible			If true, the card is initially visible, otherwise it's initially hidden. Has no effect if no parent window is specified.
-- strGlowColour	Key to the karGlowColours table. If nil, the card won't have a glow. Has no effect if no parent window is specified.
-- luaCardOwner		The owner of the card window, if created. This is where events will get fired etc. Has no effect if no parent window is specified.
-----------------------------------------------------------------------------------------------
function Card.new(nCardId, wndParent, bShowNumbers, bVisible, strGlowColour, strFont, luaCardOwner)
	local self = setmetatable({}, Card)

	assert(nCardId > 0 and nCardId <= #CardsData.karCards, "Unexpected argument to Card.new(): Invalid nCardId specified.")
	
	local tCardData = CardsData.karCards[nCardId]
	
	self.strBack = CardsData.kstrCardBackSprite
	self.strFront = tCardData.strSprite
	self.strName = tCardData.strName
	self.strCategory = tCardData.strCategory
	self.nCardId = nCardId
	self.nNumber = tCardData.nNumber
	self.nTop = tCardData.nTop
	self.nBottom = tCardData.nBottom
	self.nLeft = tCardData.nLeft
	self.nRight = tCardData.nRight
	self.strFlair = ""
	self.nQualityID = tCardData.nQualityID
	self.bShowNumbers = bShowNumbers
	self.tmrFlip = nil
	
	if wndParent then
		local wndCard = Apollo.LoadForm(CardsData.xmlDoc, "CardWindow", wndParent, luaCardOwner)
		if not wndCard then
			Print("Could not create card.")
		end
		if bVisible then
			wndCard:Show(true, true)
		else
			wndCard:Show(false, true)
		end
		wndCard:FindChild("Image"):SetSprite(self.strFront)
		
		local wndLeft = wndCard:FindChild("NumberLeft")
		local wndRight = wndCard:FindChild("NumberRight")
		local wndTop = wndCard:FindChild("NumberTop")
		local wndBottom = wndCard:FindChild("NumberBottom")
		if self.bShowNumbers then
			wndLeft:SetText(self.nLeft)
			wndRight:SetText(self.nRight)
			wndTop:SetText(self.nTop)
			wndBottom:SetText(self.nBottom)
		end
		if strFont then
			wndLeft:SetFont(strFont)
			wndRight:SetFont(strFont)
			wndTop:SetFont(strFont)
			wndBottom:SetFont(strFont)
		end
		wndLeft:Show(bShowNumbers, true)
		wndRight:Show(bShowNumbers, true)
		wndTop:Show(bShowNumbers, true)
		wndBottom:Show(bShowNumbers, true)
		
		local wndGlow = wndCard:FindChild("Glow")
		if strGlowColour == nil then
			wndGlow:Show(false, true)
		else
			wndGlow:Show(true, true)
			wndGlow:SetBGColor(CardsData.karGlowColours[strGlowColour])
		end
		
		wndCard:SetData(self)
		self.wndCard = wndCard
	end

	return self
end

function Card:Destroy()
	if self.wndCard then
		self.wndCard:Destroy()
		self.wndCard = nil
	end
	if self.tmrFlip then
		self.tmrFlip:Stop()
		self.tmrFlip = nil
	end
end
 
-----------------------------------------------------------------------------------------------
-- Cards Functions
-----------------------------------------------------------------------------------------------
function Card:SetOwned(bOwned)
	local wndLeft = self.wndCard:FindChild("NumberLeft")
	local wndRight = self.wndCard:FindChild("NumberRight")
	local wndTop = self.wndCard:FindChild("NumberTop")
	local wndBottom = self.wndCard:FindChild("NumberBottom")
	
	if bOwned then
		self.wndCard:FindChild("Image"):SetSprite(self.strFront)
	else
		self.wndCard:FindChild("Image"):SetSprite(self.strBack)
	end
	
	wndLeft:Show(self.bShowNumbers and bOwned, true)
	wndRight:Show(self.bShowNumbers and bOwned, true)
	wndTop:Show(self.bShowNumbers and bOwned, true)
	wndBottom:Show(self.bShowNumbers and bOwned, true)
end

function Card:SetOwner(nSide)
	self.nSide = nSide
	
	self.wndCard:FindChild("NumberLeft"):Show(false, false)
	self.wndCard:FindChild("NumberRight"):Show(false, false)
	self.wndCard:FindChild("NumberTop"):Show(false, false)
	self.wndCard:FindChild("NumberBottom"):Show(false, false)

	if not self.bAnimating then
		self.nOffsetLeft, self.nOffsetTop, _, _ = self.wndCard:GetAnchorOffsets()
		self.nLootCardAnimationValue = 0
		self.fLastOSClock = os.clock()
		self.bAnimating = true

		self.tmrFlip = ApolloTimer.Create(0.01, true, "OnFlipCardAnimateTimer", self)
		self.tmrFlip:Start()
	end
end

function Card:OnFlipCardAnimateTimer()
	if not self.bAnimating then return end
	
	if self.nLootCardAnimationValue >= 100 then self.nLootCardAnimationValue = 100 end
	local nClippedValue = math.mod(self.nLootCardAnimationValue, 100)
	local fLootCardAnimationSine = math.cos( nClippedValue / 100 * 6.28318530718)

	local nLeft = 70 - (math.abs(fLootCardAnimationSine) * 140 / 2)
	local nRight = nLeft + math.abs(fLootCardAnimationSine) * 140
	self.wndCard:SetAnchorOffsets(self.nOffsetLeft + nLeft, self.nOffsetTop + 0, self.nOffsetLeft + nRight, self.nOffsetTop + 180)
	
	if fLootCardAnimationSine > 0 then
		self.wndCard:FindChild("Image"):SetSprite(self.strFront)
		if self.nSide then
			self.wndCard:FindChild("Glow"):Show(true, true)
		end
	else
		self.wndCard:FindChild("Image"):SetSprite(self.strBack)
		local strGlowColour = nil
		if self.nSide == 1 then
			strGlowColour = "Friendly"
		elseif self.nSide == 2 then
			strGlowColour = "Hostile"
		else
			-- No glow
		end
		self.wndCard:FindChild("Glow"):SetBGColor(CardsData.karGlowColours[strGlowColour])
		self.wndCard:FindChild("Glow"):Show(false, true)
	end
	
	if self.nLootCardAnimationValue < 1 then
		self.wndCard:Show(true)
	end
	
	if self.nLootCardAnimationValue >= 75 then
		self.wndCard:FindChild("NumberLeft"):Show(true, false)
		self.wndCard:FindChild("NumberRight"):Show(true, false)
		self.wndCard:FindChild("NumberTop"):Show(true, false)
		self.wndCard:FindChild("NumberBottom"):Show(true, false)
	end
	
	if self.nLootCardAnimationValue >= 100 then
		self.tmrFlip:Stop()
		self.tmrFlip = nil
		self.bAnimating = false
		self.nLootCardAnimationValue = 0
		self.wndCard:SetAnchorOffsets(self.nOffsetLeft, self.nOffsetTop, self.nOffsetLeft + 140, self.nOffsetTop + 180)
	end

	local fOSClock = os.clock()
	self.nLootCardAnimationValue = self.nLootCardAnimationValue + ((fOSClock - self.fLastOSClock) * 125)
	if self.nLootCardAnimationValue > 100 then self.nLootCardAnimationValue = 100 end
	self.fLastOSClock = fOSClock
			
end

-----------------------------------------------------------------------------------------------
-- GeminiPackages support.
-----------------------------------------------------------------------------------------------
if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["Card"] = Card
