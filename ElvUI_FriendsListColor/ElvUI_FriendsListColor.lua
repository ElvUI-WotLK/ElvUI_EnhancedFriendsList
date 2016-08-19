local addonName = ...;
local E, L, V, P, G = unpack(ElvUI);
local EP = LibStub("LibElvUIPlugin-1.0");
local mod = E:NewModule("FriendsListColor", "AceHook-3.0");

local _G = _G;
local unpack, pairs = unpack, pairs;

local GetFriendInfo = GetFriendInfo;
local GetNumFriends = GetNumFriends;
local GetQuestDifficultyColor = GetQuestDifficultyColor;
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS;
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW;
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE;
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

local classIcon = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:20:20:-1:0:64:64:%d:%d:%d:%d|t";
local locale = GetLocale();
local textFormat = 
locale == "ruRU" and "%s%s|r, %s%d-го уровня" or 
locale == "deDE" and "%s%s|r, %sStufe %d" or 
"%s%s|r, %sLevel %d";

textFormat = classIcon .. textFormat;

local locclasses = {};
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do locclasses[v] = k; end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do locclasses[v] = k; end

function mod:FriendsList_Update()
	if(GetNumFriends() < 1) then return; end
	local numButtons = #FriendsFrameFriendsScrollFrame.buttons;
	local name, level, class, zone, connected, status, note, color, diffColor;
	for i = 1, numButtons do
		local friend = _G["FriendsFrameFriendsScrollFrameButton" .. i];
		if(friend.id and friend.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
			name, level, class, zone, connected, status, note = GetFriendInfo(friend.id);
			if(connected) then
				left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[locclasses[class]]);
				color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[locclasses[class]] or RAID_CLASS_COLORS[locclasses[class]];
				diffColor = GetQuestDifficultyColor(level);
				friend.name:SetFormattedText(textFormat, (left + 0.024)*64, (right - 0.02)*64, (top + 0.018)*64, (bottom - 0.02)*64, E:RGBToHex(color.r, color.g, color.b), name, E:RGBToHex(diffColor.r, diffColor.g, diffColor.b), level);
				ElvCharacterDB.FriendsListColor[name] = {level, locclasses[class], zone, GetTime()};
			else
				if(ElvCharacterDB.FriendsListColor[name]) then
					level, class, zone = unpack(ElvCharacterDB.FriendsListColor[name]);
					left, right, top, bottom = unpack(CLASS_ICON_TCOORDS[class]);
					color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
					diffColor = GetQuestDifficultyColor(level);
					friend.name:SetFormattedText(textFormat, (left + 0.024)*64, (right - 0.02)*64, (top + 0.018)*64, (bottom - 0.02)*64, E:RGBToHex(color.r*0.5, color.g*0.5, color.b*0.5), name, E:RGBToHex(diffColor.r*0.5, diffColor.g*0.5, diffColor.b*0.5), level);
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
	else
		for n, t in pairs(ElvCharacterDB.FriendsListColor) do
			local level, class, zone = unpack(t);
			if(locclasses[class]) then
				t[2] = locclasses[class];
			end
		end
	end
	if(E.global.friendsListColor) then
		ElvCharacterDB.FriendsListColor = E.global.friendsListColor;
		E.global.friendsListColor = nil;
	end
	FriendsFrameFriendsScrollFrame:HookScript("OnVerticalScroll", function() mod:FriendsList_Update(); end);
	self:SecureHook("FriendsList_Update", "FriendsList_Update");
end

E:RegisterModule(mod:GetName());