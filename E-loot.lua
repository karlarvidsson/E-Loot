
 
 
 local BUTTON_HEIGHT = 20
 local BUTTON_OFFSET = 0
 local MWHEEL_SCROLLSIZE = BUTTON_HEIGHT * 4
 
	 
 local itemSelected = 0;
 
 ELoot = {};
 
 ELoot.RaidersWithELoot = {};
 local RaidersWithELoot =  ELoot.RaidersWithELoot;
 
 ELOOTSTRINGS = {};
 ELOOTPLAYERS = {};
 ELOOTPLAYERCUR = {};
 ELOOTITEMREQUESTEDBYPLAYER = { };

 
 ELoot.SessionID = "epiphany";
 local sessionID = ELoot.SessionID;
 ELoot.SessionHost = nil;
 local sessionHost = ELoot.SessionHost;
 
 local function isInTable(t, e)
	found = false;
	for i=1, #t do
		if (e == t[i]) then
			found = true;
		end
	end
	return found;
 end
 
 ELOOTREQUESTS_TOBECHECKED = { };

 
 
ELoot.elapsedTimeTotal = 0;
local elapsedTimeTotal = ELoot.elapsedTimeTotal;

 ELoot.elapsedTimeFrame = nil;
 local elapsedTimeFrame = ELoot.elapsedTimeFrame;

function ELootTimerOnUpdate(self, elapsed)
	elapsedTimeTotal = elapsedTimeTotal + elapsed
    if elapsedTimeTotal >= 2 then
        elapsedTimeTotal = 0
		
		if (#ELOOTREQUESTS_TOBECHECKED > 0) then
			
			for i=1, #ELOOTREQUESTS_TOBECHECKED do
				if (ELOOTREQUESTS_TOBECHECKED[i]) then
					local author = ELOOTREQUESTS_TOBECHECKED[i][1];
					local itemRequestIndex = ELOOTREQUESTS_TOBECHECKED[i][2];
					local ilink = ELOOTREQUESTS_TOBECHECKED[i][3];

					local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ilink);

					if ( not ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] and sType and (sType == "Armor" or sType == "Weapon")) then

						table.insert(ELOOTPLAYERS[itemRequestIndex], author);
						table.insert(ELOOTPLAYERCUR[itemRequestIndex], ilink);
						ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] = true;
						ELoot:ForwardRequestToSessionClients(itemRequestIndex, author, ilink);
						ELootPlayersScrollFrame_Update();
						local reply = "Loot request registered: " .. ELOOTSTRINGS[itemRequestIndex] .. " for " .. author;
						SendChatMessage(reply, "WHISPER", nil, author);
						ELOOTREQUESTS_TOBECHECKED[i] = false;
					elseif (ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author]) then
						ELOOTREQUESTS_TOBECHECKED[i] = false;
					end
				end
			end
			
			local requests_empty = true;
			for i=1, #ELOOTREQUESTS_TOBECHECKED do
				if (ELOOTREQUESTS_TOBECHECKED) then
					requests_empty = false;
				end
			end
			ELOOTREQUESTS_TOBECHECKED = { };
			
		end
		
    end
end


 
 
 function ELoot:HASELOOTRSPN_HANDLER(prefix, message, distribution, sender)
	local sID = "";
	for word in string.gmatch(message, "%a+:(%a+)|") do 
		sID = word;
	end
	if (sID == sessionID) then
		local sendstring = "sessionid:"..sessionID.."|";
		if (not isInTable(RaidersWithELoot, sender)) then
			table.insert(RaidersWithELoot, sender);
		end
		ELoot_UpdateUsers();
	end
 end
 function ELoot:HASELOOTRQST_HANDLER(prefix, message, distribution, sender)
	local sID = "";
	for word in string.gmatch(message, "%a+:(%a+)|") do 
		sID = word;
	end
	if (sID == sessionID) then
		local sendstring = "sessionid:"..sessionID.."|";
		if (UnitIsConnected(sender)) then
			ELoot:SendCommMessage("HASELOOTRSPN", sendstring, "WHISPER", sender);
			if (not isInTable(RaidersWithELoot, sender) and UnitName("player") ~= sender) then
				ELoot:AskRaiderForELoot(sender);
			end
		end
	end
 end
 
  function ELoot:ELOOTSSNSTART_HANDLER(prefix, message, distribution, sender)

	local ssnhost = string.match(message, "sessionHost:(%a+)|");
	if (sessionHost == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("E-Loot: No current sessionHost, accepting new host from " .. sender .. ".");
		sessionHost = ssnhost;
		
		for word in string.gmatch(message, "elootstring:(\124.-\124h\124r)|") do
			table.insert(ELOOTSTRINGS, word);
		end
		for i=1, #ELOOTSTRINGS do
			local t1 = {};
			table.insert(ELOOTPLAYERS, t1);
			local t2 = {};
			table.insert(ELOOTPLAYERCUR, t2);
			local t3 = {};
			table.insert(ELOOTITEMREQUESTEDBYPLAYER, t3);
		
		end
		ELootItemsScrollFrame_Update();
	else
		DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Current sessionHost is " ..sessionHost.. ", ignoring session start request from " .. sender ..".");
	end
	
 end
 
 function ELoot:ELOOTFWDREQ_HANDLER(prefix, message, distribution, sender)

	local ssnhost = string.match(message, "sessionHost:(%a+)|");
	
	if (sessionHost == nil) then
		-- ignoring forward
	elseif (sessionHost == ssnhost) then
		-- the sendstring looks like this: sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|itemRequestIndex:"..itemRequestIndex.."|author:"..author.."|ilink:"..ilink.."|";
		local itemRequestIndexString = string.match(message, "itemRequestIndex:(%d+)|");
		local itemRequestIndex = tonumber(itemRequestIndexString);
		local author = string.match(message, "author:(%a+)|");
		local ilink = string.match(message, "ilink:(.+)|");
		table.insert(ELOOTPLAYERS[itemRequestIndex], author);
		table.insert(ELOOTPLAYERCUR[itemRequestIndex], ilink);
		ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] = true;
		ELootPlayersScrollFrame_Update();
		
	end
 end
 
 function ELoot:ELOOTCLEAR_HANDLER(prefix, message, distribution, sender)

	local ssnhost = string.match(message, "sessionHost:(%a+)|");
	
	if (sessionHost ~= ssnhost) then
		--ignoring clear request
	elseif (sessionHost == ssnhost) then
		DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Clear message received from " .. sender .. ", clearing session.");
		ELootClearSession();
	end
 end
 
 
 function ELoot:AskRaiderForELoot(raiderName)
	local message = "sessionid:"..sessionID.."|";
	if (UnitIsConnected(raiderName)) then
		ELoot:SendCommMessage("HASELOOTRQST", message, "WHISPER", raiderName);
	end
 end
 
 function ELoot:CheckRaidersForELoot()

	local raiders = {};
	RaidersWithELoot = {};
	ELoot_UpdateUsers();
	for i=1, MAX_RAID_MEMBERS do
		name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		table.insert(raiders, name);
	end
	
	for i=1, #raiders do
		if (UnitName("player") == RaidersWithELoot[i]) then
			--lets not forward to ourselves; nothing here!
		else
			ELoot:AskRaiderForELoot(raiders[i]);
		end
	end
 end

 
 function ELoot:ForwardRequestToSessionClients(itemRequestIndex, author, ilink)
	for i=1, #RaidersWithELoot do
		if (UnitName("player") == RaidersWithELoot[i]) then
			--lets not forward to ourselves; nothing here!
		else
			local sendstring = "sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|itemRequestIndex:"..itemRequestIndex.."|author:"..author.."|ilink:"..ilink.."|";
			ELoot:SendCommMessage("ELOOTFWDREQ", sendstring, "WHISPER", RaidersWithELoot[i]);
		end
	end
	
 end
 
 function ELoot:SendStartSession()
	-- lets let the other eloot users know that we just started a session that they should listen to
	
	local elootstrings = "";
	for i=1, #ELOOTSTRINGS do
		elootstrings = elootstrings .. "elootstring:"  .. ELOOTSTRINGS[i].."|";
	end
	
	for i=1, #RaidersWithELoot do
		local sendstring = "sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|" .. elootstrings;
		ELoot:SendCommMessage("ELOOTSSNSTART", sendstring, "WHISPER", RaidersWithELoot[i]);
	end
 end
 
 
 
 function ELoot:CommsTestHandler(prefix, message, distribution, sender)
	ELoot:SendStartSession();
 end
 
  function ELootSyncComms()
	ELoot:CheckRaidersForELoot();
 end
 
 
 
 function ELoot_UpdateUsers()
	local userstring = "";
	for i=1, #RaidersWithELoot do
		if (userstring == "") then
			userstring = RaidersWithELoot[i];
		else
			userstring = userstring .. ", " .. RaidersWithELoot[i];
		end
		
	end
	ELootMainFrame.users:SetText(userstring);
 end
 
function ELoot_OnLoad()
 LibStub("AceComm-3.0"):Embed(ELoot);
 elapsedTimeFrame = CreateFrame("frame");
 elapsedTimeFrame:SetScript("OnUpdate", ELootTimerOnUpdate)
 StaticPopupDialogs["ELOOT_CONFIRMCLEAR"] = {
  text = "Are you sure you want to clear this session?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
      ELootClearSession();
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = STATICPOPUP_NUMDIALOGS,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}
 ELoot:RegisterComm("TEST", "CommsTestHandler")
 ELoot:RegisterComm("HASELOOTRQST", "HASELOOTRQST_HANDLER");
 ELoot:RegisterComm("HASELOOTRSPN", "HASELOOTRSPN_HANDLER");
 ELoot:RegisterComm("ELOOTSSNSTART", "ELOOTSSNSTART_HANDLER");
 ELoot:RegisterComm("ELOOTFWDREQ", "ELOOTFWDREQ_HANDLER");
 ELoot:RegisterComm("ELOOTCLEAR", "ELOOTCLEAR_HANDLER");
 
 
 ELootMainFrame.users:SetText("");
 
 SLASH_ELOOT1 = "/eloot"
 SlashCmdList["ELOOT"] = function(msg, editBox) ELootMainFrame:Show(); end
end





 --ELOOTPLAYERS = { {"rogerbrown", "sco", "kungen", "inza", "macks", "dumrick", "jens", "kilee", "alyenna"},{"macks", "rogerbrown"}, {"inza"}, {}, {"poyo", "seijta"}, {"poyo", "seijta"} };
 --ELOOTPLAYERCUR = { {"bow", "bulwark", "shield", "trinket", "staff", "axe", "staff2", "robes", "onehand"},{"staff", "bow"}, {"trinket"}, {}, {"poyoshield", "bearclaw"}, {"poyoshield", "bearclaw"} };
 
 function ELootItemButton_OnClick(self, button)
	b = ELootItemsScrollFrame.buttons;
	btn = b[self:GetID()];
	itemSelected = self:GetID();
	if ( IsModifiedClick() ) then
		fixedlink = GetFixedLink(ELOOTSTRINGS[self:GetID()]);
		HandleModifiedItemClick(fixedlink);
	else
		SetItemRef(ELOOTSTRINGS[self:GetID()], "item", "LeftButton");
	end
	ELootItemsScrollFrame_Update();
	ELootPlayersScrollFrame_Update();
 end
 
 function ELootPlayerButton_OnClick()
	
 end
 function ELootPlayerButton_OnEnter()
	
 end
 function ELootPlayerButton_OnLeave()
	
 end
 
 
 function ELootItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	GameTooltip:SetHyperlink(ELOOTSTRINGS[self:GetID()]);
	GameTooltip:Show();
 end
 function ELootItemButton_OnLeave()
	GameTooltip:Hide();
 end
 
 function ELootItemsScrollFrame_Update()
	
	local offset = HybridScrollFrame_GetOffset(ELootItemsScrollFrame)
	
	local buttons = ELootItemsScrollFrame.buttons
	local numButtons = #buttons;
	local visible = #ELOOTSTRINGS;
	 
	for i=1, #buttons do
		
		local index = i + offset;
		local button = buttons[i];
		button:SetID(index);
		
		if (ELOOTSTRINGS[index] and index <= visible) then
			button.string1:SetText(ELOOTSTRINGS[index]);
			button.string1:SetTextColor(255, 0, 0);
			button.string1:Show();
			
			local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ELOOTSTRINGS[index]);
			
			button.string2:SetText(iLevel);
			button.string2:SetTextColor(255, 0, 0);
			button.string2:Show();
			
			
			button:Show();
		else
			button:Hide();
		end
		if (index == itemSelected) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
	end
	local totalHeight = visible * (BUTTON_HEIGHT + BUTTON_OFFSET);
	local displayedHeight = numButtons * (BUTTON_HEIGHT + BUTTON_OFFSET);
	HybridScrollFrame_Update(ELootItemsScrollFrame, totalHeight, displayedHeight);
 end
 
 function ELootItemsScrollFrame_OnResize()
	ELootItemsScrollFrame_Update();
 end
 
 function ELootItemsScrollFrame_OnLoad()
	ELootItemsScrollFrame.doNotHide = true;
	
	ELootItemsScrollFrame.stepSize = MWHEEL_SCROLLSIZE;
	ELootItemsScrollFrame.update = ELootItemsScrollFrame_Update;
	HybridScrollFrame_CreateButtons(ELootItemsScrollFrame, "ELootItemButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -BUTTON_OFFSET, "TOP", "BOTTOM");
 end
 
 function ELootItemsScrollFrame_OnEvent()
 
 end
 
 function ELootItemsScrollFrame_OnShow()
	ELootItemsScrollFrame_Update();
 end
 
 
 


  function ELootPlayersScrollFrame_Update()
	
	local offset = HybridScrollFrame_GetOffset(ELootPlayersScrollFrame)
	
	local buttons = ELootPlayersScrollFrame.buttons
	local numButtons = #buttons;
	local visible = 0;
	if (itemSelected > 0 and #ELOOTPLAYERS >= itemSelected) then
		visible = #ELOOTPLAYERS[itemSelected];
	else
		visible = 0;
	end
	
	for i=1, #buttons do
		
		local index = i + offset;
		local button = buttons[i];
		button:SetID(index);
		
		if (i and index <= visible) then
			button.playerName:SetText(ELOOTPLAYERS[itemSelected][index]);
			button.playerName:SetTextColor(0, 255, 0);
			button.playerName:Show();
			button.curItem:SetText(ELOOTPLAYERCUR[itemSelected][index]);
			button.curItem:Show();
			
			local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ELOOTPLAYERCUR[itemSelected][index]);
			
			button.curItemlvl:SetText(iLevel);
			button.curItemlvl:SetTextColor(0, 255, 0);
			button.curItemlvl:Show();
			button:Show();
		else
			button:Hide();
		end
		
		
	end
	
	if (visible == 0 and itemSelected > 0) then
		asdfasdfasdf:Show();
	else
		asdfasdfasdf:Hide();
	end
	local totalHeight = visible * (BUTTON_HEIGHT + BUTTON_OFFSET);
	local displayedHeight = numButtons * (BUTTON_HEIGHT + BUTTON_OFFSET);
	HybridScrollFrame_Update(ELootPlayersScrollFrame, totalHeight, displayedHeight);
 end
 
 function ELootPlayersScrollFrame_OnLoad()
	ELootPlayersScrollFrame.doNotHide = true;
	ELootPlayersScrollFrame.stepSize = MWHEEL_SCROLLSIZE;
	ELootPlayersScrollFrame.update = ELootPlayersScrollFrame_Update;
	HybridScrollFrame_CreateButtons(ELootPlayersScrollFrame, "ELootPlayerButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -BUTTON_OFFSET, "TOP", "BOTTOM");
	
	
 end
  function ELootPlayersScrollFrame_OnShow()
	ELootPlayersScrollFrame_Update();
 end
 
 function ELootPlayersScrollFrame_OnResize()
	ELootPlayersScrollFrame_Update();
 end
 
 function ELootPlayerButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	GameTooltip:SetHyperlink(ELOOTPLAYERCUR[itemSelected][self:GetID()]);
	GameTooltip:Show();
 end
 function ELootPlayerButton_OnLeave()
	GameTooltip:Hide();
 end
 
 
 function ELootGetMasterLootIndexFromName(playerName)
	for i = 1, 5 do
		
		for li = 1, GetNumLootItems() do
			candidate = GetMasterLootCandidate(li, i);
			if (candidate) then
				if (candidate == playerName) then
					return i;
				end
			end
		end
	end
 end
 
 function ELootPlayerButton_OnClick(self, button)

	if (button == "RightButton") then
		
		local menu = {
			{
				text = "Send item to " .. ELOOTPLAYERS[itemSelected][self:GetID()], hasArrow = true,
				menuList = 
					{
						{ 
							text = "Send!", func = function() 
									winnerIdx = ELootGetMasterLootIndexFromName(ELOOTPLAYERS[itemSelected][self:GetID()]); 
									
									if (winnerIdx) then
										DEFAULT_CHAT_FRAME:AddMessage("Sending loot to " .. ELOOTPLAYERS[itemSelected][self:GetID()]);
										GiveMasterLoot(itemSelected, winnerIdx);
									end
								end 
						}
					} 
			}
		} 
		EasyMenu(menu, ELootPlayerDropDownMenu, "cursor", 0 , 0, "MENU");
	else
		EasyMenu({}, ELootPlayerDropDownMenu, "cursor", 0 , 0, "MENU");
	end
 end
 
 function ELootItemsPrint(targetchat)
	
	for i=1, #ELOOTSTRINGS do
		sendstring = i .. " - " .. ELOOTSTRINGS[i]
		SendChatMessage(sendstring, targetchat);
	end
 end



function ELootHandleRaidUpdate(self, event, ...)
	ELoot:CheckRaidersForELoot();
end

 function ELootHandleWhisper(self, event, ...)
	
	
	if (event == "CHAT_MSG_WHISPER") then
		
		
		local message, author = ...;
		author = string.gsub(author, "%-%a+", "")
		local raidIndex = UnitInRaid(author);
		if (raidIndex) then
			-- sender in raid, ok
		else
			-- sender not in raid, ignoring
			return;
		end
		local itemrqi = "";
		local ilink = "";
		for word in string.gmatch(message, '%d%s') do
			itemrqi = word;
		end
		for word in string.gmatch(message, "(\124.-\124h\124r)") do
			ilink = word;
		end
		if (itemrqi ~= nil and itemrqi ~= "" and ilink ~= nil and ilink ~= "") then
			if (sessionHost ~= UnitName("player")) then
				return;
			end
			local itemRequestIndex = tonumber(itemrqi);

			if (itemRequestIndex <= 0 or itemRequestIndex > #ELOOTSTRINGS) then
				-- out of bounds
				return;
			end
			
			local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ilink);
		
			local temp = { author, itemRequestIndex, ilink };
			table.insert(ELOOTREQUESTS_TOBECHECKED, temp);
			
			if (not ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] and sType and (sType == "Armor" or sType == "Weapon")) then
				
				table.insert(ELOOTPLAYERS[itemRequestIndex], author);
				table.insert(ELOOTPLAYERCUR[itemRequestIndex], ilink);
				ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] = true;
				ELoot:ForwardRequestToSessionClients(itemRequestIndex, author, ilink);
				ELootPlayersScrollFrame_Update();
				local reply = "Loot request registered: " .. ELOOTSTRINGS[itemRequestIndex] .. " for " .. author;
				SendChatMessage(reply, "WHISPER", nil, author);
				
			end
		end
		
	end
 end

		
 function ELoot:HandleBNWhisper(self, event, ...)
	local message, author, _, _, _, _, _, _, _, _, _, _, presenceID = ...;
		local friendIdx = BNGetFriendIndex(presenceID)
		for i = 1, BNGetNumFriendToons(friendIdx) do
            local _, toonName, _, _, _, _, _, _, _, _, _, _, _, _, _, toonID = BNGetFriendToonInfo(friendIdx, i)
			for k=1, MAX_RAID_MEMBERS do
				local name = GetRaidRosterInfo(k);
				if (toonName == name) then
					-- toon is in raid!
					local message = ...;
					author = toonName;
					local itemrqi = "";
					local ilink = "";
					for word in string.gmatch(message, '%d%s') do
						itemrqi = word;
					end
					
					ilink = string.match(message, '|H.-|h.-|h');
					
					if (itemrqi ~= nil and itemrqi ~= "" and ilink ~= nil and ilink ~= "") then
						if (sessionHost ~= UnitName("player")) then
							return;
						end
						local itemRequestIndex = tonumber(itemrqi);
						if (itemRequestIndex <= 0 or itemRequestIndex > #ELOOTSTRINGS) then
							-- OUT OF BOUNDS
							return;
						end
						
						local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ilink);
						
						if (not ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] and sType and (sType == "Armor" or sType == "Weapon")) then
							table.insert(ELOOTPLAYERS[itemRequestIndex], author);
							table.insert(ELOOTPLAYERCUR[itemRequestIndex], ilink);
							ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] = true;
							ELoot:ForwardRequestToSessionClients(itemRequestIndex, author, ilink);
							ELootPlayersScrollFrame_Update();
							local reply = "Loot request registered: " .. ELOOTSTRINGS[itemRequestIndex] .. " for " .. author;
							SendChatMessage(reply, "WHISPER", nil, author);
							
						end
					end
					
					
					
				end
			end
            
        end
 end
 
 
 function ELootMainFrame_OnEvent(self, event, ...)

	if (event == "CHAT_MSG_WHISPER") then
		ELootHandleWhisper(self, event, ...);
	elseif (event == "GROUP_ROSTER_UPDATE") then
		ELootHandleRaidUpdate(self, event, ...);
	elseif (event == "CHAT_MSG_BN_WHISPER") then
		 ELoot:HandleBNWhisper(self, event, ...);
		
	end
end



 function ELootPost()
	DEFAULT_CHAT_FRAME:AddMessage("E-Loot POST initialized.");
	ELootClearSession();
	sessionHost = UnitName("player");
	
	local lootThreshhold = GetLootThreshold();
	
	for i=1, GetNumLootItems() do
		local itemlink = GetLootSlotLink(i);
		if (itemlink) then
			local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(itemlink);
			if (iRarity and iRarity >= lootThreshhold) then
				table.insert(ELOOTSTRINGS, GetLootSlotLink(i));
			end
		end
	end
	
	ELoot:SendStartSession();
	
	for i=1, #ELOOTSTRINGS do
		local t1 = {};
		table.insert(ELOOTPLAYERS, t1);
		local t2 = {};
		table.insert(ELOOTPLAYERCUR, t2);
		local t3 = {};
		table.insert(ELOOTITEMREQUESTEDBYPLAYER, t3);
		
	end
	
	ELootItemsScrollFrame_Update();
	ELootItemsPrint("RAID");
	
 end

 function ELoot:SendClearToSessionClients()
	for i=1, #RaidersWithELoot do
		if (UnitName("player") == RaidersWithELoot[i]) then
			--lets not forward to ourselves; nothing here!
		else
			local sendstring = "sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|";
			ELoot:SendCommMessage("ELOOTCLEAR", sendstring, "WHISPER", RaidersWithELoot[i]);
		end
	end
 end
 
 function ELootClear_OnClick()
	StaticPopup_Show ("ELOOT_CONFIRMCLEAR");
 end
 
 function ELootClearSession()
	if (sessionHost == UnitName("player")) then
		ELoot:SendClearToSessionClients();
	end
	itemSelected = 0;
	ELOOTSTRINGS = { };
	ELOOTPLAYERS = { };
	ELOOTPLAYERCUR = { };
	ELOOTITEMREQUESTEDBYPLAYER = { };
	ELootItemsScrollFrame_Update();
	ELootPlayersScrollFrame_Update();
	HideUIPanel(ItemRefTooltip);
	sessionHost = nil;
	DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Session cleared.");
 end
 
 
 function ELootTest()
	DEFAULT_CHAT_FRAME:AddMessage("E-Loot TEST started. ");
	ELootClearSession();
	sessionHost = UnitName("player");
	DEFAULT_CHAT_FRAME:AddMessage("sessionHost: " .. sessionHost);
	
	table.insert(ELOOTSTRINGS, GetInventoryItemLink("player",GetInventorySlotInfo("MainHandSlot")));
	table.insert(ELOOTSTRINGS, GetInventoryItemLink("player",GetInventorySlotInfo("SecondaryHandSlot")));
	table.insert(ELOOTSTRINGS, GetInventoryItemLink("player",GetInventorySlotInfo("Trinket0Slot")));
	table.insert(ELOOTSTRINGS, GetInventoryItemLink("player",GetInventorySlotInfo("LegsSlot")));
	table.insert(ELOOTSTRINGS, GetInventoryItemLink("player",GetInventorySlotInfo("WristSlot")));
	table.insert(ELOOTSTRINGS, GetInventoryItemLink("player",GetInventorySlotInfo("HeadSlot")));
	ELoot:SendStartSession();
	for i=1, #ELOOTSTRINGS do
		local t1 = {};
		table.insert(ELOOTPLAYERS, t1);
		local t2 = {};
		table.insert(ELOOTPLAYERCUR, t2);
		local t3 = {};
		table.insert(ELOOTITEMREQUESTEDBYPLAYER, t3);
		
	end
	
	ELootItemsScrollFrame_Update();
	
	ELootItemsPrint("RAID");
	
 end
 

 
