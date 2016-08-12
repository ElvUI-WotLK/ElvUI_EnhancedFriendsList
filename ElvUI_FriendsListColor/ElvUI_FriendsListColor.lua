local addonName = ...;
local E, L, V, P, G = unpack(ElvUI);
local EP = LibStub("LibElvUIPlugin-1.0");
local mod = E:NewModule("FriendsListColor", "AceHook-3.0");

local syntaxes={
	{"N", "C", "L", "Z", "S", "O"},
	{"NC", "CC", "LC", "ZC", "SC", "OC"},
	{"ND", "CD", "LD", "ZD", "SD", "OD"},
	{"Name", "Class", "Level", "Zone", "AFK/DNS", "Note"},
};

local ccolors = {
	["HUNTER"] = "ABD473",
	["WARLOCK"] = "9482C9",
	["PRIEST"] = "FFFFFF",
	["PALADIN"] = "F58CBA",
	["MAGE"] = "69CCF0",
	["ROGUE"] = "FFF569",
	["DRUID"] = "FF7D0A",
	["SHAMAN"] = "2459FF",
	["WARRIOR"] = "C79C6E",
	["DEATHKNIGHT"] = "C41F3B"
};

local getDiff = function(tar)
	local diff, col = tar - UnitLevel("player")
	if diff > 4 then
	col = RED_FONT_COLOR_CODE
	elseif diff > 2 then
	col = ORANGE_FONT_COLOR_CODE -- need more orange, this is like /emote
	elseif diff >= 0 then
	col = YELLOW_FONT_COLOR_CODE
	elseif diff >= -4 then
	col = GREEN_FONT_COLOR_CODE -- too bright green
	else
	col = GRAY_FONT_COLOR_CODE
	end
	return col:sub(0,4) == "|cff" and col:sub(5) or col -- remove "|cff" if present (don't know what will happen in the future with these constants)
end

local locclasses = {}
for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE)do locclasses[v] = k end
for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE)do locclasses[v] = k end

local form = function(str, ...) -- ... = 1:name, 2:class, 3:level, 4:zone, 5:status, 6:note
	if not str or str:len() == 0 then
		return "Fatal error in "..cfg.sname..", what have you done?" -- something fatal happen, oh no!
	end
	local values, code = {...}
	if(#values > 0) then
    local dcolor = getDiff(values[3] or 0) -- with fallback value
    local ccolor = ccolors[(locclasses[values[2] or ""] or ""):gsub(" ",""):upper()] or GRAY_FONT_COLOR_CODE -- with fallback value
	-- handle double chars like $XY
	for code in str:gmatch("%$%u%u") do
	-- color by class
	for k,v in pairs(syntaxes[2]) do
	if code == "$"..v then
	str = str:gsub(code, format("|cff%s%s%s", ccolor, values[k] or "", FONT_COLOR_CODE_CLOSE))
	break
	end
	end
	-- color by difficulty
	for k,v in pairs(syntaxes[3]) do
	if code == "$"..v then
	str = str:gsub(code, format("|cff%s%s%s", dcolor, values[k] or "", FONT_COLOR_CODE_CLOSE))
	break
	end
	end
	end
	-- handle single chars like $X
	for code in str:gmatch("%$%u") do
	for k,v in pairs(syntaxes[1]) do
	if code == "$"..v then
	str = str:gsub(code, values[k] or "")
	break
	end
	end
	end
	-- global variables {!LEVEL} becomes "Level" localized or just pure string if it's not found in _G
	for code in str:gmatch("%{%!(.+)%}") do
	str = str:gsub("%{%!"..code.."%}", _G[code] and tostring(_G[code]) or code)
	end
	-- global variables {X!LEVEL} (where X is C or D) becomes "Level" localized or just pure string if it's not found in _G. it's also colored by class or difficulty color
	for code1, code2 in str:gmatch("%{(%u)%!(.+)%}") do
	if code1 == "C" then
	str = str:gsub("%{"..code1.."%!"..code2.."%}", format("|cff%s%s%s", ccolor, _G[code2] and tostring(_G[code2]) or code2, FONT_COLOR_CODE_CLOSE))
	elseif code1 == "D" then
	str = str:gsub("%{"..code1.."%!"..code2.."%}", format("|cff%s%s%s", dcolor, _G[code2] and tostring(_G[code2]) or code2, FONT_COLOR_CODE_CLOSE))
	else
	str = str:gsub("%{"..code1.."%!"..code2.."%}", _G[code2] and tostring(_G[code2]) or code2) -- fallback, no coloring
	end
	end
	end
	return str
end

function mod:FriendsList_Update()
	if(GetNumFriends() < 1) then return; end
	local tmp
	for i = 1, GetNumFriends() do
		local friend = _G["FriendsFrameFriendsScrollFrameButton" .. i];
		if(not friend.id) then return; end
		local name, level, class, zone, connected, status, note = GetFriendInfo(friend.id);
		if(connected) then
			if(friend and friend.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
				tmp = form("$NC, {D!LEVEL} $LD $OD", name, class, level, zone or "", status or "", note or "");
				friend.name:SetText(tmp)
				ElvCharacterDB.FriendsListColor[name] = {level, class, zone}
			end
		else
			if(friend and friend.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
				if(ElvCharacterDB.FriendsListColor[name]) then
					level, class, zone =  unpack(ElvCharacterDB.FriendsListColor[name]);
					tmp = form("$NC, {D!LEVEL} $LD $C", name, class, level, zone or "", status or "", note or "");
					
					friend.name:SetText(tmp);
					friend.info:SetText(zone);
				end
			end
		end
	end
end

function mod:Initialize()
	EP:RegisterPlugin(addonName, getOptions);

	if(not ElvCharacterDB.FriendsListColor) then
		ElvCharacterDB.FriendsListColor = {};
	end
	if(E.global.friendsListColor) then
		ElvCharacterDB.FriendsListColor = E.global.friendsListColor;
		E.global.friendsListColor = nil;
	end
	self:SecureHook("FriendsList_Update", "FriendsList_Update")
	self:SecureHook("FriendsFramePendingScrollFrame_AdjustScroll", "FriendsList_Update")
end

E:RegisterModule(mod:GetName());