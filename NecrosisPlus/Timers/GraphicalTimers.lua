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
-- Version $LastChangedDate: 2009-12-10 17:09:53 +1100 (Thu, 10 Dec 2009) $
------------------------------------------------------------------------------------------------------

-- luacheck: globals Necrosis NecrosisConfig NecrosisUpdateTimer NecrosisTimerFrame0
local _G = _G
Necrosis = Necrosis or _G.Necrosis or {}
_G.Necrosis = Necrosis
local GetTime = GetTime
local floor = math.floor
local fmod = math.fmod
local format = string.format

------------------------------------------------------------------------------------------------------
-- FUNCTIONS FOR CREATION OF FRAMES ||FONCTIONS DE CREATION DES FRAMES
------------------------------------------------------------------------------------------------------

--Creation of headers for timer groups || Création des entêtes des groupes de timers
function Necrosis:CreateGroup(SpellGroup, index)
    local texte
    if _G["NecrosisSpellTimer" .. index] then
        local f = _G["NecrosisSpellTimer" .. index]
        local FontString = _G["NecrosisSpellTimer" .. index .. "Text"]
        if SpellGroup[index] and SpellGroup[index].Name then
            texte = SpellGroup[index].Name
        else
            texte = "?"
        end
        if SpellGroup[index] and SpellGroup[index].SubName then
            texte = texte .. " - " .. SpellGroup[index].SubName
        else
            texte = texte .. " - ?"
        end
        if texte == "? - ?" then
            f:Hide()
        else
            FontString:SetText(texte)
            f:Show()
        end
        return f
    end

    local FrameName = "NecrosisSpellTimer" .. index
    local frame = CreateFrame("Frame", FrameName, UIParent)

    -- Définition de ses attributs
    frame:SetWidth(150)
    frame:SetHeight(10)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 3000, 3000)
    frame:Show()

    -- Définition de la Frame du texte
    local FontString = frame:CreateFontString(FrameName .. "Text", "OVERLAY", "TextStatusBarText")

    FontString:SetWidth(150)
    FontString:SetHeight(10)
    FontString:SetJustifyH("CENTER")
    FontString:SetJustifyV("MIDDLE")
    FontString:SetTextColor(1, 1, 1)
    FontString:ClearAllPoints()
    FontString:SetPoint("LEFT", FrameName, "LEFT", 0, 0)
    FontString:Show()

    -- Définition du texte
    if SpellGroup[index] and SpellGroup[index].Name then
        texte = SpellGroup[index].Name
    else
        texte = "?"
    end
    if SpellGroup[index] and SpellGroup[index].SubName then
        texte = texte .. " - " .. SpellGroup[index].SubName
    else
        texte = texte .. " - ?"
    end
    if texte == "? - ?" then
        frame:Hide()
    else
        FontString:SetText(texte)
        frame:Show()
    end

    return frame
end

-- Creation of the timers || Création des timers
function Necrosis:AddFrame(FrameName)
    if _G[FrameName] then
        local f = _G[FrameName]
        f._lastSec = nil
        f._lastTarget = nil
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        f:Show()
        return f._text or _G[FrameName .. "Text"], f._bar or _G[FrameName .. "Bar"]
    end

    -- Création de la frame principale du timer
    local frame = CreateFrame("Frame", FrameName, UIParent)

    -- Définition de ses attributs
    frame:SetWidth(150)
    frame:SetHeight(10)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", 3000, 3000)
    frame:Show()

    --Définition de sa texture
    local texture = frame:CreateTexture(FrameName .. "Texture", "BACKGROUND")

    texture:SetWidth(150)
    texture:SetHeight(10)
    texture:SetTexture(0, 0, 0, 0.5)
    texture:ClearAllPoints()
    texture:SetPoint(NecrosisConfig.SpellTimerJust, FrameName, NecrosisConfig.SpellTimerJust, 0, 0)
    texture:Show()

    -- Définition de ses textes
    -- Extérieur
    local outFontString = frame:CreateFontString(FrameName .. "OutText", "OVERLAY", "TextStatusBarText")
    local FontString = outFontString

    FontString:SetWidth(150)
    FontString:SetHeight(10)
    FontString:SetTextColor(1, 1, 1)
    FontString:ClearAllPoints()

    if NecrosisConfig.SpellTimerPos == -1 then
        FontString:SetPoint("RIGHT", FrameName, "LEFT", -5, 1)
        FontString:SetJustifyH("RIGHT")
    else
        FontString:SetPoint("LEFT", FrameName, "RIGHT", 5, 1)
        FontString:SetJustifyH("LEFT")
    end
    FontString:Show()

    -- Définition de ses textes
    -- Intérieur
    FontString = frame:CreateFontString(FrameName .. "Text", "OVERLAY", "GameFontNormalSmall")

    FontString:SetWidth(150)
    FontString:SetHeight(10)
    FontString:SetJustifyH("LEFT")
    FontString:SetJustifyV("MIDDLE")
    FontString:ClearAllPoints()
    FontString:SetPoint("LEFT", FrameName, "LEFT", 0, 0)
    FontString:Show()

    FontString:SetTextColor(1, 1, 1)

    -- Définition de la barre colorée
    local StatusBar = CreateFrame("StatusBar", FrameName .. "Bar", frame)

    StatusBar:SetWidth(150)
    StatusBar:SetHeight(10)
    StatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    StatusBar:SetStatusBarColor(1, 1, 0)
    StatusBar:SetFrameLevel(StatusBar:GetFrameLevel() - 1)
    StatusBar:ClearAllPoints()
    StatusBar:SetPoint(NecrosisConfig.SpellTimerJust, FrameName, NecrosisConfig.SpellTimerJust, 0, 0)
    StatusBar:Show()

    -- Définition de l'étincelle en bout de barre
    texture = StatusBar:CreateTexture(FrameName .. "Spark", "OVERLAY")

    texture:SetWidth(32)
    texture:SetHeight(32)
    texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    texture:SetBlendMode("ADD")
    texture:ClearAllPoints()
    texture:SetPoint("CENTER", StatusBar, "LEFT", 0, 0)
    texture:Show()

    -- Cache child references to avoid per-frame _G string concatenation
    frame._bar = StatusBar
    frame._spark = texture
    frame._outText = outFontString
    frame._text = FontString
    frame._lastSec = nil
    frame._lastTarget = nil

    return FontString, StatusBar
end

------------------------------------------------------------------------------------------------------
-- FUNCTIONS TO UPDATE THE DISPLAY || FONCTION DE MISE À JOUR DE L'AFFICHAGE
------------------------------------------------------------------------------------------------------

function NecrosisUpdateTimer(tableau, Changement)
    if not (NecrosisConfig.TimerType == 1 and tableau[1]) then
        return
    end

    local pt, relTo, relPt, xOfs, yOfs = NecrosisTimerFrame0:GetPoint()
    local LastGroup = 0

    local yPosition = -NecrosisConfig.SensListe * 12

    -- smooth timers (if selected) || *Lisse* l'écoulement des timers si option sélectionnée
    local Now
    if NecrosisConfig.Smooth then
        Now = GetTime()
    else
        Now = floor(GetTime())
    end

    for index = 1, #tableau, 1 do
        -- Ca arrive quand on passe des timers textes aux timers graphiques
        local gtimer = tableau[index].Gtimer
        if gtimer then
            -- selection of frames timer that vary with time || Sélection des frames du timer qui varient en fonction du temps
            local Frame = _G["NecrosisTimerFrame" .. gtimer]
            local StatusBar = Frame and (Frame._bar or _G["NecrosisTimerFrame" .. gtimer .. "Bar"])
            local Spark = Frame and (Frame._spark or _G["NecrosisTimerFrame" .. gtimer .. "Spark"])
            local Text = Frame and (Frame._outText or _G["NecrosisTimerFrame" .. gtimer .. "OutText"])

            if Frame and StatusBar and Spark and Text then
                -- move frames to ensure they dont overlap || Déplacement des Frames si besoin pour qu'elles ne se chevauchent pas
                if Changement then
                    -- if the frame belongs to a mob group, then move the whole group || Si les Frames appartiennent à un groupe de mob, et qu'on doit changer de groupe
                    if tableau[index].Group ~= LastGroup and tableau[index].Group > 3 then
                        local f = Necrosis:CreateGroup(Changement, tableau[index].Group)
                        yOfs = yOfs + 1.2 * yPosition
                        f:ClearAllPoints()
                        f:SetPoint(pt, relTo, relPt, xOfs, yOfs)
                        yOfs = yOfs + 0.2 * yPosition
                        LastGroup = tableau[index].Group
                    end
                    Frame:ClearAllPoints()
                    yOfs = yOfs + yPosition
                    Frame:SetPoint(pt, relTo, relPt, xOfs, yOfs)
                end

                -- creation of color timers || Création de la couleur des timers en fonction du temps
                local duration = (tableau[index].Time and tableau[index].Time > 0) and tableau[index].Time or 1
                local r, g
                local b = 37 / 255
                local PercentColor = (tableau[index].TimeMax - Now) / duration
                if PercentColor < 0 then
                    PercentColor = 0
                end
                if PercentColor > 0.5 then
                    r = (207 / 255) - (1 - PercentColor) * 2 * (207 / 255)
                    g = 1
                else
                    r = 1
                    g = (207 / 255) - (0.5 - PercentColor) * 2 * (207 / 255)
                end

                -- calculate the position of the spark on the timer || Calcul de la position de l'étincelle sur la barre de status
                local sparkPosition = 150 * (tableau[index].TimeMax - Now) / duration
                if sparkPosition < 1 then
                    sparkPosition = 1
                end

                -- set the color and determine the portion to be filled || Définition de la couleur du timer et de la quantitée de jauge remplie
                StatusBar:SetValue(2 * tableau[index].TimeMax - (duration + Now))
                StatusBar:SetStatusBarColor(r, g, b)
                Spark:ClearAllPoints()
                Spark:SetPoint("CENTER", StatusBar, "LEFT", sparkPosition, 0)

                -- Only reformat and update timer text when the integer second or target changes
                local remSec = tableau[index].TimeMax - floor(Now)
                if remSec < 0 then
                    remSec = 0
                end
                local showTarget = (
                    tableau[index].Type == 1
                    or tableau[index].Type == 3
                    or tableau[index].Name == Necrosis.Spell[16].Name
                )
                    and tableau[index].Target
                    and tableau[index].Target ~= ""
                local targetKey = showTarget and tableau[index].Target or ""
                if Frame._lastSec ~= remSec or Frame._lastTarget ~= targetKey then
                    Frame._lastSec = remSec
                    Frame._lastTarget = targetKey
                    local minutes = floor(remSec / 60)
                    local secondes = fmod(remSec, 60)
                    local affichage = format("%02d:%02d", minutes, secondes)
                    if showTarget then
                        if NecrosisConfig.SpellTimerPos == 1 then
                            affichage = affichage .. " - " .. targetKey
                        else
                            affichage = targetKey .. " - " .. affichage
                        end
                    end
                    Text:SetText(affichage)
                end
            end
        end
    end
end
