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

-- On définit G comme étant le tableau contenant toutes les frames existantes.
-- luacheck: globals Necrosis NecrosisConfig NecrosisTimerColor NecrosisShardCount NecrosisButton NecrosisListSpells
local _G = _G
local GetTime = GetTime
local floor = math.floor
local format = string.format
local tconcat = table.concat
local twipe = table.wipe or wipe
local textTimerParts = {}
Necrosis = Necrosis or _G.Necrosis or {}
_G.Necrosis = Necrosis

------------------------------------------------------------------------------------------------------
-- NON-GRAPHICAL TIMERS FUNCTIONS || FONCTIONS D'AFFICHAGE DES TIMERS NON GRAPHIQUES
------------------------------------------------------------------------------------------------------

-- Displays the resurrection timer in the sphere || Permet l'affichage du timer de rez dans la Sphere
function Necrosis:RezTimerUpdate(SpellTimer, LastUpdate)
    local Time, TimeMax, Minutes, Secondes
    for _, valeur in ipairs(SpellTimer) do
        if valeur.Name == Necrosis.Spell[11].Name then
            Time = valeur.Time
            TimeMax = valeur.TimeMax
            break
        end
    end
    if not Time then
        NecrosisShardCount:SetText("???")
        NecrosisButton:SetNormalTexture("Interface\\AddOns\\NecrosisPlus\\UI\\Shard")
        return LastUpdate
    end

    Secondes = TimeMax - floor(GetTime())
    if Secondes < 0 then
        Secondes = 0
    end
    Minutes = floor(Secondes / 60)
    Secondes = Secondes % 60

    -- Le timer numérique
    if NecrosisConfig.CountType == 3 then
        if Minutes > 0 then
            NecrosisShardCount:SetText(Minutes .. " m")
        else
            NecrosisShardCount:SetText(Secondes)
        end
    end
    -- Le timer graphique
    if NecrosisConfig.Circle == 2 then
        if Minutes >= 16 then
            if LastUpdate ~= "Turquoise\\Shard" .. (Minutes - 15) then
                LastUpdate = "Turquoise\\Shard" .. (Minutes - 15)
                NecrosisButton:SetNormalTexture("Interface\\AddOns\\NecrosisPlus\\UI\\" .. LastUpdate)
            end
        elseif Minutes >= 1 or Secondes >= 33 then
            if LastUpdate ~= "Orange\\Shard" .. (Minutes + 1) then
                LastUpdate = "Orange\\Shard" .. (Minutes + 1)
                NecrosisButton:SetNormalTexture("Interface\\AddOns\\NecrosisPlus\\UI\\" .. LastUpdate)
            end
        elseif LastUpdate ~= "Rose\\Shard" .. Secondes then
            LastUpdate = "Rose\\Shard" .. Secondes
            NecrosisButton:SetNormalTexture("Interface\\AddOns\\NecrosisPlus\\UI\\" .. LastUpdate)
        end
    end

    return LastUpdate
end

-- Allows the viewing of recorded timers || Permet l'affichage des timers textuels
-- and other textual timers || Allows the posting of text timers
function Necrosis:TextTimerUpdate(SpellTimer, SpellGroup)
    if not _G["NecrosisListSpells"] then
        return
    end
    if not SpellTimer[1] then
        NecrosisListSpells:SetText("")
        return
    end

    local Now = floor(GetTime())
    local LastGroup = 0
    local n = 0
    twipe(textTimerParts)

    for index = 1, #SpellTimer do
        local timer = SpellTimer[index]
        local duration = (timer.Time and timer.Time > 0) and timer.Time or 1
        local percent = (floor(timer.TimeMax - Now) / duration) * 100
        if percent < 0 then
            percent = 0
        end
        local color = NecrosisTimerColor(percent)

        -- Affichage de l'entête si on change de groupe
        if timer.Group and timer.Group ~= LastGroup and timer.Group > 3 then
            local grp = SpellGroup[timer.Group]
            if grp and grp.Name then
                n = n + 1
                textTimerParts[n] = format(
                    "<purple>-------------------------------\n%s - %s\n-------------------------------<close>\n<white>",
                    grp.Name,
                    grp.SubName or ""
                )
            end
            LastGroup = timer.Group
        end

        -- Affichage du temps restant
        local seconds = timer.TimeMax - Now
        if seconds < 0 then
            seconds = 0
        end
        local minutes = floor(seconds / 60)
        seconds = seconds % 60
        if minutes > 0 then
            n = n + 1
            textTimerParts[n] = format("%02d:%02d - <close>%s%s<close>", minutes, seconds, color, timer.Name)
        else
            n = n + 1
            textTimerParts[n] = format("0:%02d - <close>%s%s<close>", seconds, color, timer.Name)
        end

        if timer.Target == nil then
            timer.Target = ""
        end

        n = n + 1
        if (timer.Type == 1 or timer.Name == Necrosis.Spell[16].Name) and timer.Target ~= "" then
            textTimerParts[n] = "<white> - " .. timer.Target .. "<close>\n"
        else
            textTimerParts[n] = "\n"
        end
    end
    local display = self:MsgAddColor(tconcat(textTimerParts))
    NecrosisListSpells:SetText(display)
end
