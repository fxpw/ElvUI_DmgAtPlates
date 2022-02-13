
local E, L, V, P, G = unpack(ElvUI)
local DAN = E:GetModule("ElvUI_DmgAtPlates")

local Loc = LibStub("AceLocale-3.0"):GetLocale("ElvUI_DmgAtPlates")



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-------------------------------------lcl fr cnfg
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------



local animationValues = {
	["verticalUp"] = Loc["Vertical Up"],
	["verticalDown"] = Loc["Vertical Down"],
	["fountain"] = Loc["Fountain"],
	["rainfall"] = Loc["Rainfall"],
	["disabled"] = Loc["Disabled"]
}
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-------------------------------------dapo
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------


function DAN:DmgAtPlatesOptions()
	E.Options.args.DmgAtPlates = {
		order = 55,
		type = "group",
		childGroups = "tab",
		name = string.format("|cff1784d1%s|r", "Damage At Plates"),
		args = {
			common = {
				order = 1,
				type = "group",
				name = Loc["common"],
				get = function(info)  return E.db.DmgAtPlates[info[#info]] end,
				set = function(info, value)
					E.db.DmgAtPlates[info[#info]] = value
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = Loc["commondesc"]
					},
					onorof = {
						order = 2,
						type = "toggle",
						name = Loc["onorof"],
						desc = Loc["onorofdesc"],
						get = function(info) return E.db.DmgAtPlates.onorof end,
						set = function(info, value)
							E.db.DmgAtPlates.onorof = value
							if not E.db.DmgAtPlates.onorof then
								DAN:OnDisable()
							else
								DAN:OnEnable()
							end
						end
					},
					showIcon = {
						order = 3,
						type = "toggle",
						name = Loc["sicon"],
						desc = Loc["sicon"],
						get = function(info) return E.db.DmgAtPlates.showIcon end,
						set = function(info, value)
							E.db.DmgAtPlates.showIcon = value
						end
					},
					spacer1 = {
						order = 4,
						type = "description",
						name = " "
					},
					spacer2 = {
						order = 5,
						type = "description",
						name = " "
					},
					font = {
						order = 6,
						type = "select",
						name = Loc["font"],
						dialogControl = "LSM30_Font",
						values = AceGUIWidgetLSMlists.font,
						get = function()
							return E.db.DmgAtPlates.font
						end,
						set = function(_, newValue)
							E.db.DmgAtPlates.font = newValue
						end
					},
					fontSize = {
						order = 7,
						type = "range",
						name = Loc["fntsize"],
						min = 5, max = 72, step = 1,
					},
					fontAlpha = {
						order = 8,
						type = "range",
						name = Loc["otfAlpha"],
						min = 0.1,
						max = 1,
						step = .01,
					},
					fontOutline = {
						order = 9,
						type = "select",
						name = Loc["Font Outline"],
						values = {
							["NONE"] = L["NONE"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						}
					},
					header2 = {
						order = 10,
						type = "header",
						name = Loc["offtarget"]
					},
					sfftrgt = {
						order = 11,
						type = "toggle",
						name = Loc["offtarget"],
						desc = "",
						get = function()
							return E.db.DmgAtPlates.sfftrgt
						end,
						set = function(_, newValue)
							E.db.DmgAtPlates.sfftrgt = newValue
						end,
					},
					sfftrgtSize = {
						order = 12,
						type = "range",
						name = Loc["otfSize"],
						desc = "",
						min = 5,
						max = 72,
						step = 1,
						disabled = function()
							return not E.db.DmgAtPlates.sfftrgt
						end,
						get = function()
							return E.db.DmgAtPlates.sfftrgtSize
						end,
						set = function(_, newValue)
							E.db.DmgAtPlates.sfftrgtSize = newValue
						end,
					},
					sfftrgtAlpha = {
						order = 13,
						type = "range",
						name = Loc["otfAlpha"],
						desc = "",
						min = 0.1,
						max = 1,
						step = .01,
						disabled = function()
							return not E.db.DmgAtPlates.sfftrgt
						end,
						get = function()
							return E.db.DmgAtPlates.sfftrgtAlpha
						end,
						set = function(_, newValue)
							E.db.DmgAtPlates.sfftrgtAlpha = newValue
						end,
					},
					header3 = {
						order = 14,
						type = "header",
						name = Loc["SmallHits"]
					},
					smallHits = {
						type = "toggle",
						order = 15,
						name = Loc["SmallHits"],
						desc = Loc["SmallHitsdesc"],
						disabled = function()
							return not E.db.DmgAtPlates.onorof or E.db.DmgAtPlates.smallHitsHide
						end,
						get = function()
							return E.db.DmgAtPlates.smallHits
						end,
						set = function(_, newValue)
							E.db.DmgAtPlates.smallHits = newValue
						end,
					},
					smallHitsScale = {
						order = 16,
						type = "range",
						name = Loc["SmallHitsScale"],
						desc = "",
						disabled = function()
							return not E.db.DmgAtPlates.onorof or not E.db.DmgAtPlates.smallHits or E.db.DmgAtPlates.smallHitsHide
						end,
						min = 0.33,
						max = 1,
						step = .01,
						get = function()
							return E.db.DmgAtPlates.smallHitsScale
						end,
						set = function(_, newValue)
							E.db.DmgAtPlates.smallHitsScale = newValue
						end,
						width = "double"
					},
					smallHitsHide = {
						order = 17,
						type = "toggle",
						name = Loc["SmallHitsHide"],
						desc = Loc["SmallHitsHidedesc"],
						get = function()
							return E.db.DmgAtPlates.smallHitsHide
						end,
						set = function(_, newValue)
							E.db.DmgAtPlates.smallHitsHide = newValue
						end,
					}
				},
			},
            pttdttab = {
				order = 2,
				type = "group",
				name = Loc["dt"],
				get = function(info)  return E.db.DmgAtPlates[info[#info]] end,
				set = function(info, value)
					E.db.DmgAtPlates[info[#info]] = value
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = Loc["pttdt"]
					},
					pttdt = {
						order = 2,
						type = "toggle",
						name = Loc["pttdt"],
						desc = Loc["pttdtdesc"],
						get = function(info) return E.db.DmgAtPlates.pttdt end,
						set = function(info, value)
							E.db.DmgAtPlates.pttdt = value
						end
					},
					ttpdt = {
						order = 3,
						type = "toggle",
						name = Loc["ttpdt"],
						desc = Loc["ttpdtdesc"],
						get = function(info) return E.db.DmgAtPlates.ttpdt end,
						set = function(info, value)
							E.db.DmgAtPlates.ttpdt = value
						end
					},
					petttdt = {
						order = 4,
						type = "toggle",
						name = Loc["petttdt"],
						desc = Loc["petttdtdesc"],
						get = function(info) return E.db.DmgAtPlates.petttdt end,
						set = function(info, value)
							E.db.DmgAtPlates.petttdt = value
						end
					},
					header2 = {
						order = 5,
						type = "header",
						name = Loc["AnimationDmg"]
					},
					tttckndcrt = {
						order = 6,
						type = "select",
						name = Loc["tttckndcrt"],
						desc = Loc["tttckndcrt"],
						values = animationValues,
						get = function(info) return E.db.DmgAtPlates.tttckndcrt end,
						set = function(info, value)
							E.db.DmgAtPlates.tttckndcrt = value
						end
					},
					tttck = {
						order = 7,
						type = "select",
						name = Loc["tttck"],
						desc = Loc["tttck"],
						values = animationValues,
						get = function(info) return E.db.DmgAtPlates.tttck end,
						set = function(info, value)
							E.db.DmgAtPlates.tttck = value
						end
					},
					crt = {
						order = 8,
						type = "select",
						name = Loc["crt"],
						desc = Loc["crt"],
						values = animationValues,
						get = function(info) return E.db.DmgAtPlates.crt end,
						set = function(info, value)
							E.db.DmgAtPlates.crt = value
						end
					},
					ntttckndcrt = {
						order = 9,
						type = "select",
						name = Loc["ntttckndcrt"],
						desc = Loc["ntttckndcrt"],
						values = animationValues,
						get = function(info) return E.db.DmgAtPlates.ntttckndcrt end,
						set = function(info, value)
							E.db.DmgAtPlates.ntttckndcrt = value
						end
					},
				},
			},
            ptthttab = {
				order = 3,
				type = "group",
				name = Loc["ht"],
				get = function(info)  return E.db.DmgAtPlates[info[#info]] end,
				set = function(info, value)
					E.db.DmgAtPlates[info[#info]] = value
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = Loc["pttht"]
					},
					pttht = {
						order = 2,
						type = "toggle",
						name = Loc["pttht"],
						desc = Loc["ptthtdesc"],
						get = function(info) return E.db.DmgAtPlates.pttht end,
						set = function(info, value)
							E.db.DmgAtPlates.pttht = value
						end
					},
					ttpht = {
						order = 3,
						type = "toggle",
						name = Loc["ttpht"],
						desc = Loc["ttphtdesc"],
						get = function(info) return E.db.DmgAtPlates.ttpht end,
						set = function(info, value)
							E.db.DmgAtPlates.ttpht = value
						end
					},
					petttht = {
						order = 4,
						type = "toggle",
						name = Loc["petttht"],
						desc = Loc["pettthtdesc"],
						get = function(info) return E.db.DmgAtPlates.petttht end,
						set = function(info, value)
							E.db.DmgAtPlates.petttht = value
						end
					},
					header2 = {
						order = 5,
						type = "header",
						name = Loc["AnimationHeal"]
					},
					hcrt = {
						order = 6,
						type = "select",
						name = Loc["crt"],
						desc = Loc["crt"],
						values = animationValues,
						get = function(info) return E.db.DmgAtPlates.hcrt end,
						set = function(info, value)
							E.db.DmgAtPlates.hcrt = value
						end
					},
					nhcrt = {
						order = 7,
						type = "select",
						name = Loc["nhcrt"],
						desc = Loc["nhcrt"],
						values = animationValues,
						get = function(info) return E.db.DmgAtPlates.nhcrt end,
						set = function(info, value)
							E.db.DmgAtPlates.nhcrt = value
						end
					},
					hlclr = {
						order = 8,
						type = "color",
						name = Loc["healColor"],
						desc = "",
						hasAlpha = false,
						set = function(_, r, g, b)
							E.db.DmgAtPlates.hlclr = DAN:rgbToHex(r, g, b)
						end,
						get = function()
							return DAN:hexToRGB(E.db.DmgAtPlates.hlclr)
						end,
					},
				},
			},
		}
	}
end
