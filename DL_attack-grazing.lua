local TICRATE = TICRATE
local MF2_ALREADYHIT = MF2_ALREADYHIT
local KITEM_FLAMESHIELD = KITEM_FLAMESHIELD
local KSHIELD_TOP = KSHIELD_TOP
local MT_PLAYER = MT_PLAYER
local motype
freeslot("sfx_graze")
local itemtable = {
	[MT_SSMINE_SHIELD] = true,
	[MT_ORBINAUT] = true,
	[MT_ORBINAUT_SHIELD] = true,
	[MT_JAWZ] = true,
	[MT_JAWZ_SHIELD] = true,
	[MT_BANANA] = true,
	[MT_BANANA_SHIELD] = true,
	[MT_LANDMINE] = true,
	[MT_BALLHOG] = true,
	[MT_GARDENTOP] = true,
	[MT_GACHABOM] = true,
	[MT_INSTAWHIP] = true,
	[MT_SPB] = true,
	[MT_SUPER_FLICKY] = true,
	[MT_DROPTARGET] = true,
	[MT_DROPTARGET_SHIELD] = true,
	[MT_SPBEXPLOSION] = true,
}

local function isplayerhazardous(p)
	return (p.invincibilitytimer or p.growshrinktimer > 0
	or (p.flamedash and p.itemtype == KITEM_FLAMESHIELD)
	or p.bubbleblowup)
end

local function blockmapsearchfunc(pmo, mo)
	motype = mo and mo.valid and mo.type
	if pmo and pmo.valid and pmo.player and pmo.player.valid and motype 
	and (itemtable[motype] or (motype == MT_PLAYER and mo.player and mo.player.valid and isplayerhazardous(mo.player)))
	and abs(pmo.z - mo.z) <= pmo.height + mo.height	-- Pretty close in height too
	and not ((mo.target and mo.target == pmo) or (mo == pmo))
		mo.grazetable = $ or {}
		mo.grazetable[#pmo.player+1] = $ and $+1 or 1
		if mo.grazetable[#pmo.player+1] == 1
			pmo.player.grazesthistic = $+TICRATE
		elseif mo.grazetable[#pmo.player+1] < TICRATE
			pmo.player.grazesthistic = $+1
		else
			mo.grazetable[#pmo.player+1] = TICRATE
		end
	end
end

addHook("MobjThinker", function(mo)
	if not (mo and mo.valid and mo.health) or mo.hitlag or (mo.flags2 & MF2_ALREADYHIT) then return end
	local p = mo.player
	if p and p.valid 
	and not isplayerhazardous(p)
		if not (p.exiting or p.spectator or p.flashing or p.spinouttimer or p.hyudorotimer or p.curshield == KSHIELD_TOP)
			p.grazesthistic = 0
			searchBlockmap("objects", blockmapsearchfunc, mo, mo.x - 99*mo.radius/70, mo.x + 99*mo.radius/70, mo.y - 99*mo.radius/70, mo.y + 99*mo.radius/70)
			if p.grazesthistic
				S_StartSound(nil, sfx_graze, p)
				p.driftboost = $+p.grazesthistic
				p.grazesthistic = 0
				--CONS_Printf(p, "grazing")
			end
		end
		mo.grazetable = $ or {}
		for k, v in ipairs(mo.grazetable)
			v = $ and $-1 or 0
		end
	end
end, MT_PLAYER)

addHook("MapLoad", function()
	for p in players.iterate
		if p.mo and p.mo.valid
			p.mo.grazetable = {}
		end
	end
end)