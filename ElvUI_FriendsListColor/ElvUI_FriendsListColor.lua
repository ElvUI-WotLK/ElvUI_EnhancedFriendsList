local addonName = ...;
local E, L, V, P, G = unpack(ElvUI);
local EP = LibStub("LibElvUIPlugin-1.0");
local mod = E:NewModule("FriendsListColor", "AceHook-3.0");

local GetFriendInfo = GetFriendInfo;
local GetNumFriends = GetNumFriends;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW;
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE;
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE;
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

local locclasses = {};
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do locclasses[v] = k; end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do locclasses[v] = k; end

function mod:FriendsList_Update()
	if(GetNumFriends() < 1) then return; end
	local name, level, class, zone, connected, status, note, color;
	for i = 1, GetNumFriends() do
		local friend = _G["FriendsFrameFriendsScrollFrameButton" .. i];
		if(friend.id and friend.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
			name, level, class, zone, connected, status, note = GetFriendInfo(friend.id);
			color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[locclasses[class]] or RAID_CLASS_COLORS[locclasses[class]];
			if(connected) then
				--local diffColor = GetQuestDifficultyColor(level);
				--print(format("%s%s|r", E:RGBToHex(diffColor.r, diffColor.g, diffColor.b), name));
				friend.name:SetText(format("%s%s|r", E:RGBToHex(color.r, color.g, color.b), name) .. ", " .. format(FRIENDS_LEVEL_TEMPLATE, level, class));
				ElvCharacterDB.FriendsListColor[name] = {level, class, zone};
			else
				if(ElvCharacterDB.FriendsListColor[name]) then
					level, class, zone = unpack(ElvCharacterDB.FriendsListColor[name])
					color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[locclasses[class]] or RAID_CLASS_COLORS[locclasses[class]];
					friend.name:SetText(format("%s%s|r", E:RGBToHex(color.r, color.g, color.b), name) .. ", " .. format(FRIENDS_LEVEL_TEMPLATE, level, class));
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