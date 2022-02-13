
local E, L, V, P, G = unpack(ElvUI)
local DAN = E:GetModule("ElvUI_DmgAtPlates")

local Loc = LibStub("AceLocale-3.0"):GetLocale("ElvUI_DmgAtPlates")

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
								-- DAN.DmgTextFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
								DAN:OnDisable()
							else
								-- DAN.DmgTextFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
								DAN:OnEnable()
							end
						end
					},
				},
			},
            pttdttab = {
				order = 2,
				type = "group",
				name = Loc["pttdt"],
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
					petttdt = {
						order = 3,
						type = "toggle",
						name = Loc["petttdt"],
						desc = Loc["petttdtdesc"],
						get = function(info) return E.db.DmgAtPlates.petttdt end,
						set = function(info, value)
							E.db.DmgAtPlates.petttdt = value
						end
					},
				},
			},
            ptthttab = {
				order = 3,
				type = "group",
				name = Loc["pttht"],
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
					petttht = {
						order = 3,
						type = "toggle",
						name = Loc["petttht"],
						desc = Loc["pettthtdesc"],
						get = function(info) return E.db.DmgAtPlates.petttht end,
						set = function(info, value)
							E.db.DmgAtPlates.petttht = value
						end
					},
				},
			},
            ttpdttab = {
				order = 4,
				type = "group",
				name = Loc["ttpdt"],
				get = function(info)  return E.db.DmgAtPlates[info[#info]] end,
				set = function(info, value)
					E.db.DmgAtPlates[info[#info]] = value
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = Loc["ttpdt"]
					},
					ttpdt = {
						order = 2,
						type = "toggle",
						name = Loc["ttpdt"],
						desc = Loc["ttpdtdesc"],
						get = function(info) return E.db.DmgAtPlates.ttpdt end,
						set = function(info, value)
							E.db.DmgAtPlates.ttpdt = value
						end
					},
				},
			},
            ttphttab = {
				order = 5,
				type = "group",
				name = Loc["ttpht"],
				get = function(info)  return E.db.DmgAtPlates[info[#info]] end,
				set = function(info, value)
					E.db.DmgAtPlates[info[#info]] = value
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = Loc["ttpht"]
					},
					ttpht = {
						order = 2,
						type = "toggle",
						name = Loc["ttpht"],
						desc = Loc["ttphtdesc"],
						get = function(info) return E.db.DmgAtPlates.ttpht end,
						set = function(info, value)
							E.db.DmgAtPlates.ttpht = value
						end
					},
				},
			},

		}
	}
end
