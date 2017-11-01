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
	["statusIcons"] = "Square",
	["hideLevelText"] = false,
	-- Online
	["enhancedName"] = true,
	["colorizeNameOnly"] = false,
	["enhancedZone"] = false,
	["enhancedZoneColor"] = {r = 1, g = 0.96, b = 0.45},
	["hideClass"] = true,
	["levelColor"] = false,
	["shortLevel"] = true,
	["sameZone"] = true,
	["sameZoneColor"] = {r = 0, g = 1, b = 0},
	-- Offline
	["offlineEnhancedName"] = true,
	["offlineColorizeNameOnly"] = true,
	["offlineHideClass"] = true,
	["offlineHideLevel"] = false,
	["offlineLevelColor"] = false,
	["offlineShortLevel"] = true,
	["offlineShowZone"] = false,
	["offlineShowLastSeen"] = true,
	-- Name Text Font
	["nameFont"] = "PT Sans Narrow",
	["nameFontSize"] = 12,
	["nameFontOutline"] = "NONE",
	-- Zone Text Font
	["zoneFont"] = "PT Sans Narrow",
	["zoneFontSize"] = 12,
	["zoneFontOutline"] = "NONE"
}

-- Options
local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName)
end

function EFL:InsertOptions()
	E.Options.args.enhanceFriendsList = {
		order = 54,
		type = "group",
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
				guiInline = true,
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
					hideLevelText = {
						order = 4,
						type = "toggle",
						name = L["Hide Level or L Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideLevelText = value EFL:EnhanceFriends() end
					}
				}
			},
			onlineFriends = {
				order = 3,
				type = "group",
				name = L["Online Friends"],
				guiInline = true,
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
					shortLevel = {
						order = 9,
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
				guiInline = true,
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
					offlineShortLevel = {
						order = 6,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShortLevel = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineShowZone = {
						order = 7,
						type = "toggle",
						name = L["Show Zone"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowZone = value EFL:EnhanceFriends() end
					},
					offlineShowLastSeen = {
						order = 8,
						type = "toggle",
						name = L["Show Last Seen"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowLastSeen = value EFL:EnhanceFriends() end
					}
				}
			},
			font = {
				order = 5,
				type = "group",
				name = L["Font"],
				guiInline = true,
				args = {
					nameFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Name Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.nameFont = value EFL:EnhanceFriends() end
					},
					nameFontSize = {
						order = 2,
						type = "range",
						name = L["Name Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.nameFontSize = value EFL:EnhanceFriends() end
					},
					nameFontOutline = {
						order = 3,
						type = "select",
						name = L["Name Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						set = function(info, value) E.db.enhanceFriendsList.nameFontOutline = value EFL:EnhanceFriends() end
					},
					zoneFont = {
						order = 4,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Zone Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.zoneFont = value EFL:EnhanceFriends() end
					},
					zoneFontSize = {
						order = 5,
						type = "range",
						name = L["Zone Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.zoneFontSize = value EFL:EnhanceFriends() end
					},
					zoneFontOutline = {
						order = 6,
						type = "select",
						name = L["Zone Font Outline"],
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
	}
end

local function ClassColorCode(class)
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
	if not color then
		return format("|cFF%02x%02x%02x", 255, 255, 255)
	else
		return format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	end
end

local function OfflineColorCode(class)
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
	if not color then
		return format("|cFF%02x%02x%02x", 160, 160, 160)
	else
		return format("|cFF%02x%02x%02x", color.r*160, color.g*160, color.b*160)
	end
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

function EFL:EnhanceFriends()
	local db = E.db.enhanceFriendsList
	local scrollFrame = FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local name, level, class, area, connected, status
	local playerZone = GetRealZoneText()

	for i = 1, numButtons do
		local Cooperate = false
		local button = buttons[i]
		local nameText, nameColor, infoText, broadcastText

		if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
			name, level, class, area, connected, status = GetFriendInfo(button.id)
			if not name then return end

			local diff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or "|cFFFFFFFF"
			local shortLevel = db.shortLevel and L["SHORT_LEVEL"] or LEVEL

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
			broadcastText = nil

			if connected then
				button.status:SetTexture(StatusIcons[db.statusIcons][(status == CHAT_FLAG_DND and "DND" or status == CHAT_FLAG_AFK and "AFK" or "Online")])

				if not ElvCharacterDB.EnhancedFriendsList_Data[name] then
					ElvCharacterDB.EnhancedFriendsList_Data[name] = {}
				end

				ElvCharacterDB.EnhancedFriendsList_Data[name].level = level
				ElvCharacterDB.EnhancedFriendsList_Data[name].class = class
				ElvCharacterDB.EnhancedFriendsList_Data[name].area = area
				ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen = format("%i", time())

				if db.enhancedName then
					if db.colorizeNameOnly then
						if db.hideClass then
							if db.levelColor then
								if db.hideLevelText then
									nameText = format("%s%s|r|cffffffff - %s%s|r", ClassColorCode(class), name, diff, level)
								else
									nameText = format("%s%s|r|cffffffff - %s|r %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
								end
							else
								if db.hideLevelText then
									nameText = format("%s%s|r|cffffffff - %s|r", ClassColorCode(class), name, level)
								else
									nameText = format("%s%s|r|cffffffff - %s %s|r", ClassColorCode(class), name, shortLevel, level)
								end
							end
						else
							if db.levelColor then
								if db.hideLevelText then
									nameText = format("%s%s|r|cffffffff - %s%s|r|cffffffff %s|r", ClassColorCode(class), name, diff, level, class)
								else
									nameText = format("%s%s|r|cffffffff - %s|r %s%s|r|cffffffff %s|r", ClassColorCode(class), name, shortLevel, diff, level, class)
								end
							else
								if db.hideLevelText then
									nameText = format("%s%s|r|cffffffff - %s %s|r", ClassColorCode(class), name, level, class)
								else
									nameText = format("%s%s|r|cffffffff - %s %s %s|r", ClassColorCode(class), name, shortLevel, level, class)
								end
							end
						end
					else
						if db.hideClass then
							if db.levelColor then
								if db.hideLevelText then
									nameText = format("%s%s - %s%s|r", ClassColorCode(class), name, diff, level)
								else
									nameText = format("%s%s - %s %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
								end
							else
								if db.hideLevelText then
									nameText = format("%s%s - %s", ClassColorCode(class), name, level)
								else
									nameText = format("%s%s - %s %s", ClassColorCode(class), name, shortLevel, level)
								end
							end
						else
							if db.levelColor then
								if db.hideLevelText then
									nameText = format("%s%s - %s%s|r %s%s", ClassColorCode(class), name, diff, level, ClassColorCode(class), class)
								else
									nameText = format("%s%s - %s %s%s|r %s%s", ClassColorCode(class), name, shortLevel, diff, level, ClassColorCode(class), class)
								end
							else
								if db.hideLevelText then
									nameText = format("%s%s - %s %s", ClassColorCode(class), name, level, class)
								else
									nameText = format("%s%s - %s %s %s", ClassColorCode(class), name, shortLevel, level, class)
								end
							end
						end
					end
				else
					if db.hideClass then
						if db.levelColor then
							if db.hideLevelText then
								nameText = format("%s, %s%s|r", name, diff, level)
							else
								nameText = format("%s, %s %s%s|r", name, shortLevel, diff, level)
							end
						else
							if db.hideLevelText then
								nameText = format("%s, %s", name, level)
							else
								nameText = format("%s, %s %s", name, shortLevel, level)
							end
						end
					else
						if db.levelColor then
							if db.hideLevelText then
								nameText = format("%s, %s%s|r %s", name, diff, level, class)
							else
								nameText = format("%s, %s %s%s|r %s", name, shortLevel, diff, level, class)
							end
						else
							if db.hideLevelText then
								nameText = format("%s, %s %s", name, level, class)
							else
								nameText = format("%s, %s %s %s", name, shortLevel, level, class)
							end
						end
					end
				end

				nameColor = FRIENDS_WOW_NAME_COLOR
				Cooperate = true
			else
				button.status:SetTexture(StatusIcons[db.statusIcons].Offline)

				if ElvCharacterDB.EnhancedFriendsList_Data[name] then
					local lastSeen = ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen
					local td = timeDiff(time(), tonumber(lastSeen))
					level = ElvCharacterDB.EnhancedFriendsList_Data[name].level
					class = ElvCharacterDB.EnhancedFriendsList_Data[name].class
					area = ElvCharacterDB.EnhancedFriendsList_Data[name].area

					local offlineShortLevel = db.offlineShortLevel and L["SHORT_LEVEL"] or LEVEL
					local offlineDiff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 160, GetQuestDifficultyColor(level).g * 160, GetQuestDifficultyColor(level).b * 160) or "|cFFAFAFAF|r"
					local offlineDiffColor
					if db.offlineEnhancedName then
						if db.offlineColorizeNameOnly then
							offlineDiffColor = db.offlineLevelColor and offlineDiff or "|cFFAFAFAF|r"
						else
							offlineDiffColor = db.offlineLevelColor and offlineDiff or OfflineColorCode(class)
						end
					else
						offlineDiffColor = db.offlineLevelColor and offlineDiff or "|cFFAFAFAF|r"
					end

					if db.offlineEnhancedName then
						if db.offlineColorizeNameOnly then
							if db.offlineHideClass then
								if db.offlineHideLevel then
									nameText = format("%s%s", OfflineColorCode(class), name)
								else
									if db.hideLevelText then
										nameText = format("%s%s|r - %s%s", OfflineColorCode(class), name, offlineDiffColor, level)
									else
										nameText = format("%s%s|r - %s %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level)
									end
								end
							else
								if db.offlineHideLevel then
									nameText = format("%s%s|r - %s", OfflineColorCode(class), name, class)
								else
									if db.hideLevelText then
										nameText = format("%s%s|r - %s%s|r %s", OfflineColorCode(class), name, offlineDiffColor, level, class)
									else
										nameText = format("%s%s|r - %s %s%s|r %s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level, class)
									end
								end
							end
						else
							if db.offlineHideClass then
								if db.offlineHideLevel then
									nameText = format("%s%s", OfflineColorCode(class), name)
								else
									if db.hideLevelText then
										nameText = format("%s%s - %s%s", OfflineColorCode(class), name, offlineDiffColor, level)
									else
										nameText = format("%s%s - %s %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level)
									end
								end
							else
								if db.offlineHideLevel then
									nameText = format("%s%s - %s", OfflineColorCode(class), name, class)
								else
									if db.hideLevelText then
										nameText = format("%s%s - %s%s|r %s%s", OfflineColorCode(class), name, offlineDiffColor, level, OfflineColorCode(class), class)
									else
										nameText = format("%s%s - %s %s%s|r %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level, OfflineColorCode(class), class)
									end
								end
							end
						end
					else
						if db.offlineHideClass then
							if db.offlineHideLevel then
								nameText = name
							else
								if db.hideLevelText then
									nameText = format("%s - %s%s", name, offlineDiffColor, level)
								else
									nameText = format("%s - %s %s%s", name, offlineShortLevel, offlineDiffColor, level)
								end
							end
						else
							if db.offlineHideLevel then
								nameText = format("%s - %s", name, class)
							else
								if db.hideLevelText then
									nameText = format("%s - %s%s|r %s", name, offlineDiffColor, level, class)
								else
									nameText = format("%s - %s %s%s|r %s", name, offlineShortLevel, offlineDiffColor, level, class)
								end
							end
						end
					end

					if db.offlineShowZone then
						if db.offlineShowLastSeen then
							infoText = format("%s - %s %s", area, L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
						else
							infoText = area
						end
					else
						if db.offlineShowLastSeen then
							infoText = format("%s %s", L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
						else
							infoText = ""
						end
					end
				else
					nameText = name

					if db.offlineShowZone then
						if db.offlineShowLastSeen then
							infoText = format("%s - %s", area, area)
						else
							infoText = area
						end
					else
						if db.offlineShowLastSeen then
							infoText = area
						else
							infoText = ""
						end
					end
				end

				nameColor = FRIENDS_GRAY_COLOR
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