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
-- Skins et voix Françaises : Eliah, Ner'zhul
--
-- Version Allemande par Geschan
-- Version Espagnole par DosS (Zul’jin)
-- Version Russe par Komsomolka
--
-- Version $LastChangedDate: 2010-08-04 12:04:27 +1000 (Wed, 04 Aug 2010) $
------------------------------------------------------------------------------------------------------

local _G = _G
Necrosis = Necrosis or _G.Necrosis or {}
_G.Necrosis = Necrosis

local version
if GetAddOnMetadata then
	version = GetAddOnMetadata("Necrosis", "Version")
end
version = version or "3.0"

Necrosis.Data = {
	Version = version,
	AppName = "Necrosis LdC",
	LastConfig = 20100701
}
Necrosis.Data.Label = Necrosis.Data.AppName .. " " .. Necrosis.Data.Version

Necrosis.Speech = Necrosis.Speech or {}
Necrosis.Unit = Necrosis.Unit or {}
Necrosis.Translation = Necrosis.Translation or {}
Necrosis.Config = Necrosis.Config or {}
