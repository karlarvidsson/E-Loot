
 
 
 local BUTTON_HEIGHT = 20
 local BUTTON_OFFSET = 0
 local MWHEEL_SCROLLSIZE = BUTTON_HEIGHT * 4
 
	 
 local itemSelected = 0;
 --local ELootComms = LibStub("AceComm-3.0");
 
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
       -- DEFAULT_CHAT_FRAME:AddMessage("ping!")
        elapsedTimeTotal = 0
		
		--DEFAULT_CHAT_FRAME:AddMessage("ELOOTREQUESTS_TOBECHECKED len: " .. #ELOOTREQUESTS_TOBECHECKED);
		if (#ELOOTREQUESTS_TOBECHECKED > 0) then
			--DEFAULT_CHAT_FRAME:AddMessage("Requests pending: ");
			
		--	local ELOOTREQUESTS_PROCESSED = { };
	--		for i=1, #ELOOTREQUESTS_TOBECHECKED do
	--			table.insert(ELOOTREQUESTS_PROCESSED, false);
		--	end
			
			for i=1, #ELOOTREQUESTS_TOBECHECKED do
				if (ELOOTREQUESTS_TOBECHECKED[i]) then
					--DEFAULT_CHAT_FRAME:AddMessage("player: " .. ELOOTREQUESTS_TOBECHECKED[i][1] );
					--DEFAULT_CHAT_FRAME:AddMessage("item index: " .. ELOOTREQUESTS_TOBECHECKED[i][2] );
					--DEFAULT_CHAT_FRAME:AddMessage("cur item: " .. ELOOTREQUESTS_TOBECHECKED[i][3] );
					local author = ELOOTREQUESTS_TOBECHECKED[i][1];
					local itemRequestIndex = ELOOTREQUESTS_TOBECHECKED[i][2];
					local ilink = ELOOTREQUESTS_TOBECHECKED[i][3];
					
					
					
					
					
					local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ilink);
					--if (sType) then
					--	DEFAULT_CHAT_FRAME:AddMessage("REQUESTED TYPE OK");
					--	DEFAULT_CHAT_FRAME:AddMessage(sType);
					--else
					--	DEFAULT_CHAT_FRAME:AddMessage("REQUESTED TYPE CHECK FAILED");
						
					--end
					
					
					
					if ( not ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] and sType and (sType == "Armor" or sType == "Weapon")) then
					
						--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: INSIDE requested check");
						table.insert(ELOOTPLAYERS[itemRequestIndex], author);
						table.insert(ELOOTPLAYERCUR[itemRequestIndex], ilink);
						ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] = true;
						ELoot:ForwardRequestToSessionClients(itemRequestIndex, author, ilink);
						ELootPlayersScrollFrame_Update();
						local reply = "Loot request registered: " .. ELOOTSTRINGS[itemRequestIndex] .. " for " .. author;
						SendChatMessage(reply, "WHISPER", nil, author);
						ELOOTREQUESTS_TOBECHECKED[i] = false;
					elseif (ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author]) then
						--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: already requested by this player, removing from pending requests");
						ELOOTREQUESTS_TOBECHECKED[i] = false;
					end
				end
			end
			
			local requests_empty = true;
			for i=1, #ELOOTREQUESTS_TOBECHECKED do
				--DEFAULT_CHAT_FRAME:AddMessage(tostring(ELOOTREQUESTS_TOBECHECKED[i]));
				if (ELOOTREQUESTS_TOBECHECKED) then
					requests_empty = false;
				end
			end
			--DEFAULT_CHAT_FRAME:AddMessage("no more requests pending, emptying table" );
			ELOOTREQUESTS_TOBECHECKED = { };
			
		else
			--DEFAULT_CHAT_FRAME:AddMessage("No requests pending.");
		end
		
	--[[	
		fff = {1,2,3,4,5,6,7,8,9,10};
		ffff = {};
		for i=1, #fff do
			table.insert(ffff, false);
		end
		for i=1, #fff do
			DEFAULT_CHAT_FRAME:AddMessage(tostring(fff[i]))
		end
		for i=1, #fff do
			if (fff[i] % 2 == 0) then
				--table.remove(fff, i);
				ffff[i] = true;
			end
		end
		
		DEFAULT_CHAT_FRAME:AddMessage("ffff len: " .. #ffff)
		for i=1, #ffff do
			
			DEFAULT_CHAT_FRAME:AddMessage("ffff: " .. tostring(ffff[i]))
		end
		
		for i=1, #ffff do
			if (ffff[i] == true) then
				--table.remove(fff, i);
				fff[i] = false;
				DEFAULT_CHAT_FRAME:AddMessage("removed " .. tostring(i))
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage("RESULTS: fff len: " .. #fff)
		for i=1, #fff do
			if (fff[i]) then
				DEFAULT_CHAT_FRAME:AddMessage(tostring(fff[i]))
			end
		end
		
		for i=1, #ELOOTSTRINGS_TOBECHECKED do
			
		end
		
		]]--
    end
end


 
 
 function ELoot:HASELOOTRSPN_HANDLER(prefix, message, distribution, sender)
	--DEFAULT_CHAT_FRAME:AddMessage("HASELOOTRSPN_HANDLER for message: " .. message);
	local sID = "";
	for word in string.gmatch(message, "%a+:(%a+)|") do 
		sID = word;
	end
	if (sID == sessionID) then
		--DEFAULT_CHAT_FRAME:AddMessage("session id matches up, "..sender .." is using ELoot!");
		local sendstring = "sessionid:"..sessionID.."|";
		if (not isInTable(RaidersWithELoot, sender)) then
			table.insert(RaidersWithELoot, sender);
		end
		ELoot_UpdateUsers();
	end
 end
 function ELoot:HASELOOTRQST_HANDLER(prefix, message, distribution, sender)
	--DEFAULT_CHAT_FRAME:AddMessage("HASELOOTRQST_HANDLER for message: " .. message);
	local sID = "";
	for word in string.gmatch(message, "%a+:(%a+)|") do 
		sID = word;
	end
	if (sID == sessionID) then
		--DEFAULT_CHAT_FRAME:AddMessage("session id matches up, sending response to ".. sender .."!");
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
	--DEFAULT_CHAT_FRAME:AddMessage("ELOOTSSNSTART_HANDLER");
	--DEFAULT_CHAT_FRAME:AddMessage(prefix);
	--DEFAULT_CHAT_FRAME:AddMessage(message);
	
	 
	local ssnhost = string.match(message, "sessionHost:(%a+)|");
	--DEFAULT_CHAT_FRAME:AddMessage("extracted new session host: " .. ssnhost);
	
	if (sessionHost == nil) then
		--DEFAULT_CHAT_FRAME:AddMessage("E-Loot: No current sessionHost, accepting new host from " .. sender .. ".");
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
		--DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Current sessionHost is " ..sessionHost.. ", ignoring session start request from " .. sender ..".");
	end
	
 end
 
 function ELoot:ELOOTFWDREQ_HANDLER(prefix, message, distribution, sender)
	--DEFAULT_CHAT_FRAME:AddMessage("ELOOTFWDREQ_HANDLER");
	--DEFAULT_CHAT_FRAME:AddMessage(prefix);
	--DEFAULT_CHAT_FRAME:AddMessage(message);
	
	local ssnhost = string.match(message, "sessionHost:(%a+)|");
	--DEFAULT_CHAT_FRAME:AddMessage("extracted new session host: " .. ssnhost);
	
	if (sessionHost == nil) then
		--DEFAULT_CHAT_FRAME:AddMessage("E-Loot: No current sessionHost, ignoring forwarded request from " .. sender .. ".");
	elseif (sessionHost == ssnhost) then
		--DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Sent sessionHost matches up with the local sessionHost, registering forwarded request from " .. sender ..".");
		-- the sendstring looks like this: sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|itemRequestIndex:"..itemRequestIndex.."|author:"..author.."|ilink:"..ilink.."|";
		local itemRequestIndexString = string.match(message, "itemRequestIndex:(%d+)|");
		local itemRequestIndex = tonumber(itemRequestIndexString);
		local author = string.match(message, "author:(%a+)|");
		local ilink = string.match(message, "ilink:(.+)|");
		--DEFAULT_CHAT_FRAME:AddMessage("itemRequestIndexString: " .. itemRequestIndexString);
		--DEFAULT_CHAT_FRAME:AddMessage("itemRequestIndex: " .. tostring(itemRequestIndex));
		--DEFAULT_CHAT_FRAME:AddMessage("author: " .. author);
		--DEFAULT_CHAT_FRAME:AddMessage("ilink: " .. ilink);
		table.insert(ELOOTPLAYERS[itemRequestIndex], author);
		table.insert(ELOOTPLAYERCUR[itemRequestIndex], ilink);
		ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] = true;
		ELootPlayersScrollFrame_Update();
		
		--DEFAULT_CHAT_FRAME:AddMessage("Forwarded request added successfully.");
	end
 end
 
 function ELoot:ELOOTCLEAR_HANDLER(prefix, message, distribution, sender)
	--DEFAULT_CHAT_FRAME:AddMessage("ELOOTCLEAR_HANDLER");
	--DEFAULT_CHAT_FRAME:AddMessage(prefix);
	--DEFAULT_CHAT_FRAME:AddMessage(message);
	
	local ssnhost = string.match(message, "sessionHost:(%a+)|");
	--DEFAULT_CHAT_FRAME:AddMessage("extracted new session host: " .. ssnhost);
	
	if (sessionHost ~= ssnhost) then
		--DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Ignoring clear request from " .. sender .. ", the sessionHost does not match up with the local one.");
	elseif (sessionHost == ssnhost) then
		--DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Clear message received from " .. sender .. ", clearing session.");
		ELootClearSession();
	end
 end
 
 
 function ELoot:AskRaiderForELoot(raiderName)
	--DEFAULT_CHAT_FRAME:AddMessage("sending to " .. raiderName);
	local message = "sessionid:"..sessionID.."|";
	if (UnitIsConnected(raiderName)) then
		ELoot:SendCommMessage("HASELOOTRQST", message, "WHISPER", raiderName);
	end
 end
 
 function ELoot:CheckRaidersForELoot()
	
--	table.insert(RaidersWithELoot, "tigerhaaaa");
--	DEFAULT_CHAT_FRAME:AddMessage(RaidersWithELoot[1]);
--	DEFAULT_CHAT_FRAME:AddMessage("printing raiders");
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
			--DEFAULT_CHAT_FRAME:AddMessage("skipping checkingourselves");
		else
			ELoot:AskRaiderForELoot(raiders[i]);
		end
	end
 end

 
 function ELoot:ForwardRequestToSessionClients(itemRequestIndex, author, ilink)
	--DEFAULT_CHAT_FRAME:AddMessage("forwarding request item: " .. itemRequestIndex .. " requested by: " .. author .. " item: " .. ilink);
	for i=1, #RaidersWithELoot do
		if (UnitName("player") == RaidersWithELoot[i]) then
			--lets not forward to ourselves; nothing here!
			--DEFAULT_CHAT_FRAME:AddMessage("skipping forwarding to ourselves");
		else
			local sendstring = "sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|itemRequestIndex:"..itemRequestIndex.."|author:"..author.."|ilink:"..ilink.."|";
			--DEFAULT_CHAT_FRAME:AddMessage("ELOOTFWDREQ[" .. sendstring .. "] to " .. RaidersWithELoot[i]);
			ELoot:SendCommMessage("ELOOTFWDREQ", sendstring, "WHISPER", RaidersWithELoot[i]);
		end
	end
	
 end
 
 function ELoot:SendStartSession()
	-- lets let the other eloot users know that we just started a session that they should listen to
	--DEFAULT_CHAT_FRAME:AddMessage("SendStartSession");
	
	local elootstrings = "";
	for i=1, #ELOOTSTRINGS do
		elootstrings = elootstrings .. "elootstring:"  .. ELOOTSTRINGS[i].."|";
	end
	
	for i=1, #RaidersWithELoot do
		local sendstring = "sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|" .. elootstrings;
		
		
		--DEFAULT_CHAT_FRAME:AddMessage("ELOOTSSNSTART[" .. sendstring .. "] to " .. RaidersWithELoot[i]);
		ELoot:SendCommMessage("ELOOTSSNSTART", sendstring, "WHISPER", RaidersWithELoot[i]);
	end
 end
 
 
 
 function ELoot:CommsTestHandler(prefix, message, distribution, sender)
	--DEFAULT_CHAT_FRAME:AddMessage("Comms received!");
	--DEFAULT_CHAT_FRAME:AddMessage("prefix: " .. prefix);
	--DEFAULT_CHAT_FRAME:AddMessage("message: " .. message);
	--DEFAULT_CHAT_FRAME:AddMessage("distribution: " .. distribution);
	--DEFAULT_CHAT_FRAME:AddMessage("sender: " .. sender);
	--ELoot:CheckRaidersForELoot();
	
	ELoot:SendStartSession();
 end
 
  function ELootSyncComms()
  --sessionHost = UnitName("player");
	--DEFAULT_CHAT_FRAME:AddMessage("sessionHost: " .. sessionHost);
	--DEFAULT_CHAT_FRAME:AddMessage("Sending comms...");
	--ELoot:SendCommMessage("TEST", "more data to send", "WHISPER", "Tigerlol");
	--DEFAULT_CHAT_FRAME:AddMessage("Comms sent.");
	--DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Manual sync initialized.");
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
--	DEFAULT_CHAT_FRAME:AddMessage("Clicked " .. self:GetID());
--	DEFAULT_CHAT_FRAME:AddMessage(itemSelected);
	if ( IsModifiedClick() ) then
		--DEFAULT_CHAT_FRAME:AddMessage("modded click");
		fixedlink = GetFixedLink(ELOOTSTRINGS[self:GetID()]);
		--DEFAULT_CHAT_FRAME:AddMessage(fixedlink);
		HandleModifiedItemClick(fixedlink);
		--SetItemRef(fixedlink, "item", "LeftButton");
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
	--DEFAULT_CHAT_FRAME:AddMessage(ELOOTSTRINGS[self:GetID()]);
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
	--	DEFAULT_CHAT_FRAME:AddMessage("GO: " .. i);
		
		if (ELOOTSTRINGS[index] and index <= visible) then
		--	DEFAULT_CHAT_FRAME:AddMessage("string" .. ELOOTSTRINGS[index]);
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
--	DEFAULT_CHAT_FRAME:AddMessage(numButtons);
 end
 
 function ELootItemsScrollFrame_OnResize()
	--DEFAULT_CHAT_FRAME:AddMessage("onresize: " .. #ELootItemsScrollFrame.buttons);
	ELootItemsScrollFrame_Update();
	--HybridScrollFrame_CreateButtons(ELootItemsScrollFrame, "ELootItemButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -BUTTON_OFFSET, "TOP", "BOTTOM");
 end
 
 function ELootItemsScrollFrame_OnLoad()
--	ELOOTSTRINGS[1] = GetInventoryItemLink("player",GetInventorySlotInfo("MainHandSlot"));
--	ELOOTSTRINGS[2] = GetInventoryItemLink("player",GetInventorySlotInfo("SecondaryHandSlot"));
--	ELOOTSTRINGS[3] = GetInventoryItemLink("player",GetInventorySlotInfo("Trinket0Slot"));
--	ELOOTSTRINGS[4] = GetInventoryItemLink("player",GetInventorySlotInfo("LegsSlot"));
--	ELOOTSTRINGS[5] = GetInventoryItemLink("player",GetInventorySlotInfo("WristSlot"));
--	ELOOTSTRINGS[6] = GetInventoryItemLink("player",GetInventorySlotInfo("HeadSlot"));
	
	--ELootItemsScrollFrame:SetHeight(2000);
	ELootItemsScrollFrame.doNotHide = true;
	
	ELootItemsScrollFrame.stepSize = MWHEEL_SCROLLSIZE;
	ELootItemsScrollFrame.update = ELootItemsScrollFrame_Update;
	HybridScrollFrame_CreateButtons(ELootItemsScrollFrame, "ELootItemButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -BUTTON_OFFSET, "TOP", "BOTTOM");
	
	--DEFAULT_CHAT_FRAME:AddMessage("Loaded");
 end
 
 function ELootItemsScrollFrame_OnEvent()
	--DEFAULT_CHAT_FRAME:AddMessage("Event fired");
 end
 
 function ELootItemsScrollFrame_OnShow()
	ELootItemsScrollFrame_Update();
	--DEFAULT_CHAT_FRAME:AddMessage("OnShow");
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
	--	DEFAULT_CHAT_FRAME:AddMessage("GO: " .. i);
		
		if (i and index <= visible) then
		--	DEFAULT_CHAT_FRAME:AddMessage("string" .. ELOOTSTRINGS[index]);
			button.playerName:SetText(ELOOTPLAYERS[itemSelected][index]);
			button.playerName:SetTextColor(0, 255, 0);
			button.playerName:Show();
			button.curItem:SetText(ELOOTPLAYERCUR[itemSelected][index]);
			--button.curItem:SetTextColor(0, 255, 0);
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
	--DEFAULT_CHAT_FRAME:AddMessage(visible);
	--DEFAULT_CHAT_FRAME:AddMessage(#buttons);
	if (visible == 0 and itemSelected > 0) then
		asdfasdfasdf:Show();
	else
		asdfasdfasdf:Hide();
	end
	local totalHeight = visible * (BUTTON_HEIGHT + BUTTON_OFFSET);
	local displayedHeight = numButtons * (BUTTON_HEIGHT + BUTTON_OFFSET);
	HybridScrollFrame_Update(ELootPlayersScrollFrame, totalHeight, displayedHeight);
--	DEFAULT_CHAT_FRAME:AddMessage(numButtons);
 end
 
 function ELootPlayersScrollFrame_OnLoad()
	ELootPlayersScrollFrame.doNotHide = true;
	ELootPlayersScrollFrame.stepSize = MWHEEL_SCROLLSIZE;
	ELootPlayersScrollFrame.update = ELootPlayersScrollFrame_Update;
	HybridScrollFrame_CreateButtons(ELootPlayersScrollFrame, "ELootPlayerButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -BUTTON_OFFSET, "TOP", "BOTTOM");
	
	
 end
  function ELootPlayersScrollFrame_OnShow()
	ELootPlayersScrollFrame_Update();
	--DEFAULT_CHAT_FRAME:AddMessage("OnShow");
 end
 
 function ELootPlayersScrollFrame_OnResize()
	--DEFAULT_CHAT_FRAME:AddMessage("onresize: " .. #ELootItemsScrollFrame.buttons);
	ELootPlayersScrollFrame_Update();
	--HybridScrollFrame_CreateButtons(ELootItemsScrollFrame, "ELootItemButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -BUTTON_OFFSET, "TOP", "BOTTOM");
 end
 
 function ELootPlayerButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	--DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERCUR[itemSelected][self:GetID()]);
	GameTooltip:SetHyperlink(ELOOTPLAYERCUR[itemSelected][self:GetID()]);
	GameTooltip:Show();
 end
 function ELootPlayerButton_OnLeave()
	GameTooltip:Hide();
 end
 
 
 function ELootGetMasterLootIndexFromName(playerName)
	for i = 1, 5 do
		--DEFAULT_CHAT_FRAME:AddMessage("ASDASD");
		--DEFAULT_CHAT_FRAME:AddMessage(itemSelected);
		
		for li = 1, GetNumLootItems() do
		--DEFAULT_CHAT_FRAME:AddMessage("loot idx:" .. li);
			candidate = GetMasterLootCandidate(li, i);
			
			--DEFAULT_CHAT_FRAME:AddMessage(i.." -> "..candidate);
			if (candidate) then
				--DEFAULT_CHAT_FRAME:AddMessage("HGEJ");
				--DEFAULT_CHAT_FRAME:AddMessage(i.." -> "..candidate)
				--DEFAULT_CHAT_FRAME:AddMessage(playerName);
				if (candidate == playerName) then
					--DEFAULT_CHAT_FRAME:AddMessage("found " .. playerName .. " returning " .. i);
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
										--DEFAULT_CHAT_FRAME:AddMessage("Sending loot to " .. ELOOTPLAYERS[itemSelected][self:GetID()]);
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
	--DEFAULT_CHAT_FRAME:AddMessage("RAID UPD");
	ELoot:CheckRaidersForELoot();
end

 function ELootHandleWhisper(self, event, ...)
	--DEFAULT_CHAT_FRAME:AddMessage(event);
	
	
	if (event == "CHAT_MSG_WHISPER") then
		
		
		local message, author = ...;
		--DEFAULT_CHAT_FRAME:AddMessage(author);
		author = string.gsub(author, "%-%a+", "")
--DEFAULT_CHAT_FRAME:AddMessage(author);
		local itemrqi = "";
		local ilink = "";
		for word in string.gmatch(message, '%d%s') do
			itemrqi = word;
		end
		for word in string.gmatch(message, "(\124.-\124h\124r)") do
			ilink = word;
		end
		--DEFAULT_CHAT_FRAME:AddMessage(itemrqi);
		--DEFAULT_CHAT_FRAME:AddMessage(type(itemrqi));
		--DEFAULT_CHAT_FRAME:AddMessage(ilink);
		if (itemrqi ~= nil and itemrqi ~= "" and ilink ~= nil and ilink ~= "") then
			--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: Inside if-statement");
			if (sessionHost ~= UnitName("player")) then
				--DEFAULT_CHAT_FRAME:AddMessage("You are not the session host, whisper ignored."); 
				return;
			end
			local itemRequestIndex = tonumber(itemrqi);
			if (itemRequestIndex) then
				--DEFAULT_CHAT_FRAME:AddMessage("itemRequestIndex" .. tostring(itemRequestIndex));
			end
			--DEFAULT_CHAT_FRAME:AddMessage("#ELOOTSTRINGS" .. tostring(#ELOOTSTRINGS));
			if (itemRequestIndex <= 0 or itemRequestIndex > #ELOOTSTRINGS) then
				--DEFAULT_CHAT_FRAME:AddMessage("OUT OF BOUNDS");
				return;
			end
			
			--DEFAULT_CHAT_FRAME:AddMessage(itemRequestIndex);
			--DEFAULT_CHAT_FRAME:AddMessage(type(ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex]));
			--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: pre type check");
			local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ilink);
			if (sType) then
				--DEFAULT_CHAT_FRAME:AddMessage("TYPE OK");
				--DEFAULT_CHAT_FRAME:AddMessage(sType);
			else
				--DEFAULT_CHAT_FRAME:AddMessage("TYPE  CHECK FAILED");
				
			end
			local temp = { author, itemRequestIndex, ilink };
			table.insert(ELOOTREQUESTS_TOBECHECKED, temp);
			
			--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: pre item already requested check");
			if (not ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] and sType and (sType == "Armor" or sType == "Weapon")) then
				
				--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: INSIDE item already requested check");
				table.insert(ELOOTPLAYERS[itemRequestIndex], author);
				table.insert(ELOOTPLAYERCUR[itemRequestIndex], ilink);
				ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex][author] = true;
				ELoot:ForwardRequestToSessionClients(itemRequestIndex, author, ilink);
				ELootPlayersScrollFrame_Update();
				local reply = "Loot request registered: " .. ELOOTSTRINGS[itemRequestIndex] .. " for " .. author;
				SendChatMessage(reply, "WHISPER", nil, author);
				
			end
		end
		if (itemrqi) then
			--DEFAULT_CHAT_FRAME:AddMessage("itemrqi: " .. itemrqi);
		end
		if (ilink) then
			--DEFAULT_CHAT_FRAME:AddMessage("ilink: " .. itemrqi);
		end
		
		--DEFAULT_CHAT_FRAME:AddMessage("DEBUG: POST if-statement");
	end
 end

 -- Borrowed from RealLinks 
 --[[
 local function GetLinkColor(data)
	local type, id, arg1 = string.match(data, '(%w+):(%d+)')
	if(type == 'item') then
		local _, _, quality = GetItemInfo(id)
		if(quality) then
			local _, _, _, hex = GetItemQualityColor(quality)
			return '|c' .. hex
		else
			-- Item is not cached yet, show a white color instead
			-- Would like to fix this somehow
			return '|cffffffff'
		end
	end
end 
]]--
		
 function ELoot:HandleBNWhisper(self, event, ...)
	--DEFAULT_CHAT_FRAME:AddMessage(event .. " handler");
	local message, author, _, _, _, _, _, _, _, _, _, _, presenceID = ...;
		local friendIdx = BNGetFriendIndex(presenceID)
		for i = 1, BNGetNumFriendToons(friendIdx) do
            local _, toonName, _, _, _, _, _, _, _, _, _, _, _, _, _, toonID = BNGetFriendToonInfo(friendIdx, i)
			for k=1, MAX_RAID_MEMBERS do
				local name = GetRaidRosterInfo(k);
				if (toonName == name) then
					-- toon is in raid!
					--DEFAULT_CHAT_FRAME:AddMessage("toon is in raid: " .. toonName);
					
					--DEFAULT_CHAT_FRAME:AddMessage("message: " .. message);
					--DEFAULT_CHAT_FRAME:AddMessage("sender: " .. toonName);
					
				--	local reply = "Real ID whispers are not supported. Try again by clicking the name of the recipient in raid chat instead:";
				--	SendChatMessage(reply, "WHISPER", nil, toonName);
					
					local message = ...;
					author = toonName;
					local itemrqi = "";
					local ilink = "";
					for word in string.gmatch(message, '%d%s') do
						itemrqi = word;
					end
				--	for word in string.gmatch(message, "\124.+(\124.-\124h\124r)") do
				--		ilink = word;
				--	end
					
					ilink = string.match(message, '|H.-|h.-|h');
					
					--DEFAULT_CHAT_FRAME:AddMessage("itemrqi type: " .. type(itemrqi));
					--DEFAULT_CHAT_FRAME:AddMessage("ilink: type: " .. type(ilink));
					--if (itemrqi) then DEFAULT_CHAT_FRAME:AddMessage("itemrqi: " .. itemrqi); end
					--if (ilink) then	DEFAULT_CHAT_FRAME:AddMessage("ilink: " .. ilink);	end
					
					if (itemrqi ~= nil and itemrqi ~= "" and ilink ~= nil and ilink ~= "") then
						if (sessionHost ~= UnitName("player")) then
							--DEFAULT_CHAT_FRAME:AddMessage("You are not the session host, whisper ignored."); 
							return;
						end
						local itemRequestIndex = tonumber(itemrqi);
						if (itemRequestIndex <= 0 or itemRequestIndex > #ELOOTSTRINGS) then
							--DEFAULT_CHAT_FRAME:AddMessage("OUT OF BOUNDS");
							return;
						end
						
						--DEFAULT_CHAT_FRAME:AddMessage(itemRequestIndex);
						--DEFAULT_CHAT_FRAME:AddMessage(type(ELOOTITEMREQUESTEDBYPLAYER[itemRequestIndex]));
						local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(ilink);
						if (sType) then
							--DEFAULT_CHAT_FRAME:AddMessage("TYPE OK");
							--DEFAULT_CHAT_FRAME:AddMessage(sType);
						end
						
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
--DEFAULT_CHAT_FRAME:AddMessage("ONEVENT");
--DEFAULT_CHAT_FRAME:AddMessage(event);
	if (event == "CHAT_MSG_WHISPER") then
		--DEFAULT_CHAT_FRAME:AddMessage("ASD");
		ELootHandleWhisper(self, event, ...);
	elseif (event == "GROUP_ROSTER_UPDATE") then
		--DEFAULT_CHAT_FRAME:AddMessage("ASDSADASD");
		ELootHandleRaidUpdate(self, event, ...);
	elseif (event == "CHAT_MSG_BN_WHISPER") then
		 ELoot:HandleBNWhisper(self, event, ...);
		
	end
end



 function ELootPost()
	--DEFAULT_CHAT_FRAME:AddMessage("ELOOT POST");
	ELootClearSession();
	sessionHost = UnitName("player");
	--DEFAULT_CHAT_FRAME:AddMessage("sessionHost: " .. sessionHost);
	
	local lootThreshhold = GetLootThreshold();
	--DEFAULT_CHAT_FRAME:AddMessage(lootThreshhold);
	
	for i=1, GetNumLootItems() do
		
		local itemlink = GetLootSlotLink(i);
		--DEFAULT_CHAT_FRAME:AddMessage(itemlink);
		local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(itemlink);
		if (iRarity >= lootThreshhold) then
			table.insert(ELOOTSTRINGS, GetLootSlotLink(i));
		end
	end
	
	
	
	for i=1, #ELOOTSTRINGS do
		local t1 = {};
		table.insert(ELOOTPLAYERS, t1);
		local t2 = {};
		table.insert(ELOOTPLAYERCUR, t2);
		local t3 = {};
		table.insert(ELOOTITEMREQUESTEDBYPLAYER, t3);
		
	end
	ELoot:SendStartSession();
--[[	ELOOTPLAYERS[1][1] = "Item 1 needed by player 1";
	ELOOTPLAYERCUR[1][1] = "Item 1 needed by player 1 ILVL";
	ELOOTPLAYERS[1][2] = "Item 1 needed by player 2";
	ELOOTPLAYERCUR[1][2] = "Item 1 needed by player 2 ILVL";
	ELOOTPLAYERS[2][1] = "Item 2 needed by player 1";
	ELOOTPLAYERCUR[2][1] = "Item 2 needed by player 1 ILVL";
	
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERS[1][1]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERCUR[1][1]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERS[1][2]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERCUR[1][2]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERS[2][1]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERCUR[2][1]);]]--
	ELootItemsScrollFrame_Update();
	ELootItemsPrint("RAID");
	
 end

 function ELoot:SendClearToSessionClients()
 --DEFAULT_CHAT_FRAME:AddMessage("sending clear2");
	for i=1, #RaidersWithELoot do
		if (UnitName("player") == RaidersWithELoot[i]) then
			--lets not forward to ourselves; nothing here!
			--DEFAULT_CHAT_FRAME:AddMessage("skipping sending clear to ourselves");
		else
			local sendstring = "sessionid:"..sessionID.."|sessionHost:"..sessionHost.."|";
			--DEFAULT_CHAT_FRAME:AddMessage("ELOOTCLEAR[" .. sendstring .. "] to " .. RaidersWithELoot[i]);
			ELoot:SendCommMessage("ELOOTCLEAR", sendstring, "WHISPER", RaidersWithELoot[i]);
		end
	end
 end
 
 function ELootClear_OnClick()
	StaticPopup_Show ("ELOOT_CONFIRMCLEAR");
 end
 
 function ELootClearSession()
	--DEFAULT_CHAT_FRAME:AddMessage("starting clear");
	if (sessionHost == UnitName("player")) then
		--DEFAULT_CHAT_FRAME:AddMessage("sending clear");
		ELoot:SendClearToSessionClients();
	end
	itemSelected = 0;
	ELOOTSTRINGS = { };
	ELOOTPLAYERS = { };
	ELOOTPLAYERCUR = { };
	ELOOTITEMREQUESTEDBYPLAYER = { };
	RaidersWithELoot = {};
	ELootItemsScrollFrame_Update();
	ELootPlayersScrollFrame_Update();
	HideUIPanel(ItemRefTooltip);
	
	ELoot_UpdateUsers();
	sessionHost = nil;
	ELoot:CheckRaidersForELoot();
	DEFAULT_CHAT_FRAME:AddMessage("E-Loot: Session cleared.");
 end
 
 
 function ELootTest()
	DEFAULT_CHAT_FRAME:AddMessage("ELOOT TEST");
	ELOOTSTRINGS = { };
	ELOOTPLAYERS = { };
	ELOOTPLAYERCUR = { };
	ELOOTITEMREQUESTEDBYPLAYER = { };
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
	
--[[	ELOOTPLAYERS[1][1] = "Item 1 needed by player 1";
	ELOOTPLAYERCUR[1][1] = "Item 1 needed by player 1 ILVL";
	ELOOTPLAYERS[1][2] = "Item 1 needed by player 2";
	ELOOTPLAYERCUR[1][2] = "Item 1 needed by player 2 ILVL";
	ELOOTPLAYERS[2][1] = "Item 2 needed by player 1";
	ELOOTPLAYERCUR[2][1] = "Item 2 needed by player 1 ILVL";
	
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERS[1][1]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERCUR[1][1]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERS[1][2]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERCUR[1][2]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERS[2][1]);
	DEFAULT_CHAT_FRAME:AddMessage(ELOOTPLAYERCUR[2][1]);]]--
	ELootItemsScrollFrame_Update();
	
	ELootItemsPrint("RAID");
	
 end
 

 
