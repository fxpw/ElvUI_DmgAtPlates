---@diagnostic disable-next-line: deprecated
local E, L, V, P, G, _ = unpack(ElvUI);


local NP = E:GetModule('NamePlates');

local EP = E.Libs.EP --elvuiplugin
local DAN = E:NewModule('ElvUI_DmgAtPlates', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
DAN.DmgTextFrame = CreateFrame("Frame", nil, UIParent)
local LibEasing = LibStub("LibEasing-1.0")
local addonName, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale("ElvUI_DmgAtPlates")


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-------------------------------------DmgAtNameplates all functions
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local mtfl, mtpw, mtrn = math.floor, math.pow, math.random
local tostring, tonumber = tostring, tonumber
local format, find = string.format, string.find
local next, select, pairs, ipairs = next, select, pairs, ipairs
local tinsert, tremove = table.insert, table.remove


local defaultFont = "Friz Quadrata TT"

local SMALL_HIT_EXPIRY_WINDOW = 30
local SMALL_HIT_MULTIPIER = 0.5

local ANIMATION_VERTICAL_DISTANCE = 75

local ANIMATION_ARC_X_MIN = 50
local ANIMATION_ARC_X_MAX = 150
local ANIMATION_ARC_Y_TOP_MIN = 10
local ANIMATION_ARC_Y_TOP_MAX = 50
local ANIMATION_ARC_Y_BOTTOM_MIN = 10
local ANIMATION_ARC_Y_BOTTOM_MAX = 50

local ANIMATION_RAINFALL_X_MAX = 75
local ANIMATION_RAINFALL_Y_MIN = 50
local ANIMATION_RAINFALL_Y_MAX = 100
local ANIMATION_RAINFALL_Y_START_MIN = 5
local ANIMATION_RAINFALL_Y_START_MAX = 15


local AutoAttack = select(1, GetSpellInfo(6603))
local AutoShot = select(1, GetSpellInfo(75))

-- local animationValues = {
-- 	["verticalUp"] = L["Vertical Up"],
-- 	["verticalDown"] = L["Vertical Down"],
-- 	["fountain"] = L["Fountain"],
-- 	["rainfall"] = L["Rainfall"],
-- 	["disabled"] = L["Disabled"]
-- }

-- local fontFlags = {
-- 	[""] = L["None"],
-- 	["OUTLINE"] = L["Outline"],
-- 	["THICKOUTLINE"] = L["Thick Outline"],
-- 	["nil, MONOCHROME"] = L["Monochrome"],
-- 	["OUTLINE , MONOCHROME"] = L["Monochrome Outline"],
-- 	["THICKOUTLINE , MONOCHROME"] = L["Monochrome Thick Outline"]
-- }

-- local stratas = {
-- 	["BACKGROUND"] = L["Background"],
-- 	["LOW"] = L["Low"],
-- 	["MEDIUM"] = L["Medium"],
-- 	["HIGH"] = L["High"],
-- 	["DIALOG"] = L["Dialog"],
-- 	["TOOLTIP"] = L["Tooltip"]
-- }

-- local positionValues = {
-- 	["TOP"] = L["Top"],
-- 	["RIGHT"] = L["Right"],
-- 	["BOTTOM"] = L["Bottom"],
-- 	["LEFT"] = L["Left"],
-- 	["TOPRIGHT"] = L["Top Right"],
-- 	["TOPLEFT"] = L["Top Left"],
-- 	["BOTTOMRIGHT"] = L["Bottom Right"],
-- 	["BOTTOMLEFT"] = L["Bottom Left"],
-- 	["CENTER"] = L["Center"]
-- }

local inversePositions = {
	["BOTTOM"] = "TOP",
	["LEFT"] = "RIGHT",
	["TOP"] = "BOTTOM",
	["RIGHT"] = "LEFT",
	["TOPLEFT"] = "BOTTOMRIGHT",
	["TOPRIGHT"] = "BOTTOMLEFT",
	["BOTTOMLEFT"] = "TOPRIGHT",
	["BOTTOMRIGHT"] = "TOPLEFT",
	["CENTER"] = "CENTER"
}

local animating = {}

local DAMAGE_TYPE_COLORS = {
	[SCHOOL_MASK_PHYSICAL] = "FFFF00",
	[SCHOOL_MASK_HOLY] = "FFE680",
	[SCHOOL_MASK_FIRE] = "FF8000",
	[SCHOOL_MASK_NATURE] = "4DFF4D",
	[SCHOOL_MASK_FROST] = "80FFFF",
	[SCHOOL_MASK_FROST + SCHOOL_MASK_FIRE] = "FF80FF",
	[SCHOOL_MASK_SHADOW] = "8080FF",
	[SCHOOL_MASK_ARCANE] = "FF80FF",
	[AutoAttack] = "FFFFFF",
	[AutoShot] = "FFFFFF",
	["pet"] = "CC8400"
}
local MISS_EVENT_STRINGS = {
	["ABSORB"] = ACTION_SPELL_MISSED_ABSORB,
	["BLOCK"] = ACTION_SPELL_MISSED_BLOCK,
	["DEFLECT"] = ACTION_SPELL_MISSED_DEFLECT,
	["DODGE"] = ACTION_SPELL_MISSED_DODGE,
	["EVADE"] = ACTION_SPELL_MISSED_EVADE,
	["IMMUNE"] = ACTION_SPELL_MISSED_IMMUN,
	["MISS"] = ACTION_SPELL_MISSED_MISS,
	["PARRY"] = ACTION_SPELL_MISSED_PARRY,
	["REFLECT"] = L["Reflected"],
	["RESIST"] = L["Resisted"]
}



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-------------------------------------------- fontstring
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function getFontPath(fontName)
	local fontPath = "Fonts\\FRIZQT__.TTF"
	return fontPath
end

local fontStringCache = {}
local frameCounter = 0
local function getFontString(f)
	local fontString, fontStringFrame

	if next(fontStringCache) then
		fontString = tremove(fontStringCache)
	else
		frameCounter = frameCounter + 1
		fontStringFrame = CreateFrame("Frame", nil, UIParent)
		fontStringFrame:SetFrameStrata("HIGH")
		fontStringFrame:SetFrameLevel(frameCounter)
		fontString = fontStringFrame:CreateFontString()
		fontString:SetParent(fontStringFrame)
	end

	fontString:SetFont(getFontPath(defaultFont), 15, "OUTLINE")

		fontString:SetShadowOffset(0, 0)

	fontString:SetAlpha(1)
	fontString:SetDrawLayer("BACKGROUND")
	fontString:SetText("")
	fontString:Show()


		if not fontString.icon then
			fontString.icon = DAN.DmgTextFrame:CreateTexture(nil, "BACKGROUND")
			fontString.icon:SetTexCoord(0.062, 0.938, 0.062, 0.938)
		end
		fontString.icon:SetAlpha(1)
		fontString.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		fontString.icon:Hide()

		-- if fontString.icon.button then
		-- 	fontString.icon.button:Show()
		-- -- end

	return fontString
end

local function recycleFontString(fontString)
	fontString:SetAlpha(0)
	fontString:Hide()

	animating[fontString] = nil

	fontString.distance = nil
	fontString.arcTop = nil
	fontString.arcBottom = nil
	fontString.arcXDist = nil
	fontString.deflection = nil
	fontString.numShakes = nil
	fontString.animation = nil
	fontString.animatingDuration = nil
	fontString.animatingStartTime = nil
	fontString.anchorFrame = nil



	fontString.pow = nil
	fontString.startHeight = nil
	fontString.DANFontSize = nil

	if fontString.icon then
		fontString.icon:ClearAllPoints()
		fontString.icon:SetAlpha(0)
		fontString.icon:Hide()
		if fontString.icon.button then
			fontString.icon.button:Hide()
			fontString.icon.button:ClearAllPoints()
		end

		fontString.icon.anchorFrame = nil

	end

	fontString:SetFont(getFontPath(defaultFont), 15, "OUTLINE")

		fontString:SetShadowOffset(0, 0)

	fontString:ClearAllPoints()

	tinsert(fontStringCache, fontString)
end

local STRATAS = {
	"BACKGROUND",
	"LOW",
	"MEDIUM",
	"HIGH",
	"DIALOG",
	"TOOLTIP"
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------- lcls
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local dse = {
	DAMAGE_SHIELD = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	SPELL_BUILDING_DAMAGE = true,
	RANGE_DAMAGE = true
}

local mse = {
	SPELL_MISSED = true,
	SPELL_PERIODIC_MISSED = true,
	RANGE_MISSED = true,
	SPELL_BUILDING_MISSED = true
}

local hse = {

}

local cleu ="COMBAT_LOG_EVENT_UNFILTERED"
local ptc ="PLAYER_TARGET_CHANGED"
local pn = GetUnitName("player")

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- функции
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------
---------------------------------------------
--------------------------------------------- anmt
---------------------------------------------
------------------------------------------------------------------------------------------
local function verticalPath(elapsed, duration, distance)
	return 0, LibEasing.InQuad(elapsed, 0, distance, duration)
end

local function arcPath(elapsed, duration, xDist, yStart, yTop, yBottom)
	local x, y
	local progress = elapsed / duration

	x = progress * xDist

	local a = -2 * yStart + 4 * yTop - 2 * yBottom
	local b = -3 * yStart + 4 * yTop - yBottom

	y = -a * mtpw(progress, 2) + b * progress + yStart

	return x, y
end

local function powSizing(elapsed, duration, start, middle, finish)
	local size = finish
	if elapsed < duration then
		if elapsed / duration < 0.5 then
			size = LibEasing.OutQuint(elapsed, start, middle - start, duration / 2)
		else
			size = LibEasing.InQuint(elapsed - elapsed / 2, middle, finish - middle, duration / 2)
		end
	end
	return size
end

local function AnimationOnUpdate()
	if next(animating) then
		for fontString, _ in pairs(animating) do
			local elapsed = GetTime() - fontString.animatingStartTime
			if elapsed > fontString.animatingDuration then
				recycleFontString(fontString)
			else
				local isTarget = false

				local frame = fontString:GetParent()
				local currentStrata = frame:GetFrameStrata()
				local strataRequired = "BACKGROUND"
				if currentStrata ~= strataRequired then
					frame:SetFrameStrata(strataRequired)
				end

				local startAlpha = 1


				local alpha = LibEasing.InExpo(elapsed, startAlpha, -startAlpha, fontString.animatingDuration)
				fontString:SetAlpha(alpha)

				if fontString.pow then
					local iconScale = 1
					local height = fontString.startHeight
					if elapsed < fontString.animatingDuration / 6 then
						fontString:SetText(fontString.DANText)
						local size =
							powSizing(elapsed, fontString.animatingDuration / 6, height / 2, height * 2, height)
						fontString:SetTextHeight(size)
					else
						fontString.pow = nil
						fontString:SetTextHeight(height)
						fontString:SetFont(getFontPath(defaultFont),fontString.DANFontSize,"OUTLINE")
						fontString:SetShadowOffset(0, 0)
						fontString:SetText(fontString.DANText)
					end
				end

				local xOffset, yOffset = 0, 0
				if fontString.animation == "verticalUp" then
					xOffset, yOffset = verticalPath(elapsed, fontString.animatingDuration, fontString.distance)
				elseif fontString.animation == "verticalDown" then
					xOffset, yOffset = verticalPath(elapsed, fontString.animatingDuration, -fontString.distance)
				elseif fontString.animation == "fountain" then
					xOffset, yOffset = arcPath(elapsed, fontString.animatingDuration, fontString.arcXDist, 0, fontString.arcTop, fontString.arcBottom)
				elseif fontString.animation == "rainfall" then
					_, yOffset = verticalPath(elapsed, fontString.animatingDuration, -fontString.distance)
					xOffset = fontString.rainfallX
					yOffset = yOffset + fontString.rainfallStartY
				end

				if fontString.anchorFrame and fontString.anchorFrame:IsShown() then
					fontString:SetPoint("CENTER", fontString.anchorFrame, "CENTER", 0 + xOffset, 0 + yOffset)
				else
					recycleFontString(fontString)
				end
			end
		end
	else
		DAN.DmgTextFrame:SetScript("OnUpdate", nil)
	end
  -- print(frame)
end

local arcDirection = 1
function DAN:Animate(fontString, anchorFrame, duration, animation)
	animation = animation or "verticalUp"

	fontString.animation = animation
	fontString.animatingDuration = duration
	fontString.animatingStartTime = GetTime()
	fontString.anchorFrame = anchorFrame

	if animation == "verticalUp" then
		fontString.distance = ANIMATION_VERTICAL_DISTANCE
	elseif animation == "verticalDown" then
		fontString.distance = ANIMATION_VERTICAL_DISTANCE
	elseif animation == "fountain" then
		fontString.arcTop = mtrn(ANIMATION_ARC_Y_TOP_MIN, ANIMATION_ARC_Y_TOP_MAX)
		fontString.arcBottom = -mtrn(ANIMATION_ARC_Y_BOTTOM_MIN, ANIMATION_ARC_Y_BOTTOM_MAX)
		fontString.arcXDist = arcDirection * mtrn(ANIMATION_ARC_X_MIN, ANIMATION_ARC_X_MAX)

		arcDirection = arcDirection * -1
	elseif animation == "rainfall" then
		fontString.distance = mtrn(ANIMATION_RAINFALL_Y_MIN, ANIMATION_RAINFALL_Y_MAX)
		fontString.rainfallX = mtrn(-ANIMATION_RAINFALL_X_MAX, ANIMATION_RAINFALL_X_MAX)
		fontString.rainfallStartY = -mtrn(ANIMATION_RAINFALL_Y_START_MIN, ANIMATION_RAINFALL_Y_START_MAX)
	end

	animating[fontString] = true

	-- start onupdate if it's not already running
	if DAN.DmgTextFrame:GetScript("OnUpdate") == nil then
		DAN.DmgTextFrame:SetScript("OnUpdate", AnimationOnUpdate)
	end
  -- print(fontString.anchorFrame)
end
------------------------------------------------------------------------------------------
---------------------------------------------
--------------------------------------------- dde
---------------------------------------------
------------------------------------------------------------------------------------------

local function DoDmgEvnt(plate,f,...)
	if not E.db.DmgAtPlates.onorof then return end
	local vnt,tm,sbvnt,_,whcst,_,guid,tgtcst,_,splld,spllname,schl,slldmg,_,_,_,_,_,crt,_,_,_,_,_,_,_ = ...
	-- print(vnt,tm,sbvnt,_,whcst,_,guid,tgtcst,_,splld,spllname,schl,slldmg,_,_,_,_,_,crt,_,_,_,_,_,_,_)
-- print("zap")
	-- f.guid = guid
	if dse[sbvnt] then
		if whcst == pn and f.guid == guid then
			-- print(spllname.." Нанесло "..tgtcst.." "..slldmg.." Урона")
			-- f.guid = guid
			-- print(f.guid)
			DAN:DamageEvent(f, spllname, slldmg, schl, crt, splld)
		end
	elseif  sbvnt == "SWING_DAMAGE" and f.guid == guid then
		if whcst == pn then
			-- f.guid = guid
			DAN:DamageEvent(f, AutoAttack, splld, 1, crt, 6603)
		end
	elseif mse[sbvnt] and f.guid == guid then
		if whcst == pn then
			-- f.guid = guid
			DAN:MissEvent(f, spllname, slldmg, splld)
		end
	end


end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- damageevents
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
local numDamageEvents = 0
local lastDamageEventTime
local runningAverageDamageEvents = 0
function DAN:DamageEvent(plate, spellName, amount, school, crit, spellId)
	local text, animation, pow, size, alpha
	----- определение чего то спеллнейма
  local autoattack = spellName == AutoAttack or spellName == AutoShot or spellName == "pet"
	--------- определение анимации
	if (autoattack and crit) then
		-- animation = "verticalUp"
		animation = "verticalUp"
		-- print(animation..568)
		pow = true
	elseif (autoattack) then
		animation = "fountain"
		-- print(animation..590)
		pow = false
	elseif (crit) then
		animation = "fountain"
		-- animation = "verticalUp"
		-- print(animation..594)
		pow = true
	elseif (not autoattack and not crit) then
		-- animation = "rainfall"
		animation = "fountain"
		-- print(animation..598)
		pow = false
	end
	------ формат текста
	text = format("%.1f", amount / 1000)
	text = text .. "k"
	------------------- красим текст в школу
	if	(spellName == AutoAttack or spellName == AutoShot) and DAMAGE_TYPE_COLORS[spellName] then
			text = "\124cff" .. DAMAGE_TYPE_COLORS[spellName] .. text .. "\124r"
	elseif school and DAMAGE_TYPE_COLORS[school] then
		text = "\124cff" .. DAMAGE_TYPE_COLORS[school] .. text .. "\124r"
	else
		text = "\124cff" .. "ffff00" .. text .. "\124r"
	end

	size = 20
	alpha = 1
	--   local size = 20
	--   local alpha = 1
	--   local animation = "fountain"
	--   local pow = false
	--------------считает последние штуки
  runningAverageDamageEvents = ((runningAverageDamageEvents * numDamageEvents) + amount) / (numDamageEvents + 1)
  numDamageEvents = numDamageEvents + 1
  lastDamageEventTime = GetTime()
  -- print(plate, text, size, alpha, animation, spellId, pow, spellName)
	DAN:DisplayText(plate, text, size, alpha, animation, spellId, pow, spellName)
end


function DAN:MissEvent(f, spellName, missType, spellId)
	local text, animation, pow, size, alpha, color
	-- local isTarget = (UnitGUID("target") == guid)
	----------------------- animation
	animation = "verticalUp"
	------------color
	color = "ffff00"
	----------------- size
	size = 20
	---------------- alpha
	alpha = 1
	pow = true
	------------- text
	text = MISS_EVENT_STRINGS[missType] or ACTION_SPELL_MISSED_MISS
	text = "\124cff" .. color .. text .. "\124r"

	self:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName)
end

---------------------------------------------
---------------------------------------------
---------------------------------------------displaytext
---------------------------------------------
---------------------------------------------
function DAN:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName)
	local fontString
	local icon
	-- local nameplate
	-- nameplate = plate
	--   local plateName1 = LNP:GetName(plate)
	fontString = getFontString(f)

	fontString.DANText = text
	fontString:SetText(fontString.DANText)

	fontString.DANFontSize = size
	fontString:SetFont(getFontPath(defaultFont), fontString.DANFontSize, "OUTLINE")

	fontString:SetShadowOffset(0, 0)

	fontString.startHeight = fontString:GetStringHeight()
	fontString.pow = pow

	if (fontString.startHeight <= 0) then
		fontString.startHeight = 5
	end


	local texture = select(3, GetSpellInfo(spellId or spellName))
	if not texture then
		texture = select(3, GetSpellInfo(spellName))
	end

	if texture then
		icon = fontString.icon
		icon:Show()
		icon:SetTexture(texture)
		icon:SetSize(size * 1, size * 1)
		icon:SetPoint(
			inversePositions["RIGHT"],
			fontString,
			"RIGHT",
			0,
			0
		)
		icon:SetAlpha(alpha)
		fontString.icon = icon
	else
		if fontString.icon then
			fontString.icon:Hide()
		end
	end

	DAN:Animate(fontString, f, 1, animation)
end






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
		name = string.format("|cff1784d1%s|r", "DamageAtPlates"),
		args = {
			tabs = {
				order = 1,
				type = "group",
				name = L["common"],
				get = function(info)  return E.db.DmgAtPlates[info[#info]] end,
				set = function(info, value)
					E.db.DmgAtPlates[info[#info]] = value
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["commondesc"]
					},
					onorof = {
						order = 2,
						type = "toggle",
						name = L["onorof"],
						desc = L["onorofdesc"],
						get = function(info) return E.db.DmgAtPlates.onorof end,
						set = function(info, value)
							E.db.DmgAtPlates.onorof = value
							if not value then
								DAN:OnDisable()
							else
								DAN:OnEnable()
							end
							-- if E.db.DmgAtPlates.onorof then
							-- 	print("DA")
							-- else
							-- 	print("NET")
							-- end
						end
					},
				},
			},
		}
	}
end

function DAN:PLAYER_ENTERING_WORLD(...)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function DAN:Initialize()
	if not E.db.DmgAtPlates then
		E.db.DmgAtPlates = {}
		E.db.DmgAtPlates.onorof = false
	end
	EP:RegisterPlugin(addonName, self.DmgAtPlatesOptions)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-------------------------------------fnct
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function DAN:CreateDataText(frame)
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	frame:SetScript("OnEvent",function(event,...)
		-- print("1")
		-- if event == cleu then
			-- if frame.guid then
				DoDmgEvnt(_,frame,...)
			-- end
		-- end
	end)

end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-------------------------------------cmnfnct
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function DAN:OnEnable()
	-- if E.db.DmgAtPlates.onorof then
	if not NP:IsHooked(NP,"OnUpdate") then
		NP:SecureHook(NP,"OnUpdate",function()
			for frame in pairs(NP.VisiblePlates) do
				-- if  E.db.DmgAtPlates.onorof then
					DAN:CreateDataText(frame)
				-- end
			end
		end)
	end
end



function DAN:OnDisable()
	if not E.db.DmgAtPlates.onorof then
		-- NP:Unhook(NP,"OnUpdate")
	end
end



E:RegisterModule(DAN:GetName())



