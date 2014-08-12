-----------------------------------------------------------------------------------------------
-- Client Lua Script for Options
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]

-----------------------------------------------------------------------------------------------
-- Options Definition
-----------------------------------------------------------------------------------------------
local Options = {} 
Options.__index = Options

setmetatable(Options, {
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
function Options:Init()
	Apollo.RegisterAddon(self)
end

function Options.new( a )
	local self = setmetatable({}, Options)

	Apollo.RegisterPackage(Players, "Saikou:Cards:Options", {})
	
	-- Create timers.	
	self.wndMain = Apollo.LoadForm(CardsData.xmlDoc, "OptionsWindow", nil, self)
	if not self.wndMain then
		Print("Could not create options window.")
		return
	end

	self.wndMain:Show(false, true)

	return self
end

-----------------------------------------------------------------------------------------------
-- Options Functions
-----------------------------------------------------------------------------------------------
function Options:Initialise()
	self.wndMain:FindChild("SilentModeButton"):SetCheck(Options.tOptions.bSilent or false)
	self.wndMain:FindChild("FilterChallengesButton"):SetCheck(Options.tOptions.bNoChallenges or false)
	self.wndMain:FindChild("NoStatisticsButton"):SetCheck(Options.tOptions.bNoStatistics or false)
	self.wndMain:FindChild("NoCollectionButton"):SetCheck(Options.tOptions.bNoCollection or false)
end

function Options:Update()
	local bSilent = self.wndMain:FindChild("SilentModeButton"):IsChecked()
	self.wndMain:FindChild("FilterChallengesButton"):Enable(not bSilent)
	self.wndMain:FindChild("NoStatisticsButton"):Enable(not bSilent)
	self.wndMain:FindChild("NoCollectionButton"):Enable(not bSilent)
end

-----------------------------------------------------------------------------------------------
-- OptionsWindow Events
-----------------------------------------------------------------------------------------------
function Options:OnButtonCheck( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Options:OnButtonUncheck( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Options:OnOptionsAcceptButton( wndHandler, wndControl, eMouseButton )
	Options.tOptions.bSilent = self.wndMain:FindChild("SilentModeButton"):IsChecked()
	Options.tOptions.bNoChallenges = self.wndMain:FindChild("FilterChallengesButton"):IsChecked()
	Options.tOptions.bNoStatistics = self.wndMain:FindChild("NoStatisticsButton"):IsChecked()
	Options.tOptions.bNoCollection = self.wndMain:FindChild("NoCollectionButton"):IsChecked()

	self.wndMain:Show(false)
end

function Options:OnOptionsCancelButton( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
end


if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["Options"] = Options
