local addonName = ...;
local E, L, V, P, G = unpack(ElvUI);
local EP = LibStub("LibElvUIPlugin-1.0");
local mod = E:NewModule("FriendsListColor", "AceHook-3.0");

local _G = _G;
local unpack, pairs = unpack, pairs;

local GetFriendInfo = GetFriendInfo;
local GetNumFriends = GetNumFriends;
local GetQuestDifficultyColor = GetQuestDifficultyColor;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW;
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE;
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

local locale = GetLocale();
local textFormat = locale == "ruRU" and "%s%s|r, %s%s-го уровня" or locale == "deDE" and "%s%s|r, %sStufe %s" or "%s%s|r, %sLevel $s";

local locclasses = {};
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do locclasses[v] = k; end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do locclasses[v] = k; end

function mod:FriendsList_Update()
	if(GetNumFriends() < 1) then return; end
	local name, level, class, zone, connected, status, note, color, diffColor;
	for i = 1, GetNumFriends() do
		local friend = _G["FriendsFrameFriendsScrollFrameButton" .. i];
		if(friend.id and friend.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
			name, level, class, zone, connected, status, note = GetFriendInfo(friend.id);
			color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[locclasses[class]] or RAID_CLASS_COLORS[locclasses[class]];
			diffColor = GetQuestDifficultyColor(level);
			if(connected) then
				friend.name:SetFormattedText(textFormat, E:RGBToHex(color.r, color.g, color.b), name, E:RGBToHex(diffColor.r, diffColor.g, diffColor.b), level);
				ElvCharacterDB.FriendsListColor[name] = {level, class, zone};
			else
				if(ElvCharacterDB.FriendsListColor[name]) then
					level, class, zone = unpack(ElvCharacterDB.FriendsListColor[name]);
					color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[locclasses[class]] or RAID_CLASS_COLORS[locclasses[class]];
					diffColor = GetQuestDifficultyColor(level);
					friend.name:SetFormattedText(textFormat, E:RGBToHex(color.r*0.5, color.g*0.5, color.b*0.5), name, E:RGBToHex(diffColor.r*0.5, diffColor.g*0.5, diffColor.b*0.5), level);
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
	FriendsFrameFriendsScrollFrame:HookScript("OnVerticalScroll", function() mod:FriendsList_Update(); end);
	self:SecureHook("FriendsList_Update", "FriendsList_Update");
end

E:RegisterModule(mod:GetName());