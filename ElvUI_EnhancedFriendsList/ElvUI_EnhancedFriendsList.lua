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
	-- Online
	["classIconFrame"] = true,
	["enhancedName"] = false,
	["colorizeNameOnly"] = false,
	["enhancedZone"] = false,
	["enhancedZoneColor"] = {r = 1, g = 0.96, b = 0.45},
	["hideClass"] = false,
	["levelColor"] = false,
	["shortLevel"] = false,
	["hideLevelText"] = false,
	["sameZone"] = false,
	["sameZoneColor"] = {r = 0, g = 1, b = 0},
	-- Offline
	["offlineEnhancedName"] = false,
	["offlineColorizeNameOnly"] = false,
	["offlineHideClass"] = true,
	["offlineHideLevel"] = true,
	["offlineLevelColor"] = false,
	["offlineShortLevel"] = false,
	["offlineHideLevelText"] = false,
	["offlineShowZone"] = true,
	["offlineShowLastSeen"] = true,
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
				set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; FriendsList_Update(); FriendsFrameStatusDropDown_Update() end,
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
						set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; FriendsList_Update() end,
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
						set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; FriendsList_Update() end,
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
			onlineFriends = {
				order = 3,
				type = "group",
				name = L["Online Friends"],
				get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
				set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; FriendsList_Update() end,
				args = {
					classIconFrame = {
						order = 0,
						type = "toggle",
						name = L["Icon Frame"]
					},
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
					hideClass = {
						order = 3,
						type = "toggle",
						name = L["Hide Class Text"]
					},
					enhancedZone = {
						order = 4,
						type = "toggle",
						name = L["Enhanced Zone"]
					},
					enhancedZoneColor = {
						order = 5,
						type = "color",
						name = L["Enhanced Zone Color"],
						get = function(info)
							local t = E.db.enhanceFriendsList.enhancedZoneColor
							local d = P.enhanceFriendsList.enhancedZoneColor
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.enhanceFriendsList.enhancedZoneColor
							t.r, t.g, t.b = r, g, b
							FriendsList_Update()
						end,
						disabled = function() return not E.db.enhanceFriendsList.enhancedZone end
					},
					levelColor = {
						order = 6,
						type = "toggle",
						name = L["Level Range Color"]
					},
					sameZone = {
						order = 7,
						type = "toggle",
						name = L["Same Zone"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."]
					},
					sameZoneColor = {
						order = 8,
						type = "color",
						name = L["Same Zone Color"],
						get = function(info)
							local t = E.db.enhanceFriendsList.sameZoneColor
							local d = P.enhanceFriendsList.sameZoneColor
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.enhanceFriendsList.sameZoneColor
							t.r, t.g, t.b = r, g, b
							FriendsList_Update()
						end,
						disabled = function() return not E.db.enhanceFriendsList.sameZone end
					},
					hideLevelText = {
						order = 9,
						type = "toggle",
						name = L["Hide Level Text"],
						desc = L["Hides the 'Level' or 'L' text."]
					},
					shortLevel = {
						order = 10,
						type = "toggle",
						name = L["Short Level"],
						disabled = function() return E.db.enhanceFriendsList.hideLevelText end
					}
				}
			},
			offlineFriends = {
				order = 4,
				type = "group",
				name = L["Offline Friends"],
				get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
				set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value; FriendsList_Update() end,
				args = {
					offlineEnhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"]
					},
					offlineColorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						disabled = function() return not E.db.enhanceFriendsList.offlineEnhancedName end
					},
					offlineHideClass = {
						order = 3,
						type = "toggle",
						name = L["Hide Class Text"]
					},
					offlineHideLevel = {
						order = 4,
						type = "toggle",
						name = L["Hide Level"]
					},
					offlineLevelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineHideLevelText = {
						order = 6,
						type = "toggle",
						name = L["Hide Level Text"],
						desc = L["Hides the 'Level' or 'L' text."]
					},
					offlineShortLevel = {
						order = 7,
						type = "toggle",
						name = L["Short Level"],
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevelText or E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineShowZone = {
						order = 8,
						type = "toggle",
						name = L["Show Zone"]
					},
					offlineShowLastSeen = {
						order = 9,
						type = "toggle",
						name = L["Show Last Seen"]
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

function EFL:EnhanceFriends_SetButton(button, index, firstButton)
	local db = E.db.enhanceFriendsList
	local levelTemplate = db.shortLevel and L["SHORT_LEVEL_TEMPLATE"] or L["LEVEL_TEMPLATE"]
	local offlineLevelTemplate = db.offlineShortLevel and L["SHORT_LEVEL_TEMPLATE"] or L["LEVEL_TEMPLATE"]

	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local name, level, class, area, connected, status = GetFriendInfo(button.id)
		if not name then return end

		local enhancedName, enhancedLevel, enhancedClass
		local colorHex, nameText, nameColor, infoText
		local Cooperate = false

		if db.showBackground then
			button.background:Show()
		else
			button.background:Hide()
		end

		button.name:ClearAllPoints()
		if db.showStatusIcon then
			button.name:Point("TOPLEFT", 20, -3)
			button.status:Show()
		else
			button.status:Hide()
			button.name:Point("TOPLEFT", 3, -3)
		end

		infoText = area

		if connected then
			button.status:SetTexture(StatusIcons[db.statusIcons][(status == CHAT_FLAG_DND and "DND" or status == CHAT_FLAG_AFK and "AFK" or "Online")])

			if not ElvCharacterDB.EnhancedFriendsList_Data[name] then
				ElvCharacterDB.EnhancedFriendsList_Data[name] = {}
			end

			ElvCharacterDB.EnhancedFriendsList_Data[name].level = level
			ElvCharacterDB.EnhancedFriendsList_Data[name].class = class
			ElvCharacterDB.EnhancedFriendsList_Data[name].area = area
			ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen = format("%i", time())

			if db.classIconFrame then
				if not button.iconFrame then
					button.iconFrame = CreateFrame("Frame", nil, button)
					button.iconFrame:Size(22)
					button.iconFrame:SetTemplate("Default")

					button.iconFrame.texture = button.iconFrame:CreateTexture()
					button.iconFrame.texture:SetAllPoints()
					button.iconFrame.texture:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
				end

				button.name:ClearAllPoints()

				local classFileName = localizedTable[class]
				if classFileName then
					button.iconFrame:Show()
					if db.showStatusIcon then
						button.iconFrame:Point("LEFT", 20, 0)
					else
						button.iconFrame:Point("LEFT", 3, 0)
					end

					button.name:Point("LEFT", button.iconFrame, "RIGHT", 3, 7)

					button.iconFrame.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFileName]))
				else
					button.iconFrame:Hide()
					if db.showStatusIcon then
						button.name:Point("TOPLEFT", 20, -3)
					else
						button.name:Point("TOPLEFT", 3, -3)
					end
				end
			elseif button.iconFrame and button.iconFrame:IsShown() then
				button.iconFrame:Hide()
			end

			colorHex = GetClassColorHex(class)
			enhancedName = db.enhancedName and colorHex..name.."|r" or name
			enhancedLevel = format(db.hideLevelText and "%s" or levelTemplate, db.levelColor and GetLevelDiffColorHex(level)..level.."|r" or level).." "
			enhancedClass = db.hideClass and "" or class

			nameText = enhancedName..(db.enhancedName and " - " or ", ")..enhancedLevel..enhancedClass

			nameColor = db.enhancedName and (db.colorizeNameOnly and HIGHLIGHT_FONT_COLOR or HexToRGB(colorHex)) or FRIENDS_WOW_NAME_COLOR

			Cooperate = true
		else
			button.status:SetTexture(StatusIcons[db.statusIcons].Offline)

			if ElvCharacterDB.EnhancedFriendsList_Data[name] then
				local lastSeen = ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen
				local td = timeDiff(time(), tonumber(lastSeen))
				level = ElvCharacterDB.EnhancedFriendsList_Data[name].level
				class = ElvCharacterDB.EnhancedFriendsList_Data[name].class
				area = ElvCharacterDB.EnhancedFriendsList_Data[name].area

				colorHex = GetClassColorHex(class, true)

				enhancedName = db.offlineEnhancedName and colorHex..name.."|r" or name
				enhancedLevel = db.offlineHideLevel and "" or format(db.offlineHideLevelText and "%s" or offlineLevelTemplate, db.offlineLevelColor and GetLevelDiffColorHex(level, true)..level.."|r" or level).." "
				enhancedClass = db.offlineHideClass and "" or class

				nameText = enhancedName..(db.offlineHideClass and db.offlineHideLevel and "" or (db.offlineEnhancedName and " - " or ", "))..enhancedLevel..enhancedClass

				infoText = (db.offlineShowZone and area..(db.offlineShowLastSeen and " - " or "") or "")..(db.offlineShowLastSeen and L["Last seen"].." "..RecentTimeDate(td.year, td.month, td.day, td.hour) or "")
			else
				nameText = name
				infoText = area
			end

			nameColor = db.offlineEnhancedName and not db.offlineColorizeNameOnly and (HexToRGB(colorHex) or FRIENDS_GRAY_COLOR) or FRIENDS_GRAY_COLOR
		end

		if nameText then
			button.name:SetText(nameText)
			button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
			button.info:SetText(infoText)
			button.info:SetTextColor(0.49, 0.52, 0.54)
			if Cooperate then
				local playerZone = GetRealZoneText()

				if db.enhancedZone then
					if db.sameZone then
						if infoText == playerZone then
							button.info:SetTextColor(db.sameZoneColor.r, db.sameZoneColor.g, db.sameZoneColor.b)
						else
							button.info:SetTextColor(db.enhancedZoneColor.r, db.enhancedZoneColor.g, db.enhancedZoneColor.b)
						end
					else
						button.info:SetTextColor(db.enhancedZoneColor.r, db.enhancedZoneColor.g, db.enhancedZoneColor.b)
					end
				else
					if db.sameZone then
						if infoText == playerZone then
							button.info:SetTextColor(db.sameZoneColor.r, db.sameZoneColor.g, db.sameZoneColor.b)
						else
							button.info:SetTextColor(0.49, 0.52, 0.54)
						end
					else
						button.info:SetTextColor(0.49, 0.52, 0.54)
					end
				end
			end
			button.name:SetFont(LSM:Fetch("font", db.nameFont), db.nameFontSize, db.nameFontOutline)
			button.info:SetFont(LSM:Fetch("font", db.zoneFont), db.zoneFontSize, db.zoneFontOutline)
		end
	end
end

function EFL:FriendsFrameStatusDropDown_Update()
	local status = (StatusIcons[E.db.enhanceFriendsList.statusIcons][(UnitIsDND("Player") and "DND" or UnitIsAFK("Player") and "AFK" or "Online")])
	FriendsFrameStatusDropDownStatus:SetTexture(status)
end

function EFL:FriendListUpdate()
	if not ElvCharacterDB.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = {}
	end

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