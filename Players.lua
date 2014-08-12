-----------------------------------------------------------------------------------------------
-- Client Lua Script for Players
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local CardsData = _G["Saikou:CardsLibs"]["CardsData"]
local Options = _G["Saikou:CardsLibs"]["Options"]
local Statistics = _G["Saikou:CardsLibs"]["Statistics"]

-----------------------------------------------------------------------------------------------
-- Players Definition
-----------------------------------------------------------------------------------------------
local Players = {} 
Players.__index = Players

setmetatable(Players, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
Players.karClasses =
{
	[GameLib.CodeEnumClass.Engineer] 		= "Engineer",
	[GameLib.CodeEnumClass.Esper] 			= "Esper",
	[GameLib.CodeEnumClass.Medic] 			= "Medic",
	[GameLib.CodeEnumClass.Spellslinger] 	= "Spellslinger",
	[GameLib.CodeEnumClass.Stalker] 		= "Stalker",
	[GameLib.CodeEnumClass.Warrior] 		= "Warrior",
}
Players.karRaces =
{
	[GameLib.CodeEnumRace.Aurin] 			= "Aurin",
	[GameLib.CodeEnumRace.Chua] 			= "Chua",
	[GameLib.CodeEnumRace.Draken] 			= "Draken",
	[GameLib.CodeEnumRace.Granok] 			= "Granok",
	[GameLib.CodeEnumRace.Human] 			= -- Human is a special case, as I like to treat exile humans as "Humans" and dominion humans as "Cassians".
		{
			[Unit.CodeEnumFaction.DominionPlayer] 	= "Cassian",
			[Unit.CodeEnumFaction.ExilesPlayer] 	= "Human",
		},
	[GameLib.CodeEnumRace.Mechari] 			= "Mechari",
	[GameLib.CodeEnumRace.Mordesh] 			= "Mordesh",
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Players:Init()
	Apollo.RegisterAddon(self)
end

function Players.new( a )
	local self = setmetatable({}, Players)

	self.bListeningForPingPongResponses = false
	
	Apollo.RegisterPackage(Players, "Saikou:Cards:Players", {})
	
	-- Create timers.	
	self.tmrRefresh = ApolloTimer.Create(3, false, "OnRefreshTimerTick", self)

	self.wndMain = Apollo.LoadForm(CardsData.xmlDoc, "PlayersWindow", nil, self)
	if not self.wndMain then
		Print("Could not create players window.")
		return
	end

	self.wndMain:Show(false, true)
	self.wndMain:FindChild("Loading"):Show(true)
	
	return self
end

-----------------------------------------------------------------------------------------------
-- Players Functions
-----------------------------------------------------------------------------------------------
function Players:Initialise( tCollection, oChannel )
	self.tCollection = tCollection
	self.oChannel = oChannel
	self:BeginSearch()
end

function Players:OnRefreshTimerTick()
	self:EndSearch()
end

function Players:BeginSearch()
	if Options.tOptions.bSilent then
		return
	end
	
	self.wndMain:FindChild("Loading"):Show(true)
	self.bListeningForPingPongResponses = true
	
	self.wndMain:FindChild("FriendsOnlyButton"):Enable(false)
	self.wndMain:FindChild("GuildOnlyButton"):Enable(false)
	self.wndMain:FindChild("CirclesOnlyButton"):Enable(false)
	self.wndMain:FindChild("NameFilter"):Enable(false)
	self.wndMain:FindChild("Clear"):Enable(false)
	self.wndMain:FindChild("RefreshButton"):Enable(false)
	
	local wndContainer = self.wndMain:FindChild("List")
	wndContainer:DestroyChildren()
	self.oChannel:SendMessage( { strType = "Players", strCommand = "Ping" } )
	self.tmrRefresh:Start()
end

function Players:EndSearch()
	self.wndMain:FindChild("Loading"):Show(false)
	self.bListeningForPingPongResponses = false

	self.wndMain:FindChild("FriendsOnlyButton"):Enable(true)
	self.wndMain:FindChild("GuildOnlyButton"):Enable(true)
	self.wndMain:FindChild("CirclesOnlyButton"):Enable(false)
	self.wndMain:FindChild("NameFilter"):Enable(true)
	self.wndMain:FindChild("Clear"):Enable(true)
	self.wndMain:FindChild("RefreshButton"):Enable(true)
	
	self:Update()	
end

---------------------------------------------------------------------------------------------------
-- PlayersWindow Functions
---------------------------------------------------------------------------------------------------
function Players:OnCloseButton( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
end

function Players:OnRefreshButton( wndHandler, wndControl, eMouseButton )
	if Options.tOptions.bSilent then
		Sound.Play(107)
		return
	end
	self:BeginSearch()
end


function Players:Update()
	local strNameFilter = self.wndMain:FindChild("NameFilter"):GetText()
	local bGuildOnly = self.wndMain:FindChild("GuildOnlyButton"):IsChecked()
	local bFriendsOnly = self.wndMain:FindChild("FriendsOnlyButton"):IsChecked()
	local bCirclesOnly = self.wndMain:FindChild("CirclesOnlyButton"):IsChecked()

	-- Determine friends information.
	local tFriends = FriendshipLib.GetList()
	local tFriendsData = {}
	if tFriends then
		-- Convert the friends data into a more easily consumed format.
		for key, tFriend in pairs(tFriends) do
			tFriendsData[tFriend.strCharacterName] = tFriend
		end
	end

	-- Determine guild information.
	local strGuild = nil
	for key, guildCurr in pairs(GuildLib.GetGuilds()) do
		local eGuildType = guildCurr:GetType()
		if eGuildType == GuildLib.GuildType_Guild then
			strGuild = guildCurr:GetName()
		end
	end
	
	-- TODO: Determine circles information.
	
	local wndContainer = self.wndMain:FindChild("List")
	for nIndex, wndItem in pairs(wndContainer:GetChildren()) do
		local tData = wndItem:GetData()
		local bVisible = true
		
		-- Check the name matches the filter.
		if strNameFilter and strNameFilter ~= "" and tData.strName then
			if not string.match(tData.strName:upper(), strNameFilter:upper()) then
				bVisible = false
			end
		end
		
		-- Check if the player is a friend.
		if bVisible and tFriends then
			local tFriend = tFriendsData[tData.strName]
			if tFriend and tFriend.bIgnore == true then
				bVisible = false
			else
				if tFriend and (tFriend.bFriend == true or tFriend.bRival == true) then
					bVisible = true
				else
					bVisible = not bFriendsOnly
				end
			end
		end
		
		-- Check if the player is in our guild.
		if bVisible and strGuild and bGuildOnly then
			if tData.strGuild ~= strGuild then
				bVisible = false
			end
		end
		
		-- Check if the player is in one of our circles.
		if bVisible then
		end

		wndItem:Show(bVisible, true)		
	end
	wndContainer:ArrangeChildrenVert()
end

function Players:CreateListItem( tMessage )
	local wndContainer = self.wndMain:FindChild("List")
	local wndItem = Apollo.LoadForm(CardsData.xmlDoc, "PlayerListItem", wndContainer, self)
	wndItem:SetData(tMessage)
	wndItem:Show(false, true)
	wndItem:FindChild("Name"):SetText(tMessage.strName)
	wndItem:FindChild("Info"):SetText(string.format("Level %d %s %s", tMessage.nLevel, tMessage.strRace, tMessage.strClass))
	if tMessage.fCompletion then
		wndItem:FindChild("CompletionPercentage"):SetText(string.format("%.0f%%", math.floor(tMessage.fCompletion * 100)))
	end
	if (tMessage.bAllowChallenge) then
		wndItem:FindChild("Challenge"):Enable(true)
		wndItem:FindChild("Challenge"):FindChild("Icon"):SetBGColor("white")
	else
		wndItem:FindChild("Challenge"):Enable(false)
		wndItem:FindChild("Challenge"):FindChild("Icon"):SetBGColor("ff555555")
	end
	if (tMessage.bAllowStatistics) then
		wndItem:FindChild("Stats"):Enable(true)
		wndItem:FindChild("Stats"):FindChild("Icon"):SetBGColor("white")
	else
		wndItem:FindChild("Statistics"):Enable(false)
		wndItem:FindChild("Statistics"):FindChild("Icon"):SetBGColor("ff555555")
	end
	if (tMessage.bAllowCollection) then
		wndItem:FindChild("Collection"):Enable(true)
		wndItem:FindChild("Collection"):FindChild("Icon"):SetBGColor("white")
	else
		wndItem:FindChild("Collection"):Enable(false)
		wndItem:FindChild("Collection"):FindChild("Icon"):SetBGColor("ff555555")
	end
	--wndItem:FindChild("Collection"):Enable(false)
	--wndItem:FindChild("Collection"):FindChild("Icon"):SetBGColor("ff555555")
	
	local tFriends = FriendshipLib.GetList()
	local tFriendsData = {}
	if tFriends then
		-- Convert the friends data into a more easily consumed format.
		for key, tFriend in pairs(tFriends) do
			tFriendsData[tFriend.strCharacterName] = tFriend
		end
	end

	local bIsFriend = false
	local bIsGuild = false
	local bIsCircle = false
	
	if tFriendsData[tMessage.strName] then
		bIsFriend = true
	end
	
	if GameLib.GetPlayerUnit():GetGuildName() == tMessage.strGuild then
		bIsGuild = true
	end	
	
	if bIsFriend then
		wndItem:FindChild("Friend"):SetBGColor("white")
		wndItem:FindChild("Friend"):SetTooltip("This player is a friend.")
	else
		wndItem:FindChild("Friend"):SetBGColor("ff555555")
		wndItem:FindChild("Friend"):SetTooltip("This player is not on your friend list.")
	end
	if bIsGuild then
		wndItem:FindChild("Guild"):SetBGColor("white")
		wndItem:FindChild("Guild"):SetTooltip("This player is in your guild.")
	else
		wndItem:FindChild("Guild"):SetBGColor("ff555555")
		wndItem:FindChild("Guild"):SetTooltip("This player is not in your guild.")
	end
	if bIsCircle then
		wndItem:FindChild("Circle"):SetBGColor("white")
		wndItem:FindChild("Circle"):SetTooltip("This player in in one of your circles.")	-- TODO: Mention which.
	else
		wndItem:FindChild("Circle"):SetBGColor("ff555555")
		wndItem:FindChild("Circle"):SetTooltip("This player is not in any of your circles.")
	end
	return wndItem
end

function Players:OnFriendsOnlyChecked( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Players:OnFriendsOnlyUnchecked( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Players:OnGuildOnlyChecked( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Players:OnGuildOnlyUnchecked( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Players:OnCirclesOnlyChecked( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Players:OnCirclesOnlyUnchecked( wndHandler, wndControl, eMouseButton )
	self:Update()
end

function Players:OnNameFilterTextChanged( wndHandler, wndControl, strText )
	self:Update()
end

function Players:OnNameFilterClearButton( wndHandler, wndControl, eMouseButton )
	self.wndMain:FindChild("NameFilter"):SetText("")
	self:Update()
end



---------------------------------------------------------------------------------------------------
-- PlayerListItem Functions
---------------------------------------------------------------------------------------------------
function Players:OnPlayerChallengeButton( wndHandler, wndControl, eMouseButton )
	-- TODO: Challenge player.
end

function Players:OnPlayerWhisperButton( wndHandler, wndControl, eMouseButton )
	-- TODO: Support for non-default chat log addons.
	local tChatLog = Apollo.GetAddon("ChatLog")
	if tChatLog then
		local strPlayerName = "Luxenia"
		local wndEdit = tChatLog:HelperGetCurrentEditbox()
		local strOutput = String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), Apollo.GetString("ChatType_Tell"), strPlayerName)
		wndEdit:SetText(strOutput)
		wndEdit:SetFocus()
		wndEdit:SetSel(strOutput:len(), -1)
		tChatLog:OnInputChanged(nil, wndEdit, strOutput)
	else
		Print("Could not find ChatLog addon.")
	end
end

function Players:OnPlayerCollectionButton( wndHandler, wndControl, eMouseButton )
	if Options.tOptions.bSilent then
		Sound.Play(107)
		return
	end
	local tData = wndControl:GetParent():GetData()
	self.oChannel:SendPrivateMessage({ tData.strName }, { strType = "Players", strCommand = "RequestCollection" })
end

function Players:OnPlayerStatisticsButton( wndHandler, wndControl, eMouseButton )
	if Options.tOptions.bSilent then
		Sound.Play(107)
		return
	end
	local tData = wndControl:GetParent():GetData()
	self.oChannel:SendPrivateMessage({ tData.strName }, { strType = "Players", strCommand = "RequestStats" })
end



---------------------------------------------------------------------------------------------------
-- Channel Functions
---------------------------------------------------------------------------------------------------
function Players:OnChannelMessageReceived( oChannel, tMessage, strSender )
	if Options.tOptions.bSilent then
		return
	end

	--Print("Message received from " .. strSender)
	-- Ensure it's a valid message.
	if not tMessage or not tMessage.strCommand then
		return
	end

	--Print(tMessage.strCommand)
	
	-- TODO: Check options.
	-- TODO: Check if sender is on ignore.
	
	if tMessage.strCommand == "Ping" then
		-- TODO: Send a response (assuming requestor isn't on ignore list).
		self.oChannel:SendMessage(self:CreatePingPongResponse())
	elseif tMessage.strCommand == "Pong" and self.bListeningForPingPongResponses then
		-- Create a list item for the ping responder.
		self:CreateListItem(tMessage)
	elseif tMessage.strCommand == "RequestStats" and not Options.tOptions.bNoStatistics then
		-- Send a response with our statistics (assuming requestor isn't on ignore list).
		self.oChannel:SendPrivateMessage({ strSender }, { strType = "Players", strCommand = "ReceiveStats", tStatistics = Statistics.Calculate() })
	elseif tMessage.strCommand == "ReceiveStats" then
		-- Received someone's stats, so show the statistics window.
		if tMessage.tStatistics then
			Event_FireGenericEvent("Saikou:Cards_ShowPlayerStatistics", { tStatistics = tMessage.tStatistics, strName = strSender })
		end
	elseif tMessage.strCommand == "RequestCollection" and not Options.tOptions.bNoCollection then
		-- Send a response (assuming requestor isn't on ignore list).
		self.oChannel:SendPrivateMessage({ strSender }, { strType = "Players", strCommand = "ReceiveCollection", tCollection = self.tCollection })
	elseif tMessage.strCommand == "ReceiveCollection" then
		-- Received someone's collection, so show the collection window.
		if tMessage.tCollection then
			Event_FireGenericEvent("Saikou:Cards_ShowPlayerCollection", { tCollection = tMessage.tCollection, strName = strSender })
		end
	end
end


---------------------------------------------------------------------------------------------------
-- Helper Functions
---------------------------------------------------------------------------------------------------
function Players:CreatePingPongResponse()
	local oPlayer = GameLib.GetPlayerUnit()
	return
	{
		strType = "Players", 
		strCommand = "Pong",
		strName = oPlayer:GetName(),
		strGuild = oPlayer:GetGuildName(),
		strCircles = { },
		nLevel = oPlayer:GetLevel(),
		strRace = Players.RaceIdToString(oPlayer:GetRaceId(), oPlayer:GetFaction()),
		strClass = Players.ClassIdToString(oPlayer:GetClassId()),
		bAllowChallenge = not Options.tOptions.bNoChallenges and false,
		bAllowStatistics = not Options.tOptions.bNoStatistics,
		bAllowCollection = not Options.tOptions.bNoCollection,
		fCompletion = self:CalculateCollectionCompletion(),
	}
end

function Players:CalculateCollectionCompletion()
	local nUniqueOwned = 0
	for nIndex, tCard in pairs(CardsData.karCards) do
		if self.tCollection[tCard.nCardId] and self.tCollection[tCard.nCardId] > 0 then
			nUniqueOwned = nUniqueOwned + 1
		end
	end
	return nUniqueOwned / #CardsData.karCards
end

function Players.RaceIdToString( eRaceId, eFaction )
	if type(Players.karRaces[eRaceId]) == "string" then
		return Players.karRaces[eRaceId]
	else
		return Players.karRaces[eRaceId][eFaction]
	end
end

function Players.ClassIdToString( eClassId )
	return Players.karClasses[eClassId]
end



if _G["Saikou:CardsLibs"] == nil then
	_G["Saikou:CardsLibs"] = { }
end
_G["Saikou:CardsLibs"]["Players"] = Players
