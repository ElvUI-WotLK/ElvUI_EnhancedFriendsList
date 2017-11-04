local E, L, V, P, G = unpack(ElvUI)
local EFL = E:NewModule("EnhancedFriendsList", "AceHook-3.0")
local EP = LibStub("LibElvUIPlugin-1.0")
local LSM = LibStub("LibSharedMedia-3.0", true)
local addonName = ...

local pairs, ipairs = pairs, ipairs
local format = format

local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local LEVEL = LEVEL
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local StatusIcons = {
	Default = {
		Online = FRIENDS_TEXTURE_ONLINE,
		Offline = FRIENDS_TEXTURE_OFFLINE,
		DND = FRIENDS_TEXTURE_DND,
		AFK = FRIENDS_TEXTURE_AFK
	},
	Square = {
		Online = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\Online",
		Offline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\Offline",
		DND	= "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\DND",
		AFK	= "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\AFK"
	},
	D3 = {
		Online = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\Online",
		Offline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\Offline",
		DND = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\DND",
		AFK = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\AFK"
	}
}

local Locale = GetLocale()

-- Profile
P["enhanceFriendsList"] = {
	-- General
	["showBackground"] = true,
	["showStatusIcon"] = true,
	["statusIcons"] = "Default",
	["nameFont"] = "PT Sans Narrow",
	["nameFontSize"] = 12,
	["nameFontOutline"] = "NONE",
	["zoneFont"] = "PT Sans Narrow",
	["zoneFontSize"] = 12,
	["zoneFontOutline"] = "NONE",

	["Online"] = {
		["enhancedName"] = false,
		["colorizeNameOnly"] = false,
		["enhancedZone"] = false,
		["enhancedZoneColor"] = {r = 1, g = 0.96, b = 0.45},
		["classText"] = true,
		["level"] = true,
		["levelColor"] = false,
		["levelText"] = false,
		["shortLevel"] = false,
		["sameZone"] = false,
		["sameZoneColor"] = {r = 0.3, g = 1.0, b = 0.3},
		["classIcon"] = false,
	},
	["Offline"] = {
		["enhancedName"] = false,
		["colorizeNameOnly"] = false,
		["classText"] = false,
		["level"] = false,
		["levelColor"] = false,
		["levelText"] = false,
		["shortLevel"] = false,
		["zoneText"] = true,
		["lastSeen"] = true,
		["classIcon"] = false,
	}
}

-- Options
local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName)
end

function EFL:InsertOptions()
	E.Options.args.enhanceFriendsList = {
		order = 54,
		type = "group",
		childGroups = "tab",
		name = ColorizeSettingName(L["Enhanced Friends List"]),
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Enhanced Friends List"]
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
				set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; EFL:Update(); FriendsList_Update(); FriendsFrameStatusDropDown_Update() end,
				args = {
					showBackground = {
						order = 1,
						type = "toggle",
						name = L["Show Background"]
					},
					showStatusIcon = {
						order = 2,
						type = "toggle",
						name = L["Show Status Icon"]
					},
					statusIcons = {
						order = 3,
						type = "select",
						name = L["Status Icons Textures"],
						values = {
							["Default"] = "Default",
							["Square"] = "Square",
							["D3"] = "Diablo 3"
						}
					},
					nameFont = {
						order = 4,
						type = "group",
						name = L["Name Font"],
						guiInline = true,
						get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
						set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; EFL:Update(); FriendsList_Update() end,
						args = {
							nameFont = {
								order = 1,
								type = "select", dialogControl = "LSM30_Font",
								name = L["Font"],
								values = AceGUIWidgetLSMlists.font
							},
							nameFontSize = {
								order = 2,
								type = "range",
								name = FONT_SIZE,
								min = 6, max = 22, step = 1
							},
							nameFontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = {
									["NONE"] = NONE,
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE"
								}
							}
						}
					},
					zoneFont = {
						order = 5,
						type = "group",
						name = L["Zone Font"],
						guiInline = true,
						get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
						set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; EFL:Update(); FriendsList_Update() end,
						args = {
							zoneFont = {
								order = 1,
								type = "select", dialogControl = "LSM30_Font",
								name = L["Font"],
								values = AceGUIWidgetLSMlists.font
							},
							zoneFontSize = {
								order = 2,
								type = "range",
								name = FONT_SIZE,
								min = 6, max = 22, step = 1
							},
							zoneFontOutline = {
								order = 3,
								type = "select",
								name = L["Font Outline"],
								desc = L["Set the font outline."],
								values = {
									["NONE"] = NONE,
									["OUTLINE"] = "OUTLINE",
									["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
									["THICKOUTLINE"] = "THICKOUTLINE"
								}
							}
						}
					}
				}
			},
			Online = {
				order = 3,
				type = "group",
				name = L["Online Friends"],
				get = function(info) return E.db.enhanceFriendsList.Online[ info[#info] ] end,
				set = function(info, value) E.db.enhanceFriendsList.Online[ info[#info] ] = value; EFL:Update(); FriendsList_Update() end,
				args = {
					enhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"]
					},
					colorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						disabled = function() return not E.db.enhanceFriendsList.enhancedName end
					},
					classText = {
						order = 3,
						type = "toggle",
						name = L["Class Text"]
					},
					level = {
						order = 4,
						type = "toggle",
						name = L["Level"]
					},
					levelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"]
					},
					levelText = {
						order = 6,
						type = "toggle",
						name = L["Level Text"],
						desc = L["Hides the 'Level' or 'L' text."]
					},
					shortLevel = {
						order = 7,
						type = "toggle",
						name = L["Short Level"],
					},
					enhancedZone = {
						order = 8,
						type = "toggle",
						name = L["Enhanced Zone"]
					},
					enhancedZoneColor = {
						order = 9,
						type = "color",
						name = L["Enhanced Zone Color"],
						get = function(info)
							local t = E.db.enhanceFriendsList.Online.enhancedZoneColor
							local d = P.enhanceFriendsList.Online.enhancedZoneColor
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.enhanceFriendsList.Online.enhancedZoneColor
							t.r, t.g, t.b = r, g, b
							FriendsList_Update()
						end,
					},
					sameZone = {
						order = 10,
						type = "toggle",
						name = L["Same Zone"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."]
					},
					sameZoneColor = {
						order = 11,
						type = "color",
						name = L["Same Zone Color"],
						get = function(info)
							local t = E.db.enhanceFriendsList.Online.sameZoneColor
							local d = P.enhanceFriendsList.Online.sameZoneColor
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.enhanceFriendsList.Online.sameZoneColor
							t.r, t.g, t.b = r, g, b
							FriendsList_Update()
						end,
					},
					classIcon = {
						order = 12,
						type = "toggle",
						name = L["Class Icon"]
					}
				}
			},
			Offline = {
				order = 4,
				type = "group",
				name = L["Offline Friends"],
				get = function(info) return E.db.enhanceFriendsList.Offline[ info[#info] ] end,
				set = function(info, value) E.db.enhanceFriendsList.Offline[ info[#info] ] = value; EFL:Update(); FriendsList_Update() end,
				args = {
					enhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"]
					},
					colorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
					},
					classText = {
						order = 3,
						type = "toggle",
						name = L["Class Text"]
					},
					level = {
						order = 4,
						type = "toggle",
						name = L["Level"]
					},
					levelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
					},
					levelText = {
						order = 6,
						type = "toggle",
						name = L["Hide Level Text"],
						desc = L["Hides the 'Level' or 'L' text."]
					},
					shortLevel = {
						order = 7,
						type = "toggle",
						name = L["Short Level"],
					},
					zoneText = {
						order = 8,
						type = "toggle",
						name = L["Zone Text"]
					},
					lastSeen = {
						order = 9,
						type = "toggle",
						name = L["Last Seen"]
					},
					classIcon = {
						order = 10,
						type = "toggle",
						name = L["Class Icon"]
					}
				}
			}
		}
	}
end

local function timeDiff(t2, t1)
	if t2 < t1 then return end

	local d1, d2, carry, diff = date("*t", t1), date("*t", t2), false, {}
	local colMax = {60, 60, 24, date("*t", time{year = d1.year,month = d1.month + 1, day = 0}).day, 12}

	d2.hour = d2.hour - (d2.isdst and 1 or 0) + (d1.isdst and 1 or 0)
	for i, v in ipairs({"sec", "min", "hour", "day", "month", "year"}) do
		diff[v] = d2[v] - d1[v] + (carry and -1 or 0)
		carry = diff[v] < 0
		if carry then diff[v] = diff[v] + colMax[i] end
	end

	return diff
end

local function GetLevelDiffColorHex(level, offline)
	if level ~= 0 then
		local color = GetQuestDifficultyColor(level)
		return offline and format("|cFF%02x%02x%02x", color.r*160, color.g*160, color.b*160) or format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	else
		return offline and "|cFFAFAFAF" or "|cFFFFFFFF"
	end
end

local localizedTable = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	localizedTable[v] = k
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	localizedTable[v] = k
end

local function GetClassColorHex(class, offline)
	class = localizedTable[class]

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if color then
		return offline and format("|cff%02x%02x%02x", color.r*160, color.g*160, color.b*160) or format("|cff%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	else
		return offline and "|cFFAFAFAF" or "|cFFFFFFFF"
	end
end

local function HexToRGB(hex)
	if not hex then return nil end

	local rhex, ghex, bhex = string.sub(hex, 5, 6), string.sub(hex, 7, 8), string.sub(hex, 9, 10)
	return {r = tonumber(rhex, 16)/225, g = tonumber(ghex, 16)/225, b = tonumber(bhex, 16)/225}
end

function EFL:Update()
	for i = 1, #FriendsFrameFriendsScrollFrame.buttons do
		local button = FriendsFrameFriendsScrollFrame.buttons[i]

		self:Configure_Background(button)

		self:Configure_Status(button)

		self:Configure_IconFrame(button)

		button.name:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.nameFont), E.db.enhanceFriendsList.nameFontSize, E.db.enhanceFriendsList.nameFontOutline)
		button.info:SetFont(LSM:Fetch("font", E.db.enhanceFriendsList.zoneFont), E.db.enhanceFriendsList.zoneFontSize, E.db.enhanceFriendsList.zoneFontOutline)
	end
end

-- Status
function EFL:Update_Status(button)
	if not E.db.enhanceFriendsList.showStatusIcon then return end

	if button.TYPE == "Online" then
		button.status:SetTexture(StatusIcons[E.db.enhanceFriendsList.statusIcons][(button.statusType == CHAT_FLAG_DND and "DND" or button.statusType == CHAT_FLAG_AFK and "AFK" or "Online")])
	else
		button.status:SetTexture(StatusIcons[E.db.enhanceFriendsList.statusIcons].Offline)
	end
end

function EFL:Configure_Status(button)
	if E.db.enhanceFriendsList.showStatusIcon then
		button.status:Show()
	else
		button.status:Hide()
	end
end

-- Name
function EFL:Update_Name(button)
	local infoText
	local isOffline = button.TYPE == "Offline" or false

	local enhancedName = (self.db[button.TYPE].enhancedName and GetClassColorHex(button.class, isOffline)..button.nameText.."|r" or button.nameText)
	local enhancedLevel = self.db[button.TYPE].level and format(self.db[button.TYPE].levelText and "%s" or self.db[button.TYPE].shortLevel and L["SHORT_LEVEL_TEMPLATE"] or L["LEVEL_TEMPLATE"], self.db[button.TYPE].levelColor and GetLevelDiffColorHex(button.levelText, isOffline)..button.levelText.."|r" or button.levelText).." " or ""
	local enhancedClass = self.db[button.TYPE].classText and button.class or ""
	button.name:SetText(enhancedName..((self.db[button.TYPE].level or self.db[button.TYPE].classText) and (self.db[button.TYPE].enhancedName and " - " or ", ") or "")..enhancedLevel..enhancedClass)

	local nameColor = self.db[button.TYPE].enhancedName and (self.db[button.TYPE].colorizeNameOnly and (isOffline and FRIENDS_GRAY_COLOR or HIGHLIGHT_FONT_COLOR) or HexToRGB(GetClassColorHex(button.class, isOffline))) or (isOffline and FRIENDS_GRAY_COLOR or FRIENDS_WOW_NAME_COLOR)
	button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)

	if isOffline then
		if ElvCharacterDB.EnhancedFriendsList_Data[button.nameText] then
			local td = timeDiff(time(), tonumber(ElvCharacterDB.EnhancedFriendsList_Data[button.nameText].lastSeen))

			infoText = (self.db[button.TYPE].zoneText and button.area..(self.db[button.TYPE].lastSeen and " - " or "") or "")..(self.db[button.TYPE].lastSeen and L["Last seen"].." "..RecentTimeDate(td.year, td.month, td.day, td.hour) or "")
		else
			infoText = button.area
		end

		button.info:SetTextColor(0.49, 0.52, 0.54)
	else
		infoText = button.area

		local playerZone = GetRealZoneText()
		if self.db[button.TYPE].enhancedZone then
			if self.db[button.TYPE].sameZone then
				if infoText == playerZone then
					button.info:SetTextColor(self.db[button.TYPE].sameZoneColor.r, self.db[button.TYPE].sameZoneColor.g, self.db[button.TYPE].sameZoneColor.b)
				else
					button.info:SetTextColor(self.db[button.TYPE].enhancedZoneColor.r, self.db[button.TYPE].enhancedZoneColor.g, self.db[button.TYPE].enhancedZoneColor.b)
				end
			else
				button.info:SetTextColor(self.db[button.TYPE].enhancedZoneColor.r, self.db[button.TYPE].enhancedZoneColor.g, self.db[button.TYPE].enhancedZoneColor.b)
			end
		else
			if self.db[button.TYPE].sameZone then
				if infoText == playerZone then
					button.info:SetTextColor(self.db[button.TYPE].sameZoneColor.r, self.db[button.TYPE].sameZoneColor.g, self.db[button.TYPE].sameZoneColor.b)
				else
					button.info:SetTextColor(0.49, 0.52, 0.54)
				end
			else
				button.info:SetTextColor(0.49, 0.52, 0.54)
			end
		end
	end

	button.info:SetText(infoText)

	button.name:ClearAllPoints()
	if button.iconFrame:IsShown() then
		button.name:Point("LEFT", button.iconFrame, "RIGHT", 3, 7)
	else
		if E.db.enhanceFriendsList.showStatusIcon then
			button.name:Point("TOPLEFT", 22, -3)
		else
			button.name:Point("TOPLEFT", 3, -3)
		end
	end
end

-- IconFrame
function EFL:Update_IconFrame(button)
	if E.db.enhanceFriendsList[button.TYPE].classIcon then
		local classFileName = localizedTable[button.class]
		if classFileName then
			button.iconFrame:Show()

			button.iconFrame.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
			button.iconFrame:SetAlpha(button.TYPE == "Online" and 1 or 0.6)
		else
			button.iconFrame:Hide()
		end
	elseif button.iconFrame:IsShown() then
		button.iconFrame:Hide()
	end
end

function EFL:Configure_IconFrame(button)
	button.iconFrame:ClearAllPoints()
	if E.db.enhanceFriendsList.showStatusIcon then
		button.iconFrame:Point("LEFT", 22, 0)
	else
		button.iconFrame:Point("LEFT", 3, 0)
	end
end

function EFL:Construct_IconFrame(button)
	button.iconFrame = CreateFrame("Frame", "$parentIconFrame", button)
	button.iconFrame:Size(26)
	button.iconFrame:SetTemplate("Default")

	button.iconFrame.texture = button.iconFrame:CreateTexture()
	button.iconFrame.texture:SetAllPoints()
	button.iconFrame.texture:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
	button.iconFrame:Hide()
end

-- Background
function EFL:Update_Background(button)
	if not E.db.enhanceFriendsList.showBackground then return end

	if button.TYPE == "Online" then
		button.backgroundLeft:SetGradientAlpha("Horizontal", 1,0.824,0,0.05, 1,0.824,0,0)
		button.backgroundRight:SetGradientAlpha("Horizontal", 1,0.824,0,0, 1,0.824,0,0.05)
	else
		button.backgroundLeft:SetGradientAlpha("Horizontal", 0.588,0.588,0.588,0.05, 0.588,0.588,0.588,0)
		button.backgroundRight:SetGradientAlpha("Horizontal", 0.588,0.588,0.588,0, 0.588,0.588,0.588,0.05)
	end
end

function EFL:Configure_Background(button)
	if E.db.enhanceFriendsList.showBackground then
		button.backgroundLeft:Show()
		button.backgroundRight:Show()
	else
		button.backgroundLeft:Hide()
		button.backgroundRight:Hide()
	end
end

function EFL:Construct_Background(button)
	button.backgroundLeft = button:CreateTexture(nil, "BACKGROUND")
	button.backgroundLeft:SetWidth(button:GetWidth() / 2)
	button.backgroundLeft:SetHeight(32)
	button.backgroundLeft:SetPoint("LEFT", button, "CENTER")
	button.backgroundLeft:SetTexture(E.media.blankTex)
	button.backgroundLeft:SetGradientAlpha("Horizontal", 1,0.824,0.0,0.05, 1,0.824,0.0,0)

	button.backgroundRight = button:CreateTexture(nil, "BACKGROUND")
	button.backgroundRight:SetWidth(button:GetWidth() / 2)
	button.backgroundRight:SetHeight(32)
	button.backgroundRight:SetPoint("RIGHT", button, "CENTER")
	button.backgroundRight:SetTexture(E.media.blankTex)
	button.backgroundRight:SetGradientAlpha("Horizontal", 1,0.824,0.0,0, 1,0.824,0.0,0.05)
end

-- Highlight
function EFL:Update_Highlight(button)
	if button.TYPE == "Online" then
		if button.statusType == "" then
			button.highlightLeft:SetGradientAlpha("Horizontal", 0.243,0.570,1,0.35, 0.243,0.570,1,0)
			button.highlightRight:SetGradientAlpha("Horizontal", 0.243,0.570,1,0, 0.243,0.570,1,0.35)
		elseif button.statusType == CHAT_FLAG_AFK then
			button.highlightLeft:SetGradientAlpha("Horizontal", 1,1,0,0.35, 1,1,0,0)
			button.highlightRight:SetGradientAlpha("Horizontal", 1,1,0,0, 1,1,0,0.35)
		elseif button.statusType == CHAT_FLAG_DND then
			button.highlightLeft:SetGradientAlpha("Horizontal", 1,0,0,0.35, 1,0,0,0)
			button.highlightRight:SetGradientAlpha("Horizontal", 1,0,0,0, 1,0,0,0.35)
		end
	else
		button.highlightLeft:SetGradientAlpha("Horizontal", 0.486,0.518,0.541,0.35, 0.486,0.518,0.541,0)
		button.highlightRight:SetGradientAlpha("Horizontal", 0.486,0.518,0.541,0, 0.486,0.518,0.541,0.35)
	end
end

function EFL:Construct_Highlight(button)
	button.highlightLeft = button:CreateTexture(nil, "HIGHLIGHT")
	button.highlightLeft:SetWidth(button:GetWidth() / 2)
	button.highlightLeft:SetHeight(32)
	button.highlightLeft:SetPoint("LEFT", button, "CENTER")
	button.highlightLeft:SetTexture(E.media.blankTex)
	button.highlightLeft:SetGradientAlpha("Horizontal", 0.243,0.570,1,0.35, 0.243,0.570,1,0)

	button.highlightRight = button:CreateTexture(nil, "HIGHLIGHT")
	button.highlightRight:SetWidth(button:GetWidth() / 2)
	button.highlightRight:SetHeight(32)
	button.highlightRight:SetPoint("RIGHT", button, "CENTER")
	button.highlightRight:SetTexture(E.media.blankTex)
	button.highlightRight:SetGradientAlpha("Horizontal", 0.243,0.570,1,0, 0.243,0.570,1,0.35)
end

function EFL:EnhanceFriends_SetButton(button, index, firstButton)
	local db = E.db.enhanceFriendsList
	local levelTemplate = db.shortLevel and L["SHORT_LEVEL_TEMPLATE"] or L["LEVEL_TEMPLATE"]
	local offlineLevelTemplate = db.offlineShortLevel and L["SHORT_LEVEL_TEMPLATE"] or L["LEVEL_TEMPLATE"]

	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local name, level, class, area, connected, status = GetFriendInfo(button.id)
		if not name then return end

		button.nameText = name
		button.TYPE = connected and "Online" or "Offline"
		button.statusType = status

		if connected then
			if not ElvCharacterDB.EnhancedFriendsList_Data[name] then
				ElvCharacterDB.EnhancedFriendsList_Data[name] = {}
			end

			ElvCharacterDB.EnhancedFriendsList_Data[name].level = level
			ElvCharacterDB.EnhancedFriendsList_Data[name].class = class
			ElvCharacterDB.EnhancedFriendsList_Data[name].area = area
			ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen = format("%i", time())
		else
			if ElvCharacterDB.EnhancedFriendsList_Data[name] then
				level = ElvCharacterDB.EnhancedFriendsList_Data[name].level
				class = ElvCharacterDB.EnhancedFriendsList_Data[name].class
				area = ElvCharacterDB.EnhancedFriendsList_Data[name].area
			end
		end

		button.levelText = level
		button.class = class
		button.area = area

		self:Update_Background(button)
		self:Update_Status(button)
		self:Update_IconFrame(button)
		self:Update_Name(button)
		self:Update_Highlight(button)
	end
end

function EFL:FriendsFrameStatusDropDown_Update()
	local status = (StatusIcons[E.db.enhanceFriendsList.statusIcons][(UnitIsDND("Player") and "DND" or UnitIsAFK("Player") and "AFK" or "Online")])
	FriendsFrameStatusDropDownStatus:SetTexture(status)
end

function EFL:FriendListUpdate()
	self.db = E.db.enhanceFriendsList

	if not ElvCharacterDB.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = {}
	end

	for i = 1, #FriendsFrameFriendsScrollFrame.buttons do
		local button = FriendsFrameFriendsScrollFrame.buttons[i]

		self:Construct_IconFrame(button)

		self:Construct_Background(button)
		button.background:Hide()

		self:Construct_Highlight(button)
		button.highlight:SetVertexColor(0, 0, 0, 0)
	end

	self:Update()

	self:SecureHook("FriendsFrameStatusDropDown_Update")
	self:SecureHook(FriendsFrameFriendsScrollFrame, "buttonFunc", "EnhanceFriends_SetButton")
end

function EFL:Initialize()
	EP:RegisterPlugin(addonName, EFL.InsertOptions)

	EFL:FriendListUpdate()
end

local function InitializeCallback()
	EFL:Initialize()
end

E:RegisterModule(EFL:GetName(), InitializeCallback)