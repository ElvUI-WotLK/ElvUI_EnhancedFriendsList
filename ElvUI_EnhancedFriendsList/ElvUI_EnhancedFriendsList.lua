local E, L, V, P, G = unpack(ElvUI)
local EFL = E:NewModule("EnhancedFriendsList")
local EP = LibStub("LibElvUIPlugin-1.0")
local LSM = LibStub("LibSharedMedia-3.0", true)
local addonName = ...

local pairs, ipairs = pairs, ipairs
local format = format

local IsChatAFK = IsChatAFK
local IsChatDND = IsChatDND
local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumFriends = GetNumFriends
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
		get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
		set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value end,
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
				args = {
					showBackground = {
						order = 1,
						type = "toggle",
						name = L["Show Background"],
						set = function(info, value) E.db.enhanceFriendsList.showBackground = value EFL:EnhanceFriends() end
					},
					showStatusIcon = {
						order = 2,
						type = "toggle",
						name = L["Show Status Icon"],
						set = function(info, value) E.db.enhanceFriendsList.showStatusIcon = value EFL:EnhanceFriends() end
					},
					statusIcons = {
						order = 3,
						type = "select",
						name = L["Status Icons Textures"],
						values = {
							["Default"] = "Default",
							["Square"] = "Square",
							["D3"] = "Diablo 3"
						},
						set = function(info, value) E.db.enhanceFriendsList.statusIcons = value EFL:EnhanceFriends() EFL:FriendDropdownUpdate() end
					},
					nameFont = {
						order = 4,
						type = "group",
						name = L["Name Font"],
						guiInline = true,
						args = {
							nameFont = {
								order = 1,
								type = "select", dialogControl = "LSM30_Font",
								name = L["Font"],
								values = AceGUIWidgetLSMlists.font,
								set = function(info, value) E.db.enhanceFriendsList.nameFont = value EFL:EnhanceFriends() end
							},
							nameFontSize = {
								order = 2,
								type = "range",
								name = FONT_SIZE,
								min = 6, max = 22, step = 1,
								set = function(info, value) E.db.enhanceFriendsList.nameFontSize = value EFL:EnhanceFriends() end
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
								},
								set = function(info, value) E.db.enhanceFriendsList.nameFontOutline = value EFL:EnhanceFriends() end
							}
						}
					},
					zoneFont = {
						order = 5,
						type = "group",
						name = L["Zone Font"],
						guiInline = true,
						args = {
							zoneFont = {
								order = 1,
								type = "select", dialogControl = "LSM30_Font",
								name = L["Font"],
								values = AceGUIWidgetLSMlists.font,
								set = function(info, value) E.db.enhanceFriendsList.zoneFont = value EFL:EnhanceFriends() end
							},
							zoneFontSize = {
								order = 2,
								type = "range",
								name = FONT_SIZE,
								min = 6, max = 22, step = 1,
								set = function(info, value) E.db.enhanceFriendsList.zoneFontSize = value EFL:EnhanceFriends() end
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
								},
								set = function(info, value) E.db.enhanceFriendsList.zoneFontOutline = value EFL:EnhanceFriends() end
							}
						}
					}
				}
			},
			onlineFriends = {
				order = 3,
				type = "group",
				name = L["Online Friends"],
				args = {
					enhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedName = value EFL:EnhanceFriends() end
					},
					colorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						set = function(info, value) E.db.enhanceFriendsList.colorizeNameOnly = value EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.enhancedName end
					},
					hideClass = {
						order = 3,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideClass = value EFL:EnhanceFriends() end
					},
					enhancedZone = {
						order = 4,
						type = "toggle",
						name = L["Enhanced Zone"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedZone = value EFL:EnhanceFriends() end
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
							EFL:EnhanceFriends()
						end,
						disabled = function() return not E.db.enhanceFriendsList.enhancedZone end
					},
					levelColor = {
						order = 6,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.levelColor = value EFL:EnhanceFriends() end
					},
					sameZone = {
						order = 7,
						type = "toggle",
						name = L["Same Zone"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."],
						set = function(info, value) E.db.enhanceFriendsList.sameZone = value EFL:EnhanceFriends() end
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
							EFL:EnhanceFriends()
						end,
						disabled = function() return not E.db.enhanceFriendsList.sameZone end
					},
					hideLevelText = {
						order = 9,
						type = "toggle",
						name = L["Hide Level Text"],
						desc = L["Hides the 'Level' or 'L' text."],
						set = function(info, value) E.db.enhanceFriendsList.hideLevelText = value EFL:EnhanceFriends() end
					},
					shortLevel = {
						order = 10,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.shortLevel = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.hideLevelText end
					}
				}
			},
			offlineFriends = {
				order = 4,
				type = "group",
				name = L["Offline Friends"],
				args = {
					offlineEnhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.offlineEnhancedName = value EFL:EnhanceFriends() end
					},
					offlineColorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						set = function(info, value) E.db.enhanceFriendsList.offlineColorizeNameOnly = value EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.offlineEnhancedName end
					},
					offlineHideClass = {
						order = 3,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.offlineHideClass = value EFL:EnhanceFriends() end
					},
					offlineHideLevel = {
						order = 4,
						type = "toggle",
						name = L["Hide Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineHideLevel = value EFL:EnhanceFriends() end
					},
					offlineLevelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.offlineLevelColor = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineHideLevelText = {
						order = 6,
						type = "toggle",
						name = L["Hide Level Text"],
						desc = L["Hides the 'Level' or 'L' text."],
						set = function(info, value) E.db.enhanceFriendsList.offlineHideLevelText = value EFL:EnhanceFriends() end
					},
					offlineShortLevel = {
						order = 7,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShortLevel = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevelText or E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineShowZone = {
						order = 8,
						type = "toggle",
						name = L["Show Zone"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowZone = value EFL:EnhanceFriends() end
					},
					offlineShowLastSeen = {
						order = 9,
						type = "toggle",
						name = L["Show Last Seen"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowLastSeen = value EFL:EnhanceFriends() end
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

local function GetClassColorHex(class, offline)
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if class == v then
			class = k
		end
	end
	if Locale ~= "enUS" then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if class == v then
				class = k
			end
		end
	end

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if color then
		return offline and format("|cff%02x%02x%02x", color.r*160, color.g*160, color.b*160) or format("|cff%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	else
		return offline and "|cFFAFAFAF" or "|cFFFFFFFF"
	end
end

local function HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 5, 6), string.sub(hex, 7, 8), string.sub(hex, 9, 10)
	return tonumber(rhex, 16)/225, tonumber(ghex, 16)/225, tonumber(bhex, 16)/225
end

function EFL:EnhanceFriends()
	local db = E.db.enhanceFriendsList
	local levelTemplate = db.shortLevel and L["SHORT_LEVEL_TEMPLATE"] or L["LEVEL_TEMPLATE"]
	local offlineLevelTemplate = db.offlineShortLevel and L["SHORT_LEVEL_TEMPLATE"] or L["LEVEL_TEMPLATE"]

	local scrollFrame = FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button
	local name, level, class, area, connected, status
	local enhancedName, enhancedLevel, enhancedClass
	local playerZone = GetRealZoneText()

	for i = 1, numButtons do
		button = buttons[i]
		local Cooperate = false
		local colorHex, r, g, b, nameText, nameColor, infoText

		if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
			name, level, class, area, connected, status = GetFriendInfo(button.id)
			if not name then return end

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

				colorHex = GetClassColorHex(class)
				enhancedName = db.enhancedName and colorHex..name.."|r" or name
				enhancedLevel = format(db.hideLevelText and "%s" or levelTemplate, db.levelColor and GetLevelDiffColorHex(level)..level.."|r" or level).." "
				enhancedClass = db.hideClass and "" or class

				nameText = enhancedName..(db.enhancedName and " - " or ", ")..enhancedLevel..enhancedClass

				if db.enhancedName then
					if db.colorizeNameOnly then
						nameColor = HIGHLIGHT_FONT_COLOR
					else
						r, g, b = HexToRGB(colorHex)
						nameColor = {r = r, g = g, b = b}
					end
				else
					nameColor = FRIENDS_WOW_NAME_COLOR
				end

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

				if db.offlineEnhancedName then
					if db.offlineColorizeNameOnly then
						nameColor = FRIENDS_GRAY_COLOR
					else
						if colorHex then
							r, g, b = HexToRGB(colorHex)
							nameColor = {r = r, g = g, b = b}
						else
							nameColor = FRIENDS_GRAY_COLOR
						end
					end
				else
					nameColor = FRIENDS_GRAY_COLOR
				end
			end
		end

		if nameText then
			button.name:SetText(nameText)
			button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
			button.info:SetText(infoText)
			button.info:SetTextColor(0.49, 0.52, 0.54)
			if Cooperate then
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

function EFL:FriendDropdownUpdate()
	local status
	status = (StatusIcons[E.db.enhanceFriendsList.statusIcons][(UnitIsDND("Player") and "DND" or UnitIsAFK("Player") and "AFK" or "Online")])

	FriendsFrameStatusDropDownStatus:SetTexture(status)
end

function EFL:FriendListUpdate()
	if not ElvCharacterDB.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = {}
	end

	if E.global.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = E.global.EnhancedFriendsList_Data
		E.global.EnhancedFriendsList_Data = nil
	end

	hooksecurefunc("DynamicScrollFrame_Update", EFL.EnhanceFriends)
	hooksecurefunc("FriendsList_Update", EFL.EnhanceFriends)
	hooksecurefunc("FriendsFrameStatusDropDown_Update", EFL.FriendDropdownUpdate)
end

function EFL:Initialize()
	EP:RegisterPlugin(addonName, EFL.InsertOptions)

	EFL:FriendListUpdate()
end

local function InitializeCallback()
	EFL:Initialize()
end

E:RegisterModule(EFL:GetName(), InitializeCallback)