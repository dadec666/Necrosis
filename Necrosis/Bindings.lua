--[[
    Necrosis LdC
    Copyright (C) 2005-2008  Lom Enfroy

    This file is part of Necrosis LdC.

    Necrosis LdC is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Necrosis LdC is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Necrosis LdC; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
--]]


------------------------------------------------------------------------------------------------------
-- Necrosis LdC
-- Par Lomig (Kael'Thas EU/FR) & Tarcalion (Nagrand US/Oceanic) 
-- Contributions deLiadora et Nyx (Kael'Thas et Elune EU/FR)
--
-- Skins et voix Francaises : Eliah, Ner'zhul
--
-- Version Allemande par Geschan
-- Version Espagnole par DosS (Zul'jin)
-- Version Russe par Komsomolka
--
-- Version $LastChangedDate: 2010-08-04 12:04:27 +1000 (Wed, 04 Aug 2010) $
------------------------------------------------------------------------------------------------------

local _G = _G or getfenv(0)
Necrosis = Necrosis or _G.Necrosis or {}
_G.Necrosis = Necrosis

-- Creation des raccourcis claviers
function Necrosis:BindName()

	self.Spell = self.Spell or {}
	self.Translation = self.Translation or {}
	self.Translation.Item = self.Translation.Item or {}
	self.Translation.Misc = self.Translation.Misc or {}
	self.Localize = self.Localize or { Utilisation = "Use", Echange = "Trade" }
	self.Config = self.Config or {}
	self.Config.Menus = self.Config.Menus or {
		["Menu des Buffs"] = "Buffs",
		["Menu des Demons"] = "Demons",
		["Menu des Maledictions"] = "Curses"
	}

	-------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Premiere section
	-------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Le Titre
	_G["BINDING_HEADER_Necrosis"] = "Necrosis LdC"

	-- La Sphere
	_G["BINDING_NAME_CLICK NecrosisButton:LeftButton"] = (NecrosisConfig and NecrosisConfig.MainSpell and self.Spell[NecrosisConfig.MainSpell] and self.Spell[NecrosisConfig.MainSpell].Name) or "Necrosis"

	-- mounts || Le Cheval
	if (NecrosisConfig and NecrosisConfig.LeftMount) then
		_G["BINDING_NAME_CLICK NecrosisMountButton:LeftButton"] = GetSpellInfo(NecrosisConfig.LeftMount) or "Mount 1"
	else
		_G["BINDING_NAME_CLICK NecrosisMountButton:LeftButton"] = (self.Spell[1] and self.Spell[1].Name) or "Mount 1"
	end
	
	if (NecrosisConfig and NecrosisConfig.RightMount) then
		_G["BINDING_NAME_CLICK NecrosisMountButton:RightButton"] = GetSpellInfo(NecrosisConfig.RightMount) or "Mount 2"
	else
		_G["BINDING_NAME_CLICK NecrosisMountButton:RightButton"] = (self.Spell[2] and self.Spell[2].Name) or "Mount 2"
	end

	-- La Pierre de feu
	_G["BINDING_NAME_CLICK NecrosisFirestoneButton:RightButton"] = (self.Spell[54] and self.Spell[54].Name) or "Firestone"
	_G["BINDING_NAME_CLICK NecrosisFirestoneButton:LeftButton"] = self.Translation.Item.Firestone or "Firestone"

	--La Pierre de sort
	_G["BINDING_NAME_CLICK NecrosisSpellstoneButton:RightButton"] = (self.Spell[53] and self.Spell[53].Name) or "Spellstone"
	_G["BINDING_NAME_CLICK NecrosisSpellstoneButton:LeftButton"] = self.Translation.Item.Spellstone or "Spellstone"

	--La Pierre de soin
	local hsName = self.Translation.Item.Healthstone or "Healthstone"
	local useText = self.Localize["Utilisation"] or "Use"
	local tradeText = self.Localize["Echange"] or "Trade"
	_G["BINDING_NAME_CLICK NecrosisHealthstoneButton:RightButton"] = (self.Spell[52] and self.Spell[52].Name) or "Healthstone"
	_G["BINDING_NAME_CLICK NecrosisHealthstoneButton:LeftButton"] = hsName .. " - " .. useText
	_G["BINDING_NAME_CLICK NecrosisHealthstoneButton:MiddleButton"] = hsName .. " - " .. tradeText

	-- La Pierre de resurrection
	_G["BINDING_NAME_CLICK NecrosisSoulstoneButton:RightButton"] = (self.Spell[51] and self.Spell[51].Name) or "Soulstone"
	_G["BINDING_NAME_CLICK NecrosisSoulstoneButton:LeftButton"] = self.Translation.Item.Soulstone or "Soulstone"
	
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Deuxieme section
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local buffMenuName = (self.Config.Menus and self.Config.Menus["Menu des Buffs"]) or "Buffs"
	_G["BINDING_HEADER_NecrosisSpell"] = "Necrosis - " .. buffMenuName
	_G["BINDING_NAME_CLICK NecrosisBuffMenuButton:LeftButton"] = buffMenuName
	
	local buffID = {31, -- demon armor
	                47, -- fel armor 
	                32, -- unending breath
	                33, -- detect invisibility
	                34, -- eye of killrogg
	                37, -- ritual of summoning
	                38, -- soul link
	                43, -- shadow ward
	                59} -- demonic empowerment
	for i = 1, #buffID, 1 do
		_G["BINDING_NAME_CLICK NecrosisBuffMenu"..i..":LeftButton"] = (self.Spell[buffID[i]] and self.Spell[buffID[i]].Name) or ("Buff " .. i)
	end
	
	local banishName = (self.Spell[9] and self.Spell[9].Name) or "Banish"
	local rankText = (self.Translation.Misc and self.Translation.Misc["Rank"]) or "Rank"
	_G["BINDING_NAME_CLICK NecrosisBuffMenu10:LeftButton"] = banishName
	_G["BINDING_NAME_CLICK NecrosisBuffMenu10:RightButton"] = banishName .. " (" .. rankText .. " 1)"

	-------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Troisieme section
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local petMenuName = (self.Config.Menus and self.Config.Menus["Menu des Demons"]) or "Demons"
	_G["BINDING_HEADER_NecrosisPet"] = "Necrosis - " .. petMenuName
	_G["BINDING_NAME_CLICK NecrosisPetMenuButton:LeftButton"] = petMenuName
	
	for i = 2, 6, 1 do
		_G["BINDING_NAME_CLICK NecrosisPetMenu"..i..":LeftButton"] = (self.Spell[i+1] and self.Spell[i+1].Name) or ("Pet " .. (i+1))
	end
	
	local buttonID = {1, 7, 8, 9, 10}
	local BuffID = {15, -- fel domination
	                8,  -- summon infernal
	                30, -- ritual of doom
	                35, -- enslave demon
	                44} -- demonic sacrifice
	for i = 1, #buttonID, 1 do
		_G["BINDING_NAME_CLICK NecrosisPetMenu"..buttonID[i]..":LeftButton"] = (self.Spell[BuffID[i]] and self.Spell[BuffID[i]].Name) or ""
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Quatrieme section
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	
	local curseMenuName = (self.Config.Menus and self.Config.Menus["Menu des Maledictions"]) or "Curses"
	_G["BINDING_HEADER_NecrosisCurse"] = "Necrosis - " .. curseMenuName
	_G["BINDING_NAME_CLICK NecrosisCurseMenuButton:LeftButton"] = curseMenuName
	
	local buffID = {23, -- curse of weakness
	                22, -- curse of agony
	                25, -- curse of tongues
	                40, -- curse of exhaustion
	                26, -- curse of the elements
	                16, -- curse of doom
	                14} -- corruption
	for i = 1, #buffID, 1 do
		_G["BINDING_NAME_CLICK NecrosisCurseMenu"..i..":LeftButton"] = (self.Spell[buffID[i]] and self.Spell[buffID[i]].Name) or ""
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Cinquieme section
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	
	-- Le Titre
	local metaName = (self.Spell[27] and self.Spell[27].Name) or "Metamorphosis"
	_G["BINDING_HEADER_NecrosisMetamorphosis"] = "Necrosis - " .. metaName
	
	_G["BINDING_NAME_CLICK NecrosisMetamorphosisButton:LeftButton"] = metaName
	
	local buffID = {39, 58, 56, 57}
	for i = 1, #buffID, 1 do
		_G["BINDING_NAME_CLICK NecrosisMetamorphosisMenu"..i..":LeftButton"] = (self.Spell[buffID[i]] and self.Spell[buffID[i]].Name) or ""
	end
end
