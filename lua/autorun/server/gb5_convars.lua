AddCSLuaFile()

if GetConVar("gb5_easyuse") == nil then
	CreateConVar("gb5_easyuse", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("gb5_nuke_light") == nil then
	CreateConVar("gb5_nuke_light", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("gb5_zombie_strength") == nil then
	CreateConVar("gb5_zombie_strength", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("gb5_sound_speed") == nil then
	CreateConVar("gb5_sound_speed", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("gb5_maxforcefield_range") == nil then
	CreateConVar("gb5_maxforcefield_range", "5000", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("gb5_fragility") == nil then
	CreateConVar("gb5_fragility", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_nuclear_emp") == nil then
	CreateConVar("gb5_nuclear_emp", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_safeemp") == nil then
	CreateConVar("gb5_safeemp", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_nuclear_vaporisation") == nil then
	CreateConVar("gb5_nuclear_vaporisation", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_shockwave_unfreeze") == nil then
	CreateConVar("gb5_shockwave_unfreeze", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_decals") == nil then
	CreateConVar("gb5_decals", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_realistic_sound") == nil then
	CreateConVar("gb5_realistic_sound", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_sound_shake") == nil then
	CreateConVar("gb5_sound_shake", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("gb5_nuclear_fallout") == nil then
	CreateConVar("gb5_nuclear_fallout", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("gb5_nmrih_zombies") == nil then
	CreateConVar("gb5_nmrih_zombies", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end