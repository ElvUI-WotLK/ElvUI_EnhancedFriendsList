local E, L, V, P, G = unpack(ElvUI)
local EFL = E:GetModule("EnhancedFriendsList")

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
						disabled = function() return not E.db.enhanceFriendsList.Online.enhancedName end
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
						disabled = function() return not E.db.enhanceFriendsList.Online.level end
					},
					levelText = {
						order = 6,
						type = "toggle",
						name = L["Level Text"],
						desc = L["Hides the 'Level' or 'L' text."],
						disabled = function() return not E.db.enhanceFriendsList.Online.level end
					},
					shortLevel = {
						order = 7,
						type = "toggle",
						name = L["Short Level"],
						disabled = function() return not E.db.enhanceFriendsList.Online.level or not E.db.enhanceFriendsList.Online.levelText end
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
						disabled = function() return not E.db.enhanceFriendsList.Offline.enhancedName end
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
						disabled = function() return not E.db.enhanceFriendsList.Offline.level end
					},
					levelText = {
						order = 6,
						type = "toggle",
						name = L["Level Text"],
						desc = L["Hides the 'Level' or 'L' text."],
						disabled = function() return not E.db.enhanceFriendsList.Offline.level end
					},
					shortLevel = {
						order = 7,
						type = "toggle",
						name = L["Short Level"],
						disabled = function() return not E.db.enhanceFriendsList.Offline.level or not E.db.enhanceFriendsList.Offline.levelText end
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