---@diagnostic disable-next-line: deprecated
local E, L, V, P, G, _ = unpack(ElvUI);
local NP = E:GetModule('NamePlates');
local EP = E.Libs.EP 
local DAN = E:NewModule('ElvUI_DmgAtPlates', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')
local LibEasing = LibStub("LibEasing-1.0")
local Loc = LibStub("AceLocale-3.0"):GetLocale("ElvUI_DmgAtPlates")
local LSM = E.Libs.LSM

-------------------------------------------------dmg text frame
DAN.DmgTextFrame = CreateFrame("Frame", nil, UIParent)
-------------------------------------------------player events frame
DAN.ElvUI_PDFrame = CreateFrame("Frame","ElvUI_PDF",UIParent)
DAN.ElvUI_PDFrame:SetPoint("CENTER",UIParent,"CENTER",0,-100)
DAN.ElvUI_PDFrame:SetSize(32,32)
DAN.ElvUI_PDFrame:Show()
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-------------------------------------DmgAtNameplates all functions and const
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local mtfl, mtpw, mtrn = math.floor, math.pow, math.random
local tostring, tonumber = tostring, tonumber
local format, find = string.format, string.find
local next, select, pairs, ipairs = next, select, pairs, ipairs
local tinsert, tremove = table.insert, table.remove


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
local AutoAttackPet = select(1, GetSpellInfo(315235))

local AutoShot = select(1, GetSpellInfo(75))


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
	["REFLECT"] = Loc["Reflected"],
	["RESIST"] = Loc["Resisted"]
}

function DAN:rgbToHex(r, g, b)
	return format("%02x%02x%02x", mtfl(255 * r), mtfl(255 * g), mtfl(255 * b))
end

function DAN:hexToRGB(hex)
	return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255, 1
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--------------------------------------------- lcls
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

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
	SPELL_BUILDING_MISSED = true,
	-- SWING_MISSED = true
}

local hse = {
	SPELL_HEAL = true,
	SPELL_PERIODIC_HEAL = true

}
local csi = {
	SPELL_INTERRUPT = true
}


local cleu
local ptc
local pn
local pguid



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-------------------------------------------- fontstring
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

function DAN:GFP(fontName)
	local fontPath = LSM:Fetch("font", fontName) or "Fonts\\FRIZQT__.TTF"
	return fontPath
end

local fontStringCache = {}
local frameCounter = 0
function DAN:GFS()
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
	fontString:SetFont(DAN:GFP(E.db.DmgAtPlates.font),E.db.DmgAtPlates.fontSize,E.db.DmgAtPlates.fontOutline)
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

function DAN:RFS(fontString)
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

	fontString:SetFont(DAN:GFP(E.db.DmgAtPlates.font),E.db.DmgAtPlates.fontSize,E.db.DmgAtPlates.fontOutline)

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


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--------------------------------------------- anmt
------------------------------------------------------------------------------------------
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
				DAN:RFS(fontString)
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
						fontString:SetFont(E.db.DmgAtPlates.font,E.db.DmgAtPlates.fontSize,E.db.DmgAtPlates.fontOutline)
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
					DAN:RFS(fontString)
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
--   print(410)
end
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--------------------------------------------- dt
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function DAN:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName)
	local fontString
	local icon

	fontString = DAN:GFS()

	fontString.DANText = text
	fontString:SetText(fontString.DANText)

	fontString.DANFontSize = size
	fontString:SetFont(DAN:GFP(E.db.DmgAtPlates.font),size,E.db.DmgAtPlates.fontOutline)

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

	if texture and E.db.DmgAtPlates.showIcon then
		icon = fontString.icon
		icon:Show()
		icon:SetTexture(texture)
		icon:SetSize(size * 1, size * 1)
		icon:SetPoint(inversePositions["RIGHT"], fontString, "RIGHT", 0, 0)
		icon:SetAlpha(alpha)
		fontString.icon = icon
	else
		if fontString.icon then
			fontString.icon:Hide()
		end
	end
	-- print(457)
	DAN:Animate(fontString, f, 1, animation)
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
---------------------------------------------de me de he ise
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
local numDamageEvents = 0
local lastDamageEventTime
local runningAverageDamageEvents = 0
function DAN:DamageEvent(f, spellName, amount, school, crit, spellId)
	local text, animation, pow, size, alpha
	----- определение чего то спеллнейма
  	local autoattack = spellName == AutoAttack or spellName == AutoShot or spellName == "pet"
	--------- animation
	if (autoattack and crit) then
		-- animation = "verticalUp"
		animation = E.db.DmgAtPlates.tttckndcrt or "verticalUp"
		-- print(animation..568)
		pow = true
	elseif (autoattack) then
		animation =  E.db.DmgAtPlates.tttck or "fountain"
		-- print(animation..590)
		pow = false
	elseif (crit) then
		animation = E.db.DmgAtPlates.crt or "fountain"
		-- animation = "verticalUp"
		-- print(animation..594)
		pow = true
	elseif (not autoattack and not crit) then
		-- animation = "rainfall"
		animation = E.db.DmgAtPlates.ntttckndcrt or "fountain"
		-- print(animation..598)
		pow = false
	end
	------ формат текста
	text = format("%.1fk", amount / 1000)
	-- text = text .. "k"
	------------------- красим текст в школу
	if	(spellName == AutoAttack or spellName == AutoShot) and DAMAGE_TYPE_COLORS[spellName] then
			text = "\124cff" .. DAMAGE_TYPE_COLORS[spellName] .. text .. "\124r"
	elseif school and DAMAGE_TYPE_COLORS[school] then
		text = "\124cff" .. DAMAGE_TYPE_COLORS[school] .. text .. "\124r"
	else
		text = "\124cff" .. "ffff00" .. text .. "\124r"
	end

	local isTarget = (UnitGUID("target") == f.guid)

	if (E.db.DmgAtPlates.sfftrgt and not isTarget and pguid ~= f.guid) then
		size = E.db.DmgAtPlates.sfftrgtSize or 20
		alpha = E.db.DmgAtPlates.sfftrgtAlpha or 1
		-- print(473)
	else
		size = E.db.DmgAtPlates.fontSize or 20
		alpha = E.db.DmgAtPlates.fontAlpha or 1
	end
	--------------small hits
	if (E.db.DmgAtPlates.smallHits or E.db.DmgAtPlates.smallHitsHide) then
		if (not lastDamageEventTime or (lastDamageEventTime + SMALL_HIT_EXPIRY_WINDOW < GetTime())) then
			numDamageEvents = 0
			runningAverageDamageEvents = 0
		end
		runningAverageDamageEvents = ((runningAverageDamageEvents * numDamageEvents) + amount) / (numDamageEvents + 1)
		numDamageEvents = numDamageEvents + 1
		lastDamageEventTime = GetTime()
		if ((not crit and amount < SMALL_HIT_MULTIPIER * runningAverageDamageEvents) or (crit and amount / 2 < SMALL_HIT_MULTIPIER * runningAverageDamageEvents)) then
			if (E.db.DmgAtPlates.smallHitsHide) then
				return
			else
				size = size * (E.db.DmgAtPlates.smallHitsScale or 1)
			end
		end
	end
	------for debug
	if (size < 5) then
		size = 5
	end

	DAN:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName)
end

function DAN:HealEvent(f, spllname, slldmg, healcrt, splld, vrhll)
	local text, animation, pow, size, alpha, color
	----------------------- animation
	if healcrt then
		animation = E.db.DmgAtPlates.hcrt or "verticalUp"
	else
		animation =  E.db.DmgAtPlates.nhcrt or "fountain"
	end
	------------color
	color = E.db.DmgAtPlates.hlclr or "ffff00"
	----------------- size
	size = E.db.DmgAtPlates.fontSize or 20
	---------------- alpha
	alpha = 1
	pow = false
	------------- text
	if E.db.DmgAtPlates.shwrhll and slldmg == vrhll then
		text = format("Перелечено: %.1f k", (vrhll  / 1000))
	elseif not E.db.DmgAtPlates.shwrhll and slldmg == vrhll then
		return
	else
		text = format("%.1fk", ((slldmg - vrhll)  / 1000))
	end
	text = "\124cff" .. color .. text .. "\124r"
	self:DisplayText(f, text, size, alpha, animation, splld, pow, spllname)
end

function DAN:MissEvent(f, spellName, missType, spellId)
	local text, animation, pow, size, alpha, color
	----------------------- animation
	animation = "verticalDown"
	------------color
	color = "ffff00"
	----------------- size
	size = E.db.DmgAtPlates.fontSize or 20
	---------------- alpha
	alpha = 1
	pow = true
	------------- text
	text = MISS_EVENT_STRINGS[missType] or ACTION_SPELL_MISSED_MISS
	text = "\124cff" .. color .. text .. "\124r"

	self:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName)
end
function DAN:MissEventPet(f, spellName, missType, spellId)
	local text, animation, pow, size, alpha, color
	----------------------- animation
	animation = "verticalDown"
	------------color
	color = "ffff00"
	----------------- size
	size = E.db.DmgAtPlates.fontSize or 20
	---------------- alpha
	alpha = 1
	pow = true
	------------- text
	text = MISS_EVENT_STRINGS[missType] or ACTION_SPELL_MISSED_MISS
	text = "\124cff" .. color .."Питомец ".. text .. "\124r"

	self:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName)
end

function DAN:DispelEvent(f, spellName, infodis, spellId)
	local text, animation, pow, size, alpha, color
	----------------------- animation
	animation = "fountain"
	------------color
	color = "ffff00"
	----------------- size
	size = E.db.DmgAtPlates.fontSize or 20
	---------------- alpha
	alpha = 1
	pow = false
	------------- text
	text = infodis
	text = "\124cff" .. color .. text .. "\124r"

	self:DisplayText(f, text, size, alpha, animation, spellId, pow, spellName)
end



function DAN:SpellInterruptEvent(f,  spllname, splld, intrspll)
	local text, animation, pow, size, alpha, color
	-- print(spllname, splld, intrspll)
	----------------------- animation
	animation = "verticalUp"
	------------color
	color = "ffff00"
	----------------- size
	size = E.db.DmgAtPlates.fontSize or 20
	---------------- alpha
	alpha = 1
	pow = true
	------------- text
	text = "Прервано ".."{"..intrspll.."}"
	-- text = text .. "k"
	text = "\124cff" .. color .. text .. "\124r"

	self:DisplayText(f, text, size, alpha, animation, splld, pow, spllname)
end


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
--------------------------------------------- cde
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
local BITMASK_PETS = COMBATLOG_OBJECT_TYPE_PET + COMBATLOG_OBJECT_TYPE_GUARDIAN
function DAN:ChckDmgEvnt(...)
	if not E.db.DmgAtPlates.onorof then return end
	-- print("rab")
	-- local vnt1,tm2,sbvnt3,guidwhcst4,whcst5,flags6,tgtguid7,tgtcst8,_,splld10,spllname11,schl12,slldmg13,infodis14,intrspll15,healcrt16,_,_,crt19,_,_,_,_,_,_,_ = ...
	local args = {...}
	-- for k,v in pairs(args) do
	-- 	print(k,v)
	-- end
	if args[4] == pguid and args[7] ~= pguid then
		if dse[args[3]] and E.db.DmgAtPlates.pttdt then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:DamageEvent(frame, args[11], args[13], args[12], args[19], args[10])
				end
			end
		elseif  args[3] == "SWING_DAMAGE" and E.db.DmgAtPlates.pttdt  then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:DamageEvent(frame, AutoAttack, args[10], 1, args[19], 6603)
				end
			end
		elseif mse[args[3]] and E.db.DmgAtPlates.pttdt  then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:MissEvent(frame, args[11], args[13], args[10])
				end
			end
		elseif  args[3] == "SPELL_DISPEL" and E.db.DmgAtPlates.pttdt  then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:DispelEvent(frame, args[11], args[14], args[13])
				end
			end
		elseif hse[args[3]] and E.db.DmgAtPlates.pttht  then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:HealEvent(frame, args[11], args[13], args[16], args[10],args[14])
				end
			end
		elseif csi[args[3]] and E.db.DmgAtPlates.pttdt then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:SpellInterruptEvent(frame, args[11],args[10],args[14])
				end
			end
		elseif args[3] == "SWING_MISSED" and E.db.DmgAtPlates.pttdt then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:MissEvent(frame, AutoAttack, AutoAttack , 6603)
				end
			end
		end
	elseif args[7] == pguid then
		if dse[args[3]] and E.db.DmgAtPlates.ttpdt then
			DAN:DamageEvent(ElvUI_PDF, args[11], args[13], args[12], args[19], args[10])
		elseif  args[3] == "SWING_DAMAGE" and E.db.DmgAtPlates.ttpdt then
			DAN:DamageEvent(ElvUI_PDF, AutoAttack, args[10], 1, args[19], 6603)
		elseif mse[args[3]] and E.db.DmgAtPlates.ttpdt then
			DAN:MissEvent(ElvUI_PDF, args[11], args[13], args[10])
		elseif  args[3] == "SPELL_DISPEL" and E.db.DmgAtPlates.ttpdt then
			DAN:DispelEvent(ElvUI_PDF, args[11], args[14], args[13])
		elseif hse[args[3]] and E.db.DmgAtPlates.ttpht then
			DAN:HealEvent(ElvUI_PDF, args[11], args[13], args[16], args[10],args[14])
		elseif csi[args[3]]  and E.db.DmgAtPlates.ttpdt then
			DAN:SpellInterruptEvent(frame, args[11],args[10],args[14])
		elseif args[3] == "SWING_MISSED" and E.db.DmgAtPlates.ttpdt then
			DAN:MissEvent(ElvUI_PDF, AutoAttack, AutoAttack , 6603)
		end
	elseif bit.band(args[6], BITMASK_PETS) > 0 and bit.band(args[6], COMBATLOG_OBJECT_AFFILIATION_MINE) > 0 then -- pet/guard events
		if dse[args[3]] and E.db.DmgAtPlates.petttdt  then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:DamageEvent(frame, args[11], args[13], "pet", args[19], args[10])
				end
			end
		elseif args[3] == "SWING_DAMAGE" and E.db.DmgAtPlates.petttdt then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:DamageEvent(frame, AutoAttackPet, args[10], "pet", args[19], 315235)
				end
			end
		elseif mse[args[3]] and E.db.DmgAtPlates.petttdt then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:MissEventPet(frame, args[11], args[13], args[10])
				end
			end
		elseif hse[args[3]] and E.db.DmgAtPlates.petttht then
			for frame in pairs(NP.VisiblePlates) do
				if frame.guid == args[7] then
					DAN:HealEvent(frame, args[11], args[13], args[16], args[10],args[14])
				end
			end
		end
	end
end

function DAN:PLAYER_ENTERING_WORLD(...)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	cleu = "COMBAT_LOG_EVENT_UNFILTERED"
	ptc = "PLAYER_TARGET_CHANGED"
	pn = GetUnitName("player")
	pguid = UnitGUID("player")
	DAN.DmgTextFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	DAN.DmgTextFrame:SetScript("OnEvent",function(event,...)
		DAN:ChckDmgEvnt(...)
	end)
end

function DAN:Initialize()
	E.db.DmgAtPlates = E.db.DmgAtPlates or {}
	E.db.DmgAtPlates.hlclr = E.db.DmgAtPlates.hlclr or "ffff00"
	E.db.DmgAtPlates.onorof = E.db.DmgAtPlates.onorof or false
	EP:RegisterPlugin("ElvUI_DmgAtPlates", self.DmgAtPlatesOptions)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-------------------------------------cmnfnct
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------



function DAN:OnDisable()
	if not E.db.DmgAtPlates.onorof then
		DAN.DmgTextFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end
function DAN:OnEnable()
	if E.db.DmgAtPlates.onorof then
		DAN.DmgTextFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		DAN.DmgTextFrame:SetScript("OnEvent",function(event,...)
			DAN:ChckDmgEvnt(...)
		end)
	end
end


E:RegisterModule(DAN:GetName())



