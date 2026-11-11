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

-- luacheck: globals Necrosis NecrosisConfig SLASH_NecrosisCommand1 SLASH_NecrosisCommand2 NecrosisAntiFearButton NecrosisBacklashButton NecrosisButton NecrosisCreatureAlertButton NecrosisListSpells NecrosisShadowTranceButton NecrosisSpellTimerButton NecrosisTimerFrame0

-- On définit _G comme étant le tableau contenant toutes les frames existantes.
local _G = _G
Necrosis = Necrosis or _G.Necrosis or {}
_G.Necrosis = Necrosis

------------------------------------------------------------------------------------------------------
-- FONCTION D'INITIALISATION
------------------------------------------------------------------------------------------------------

function Necrosis:Initialize(Config)
    -- Initilialisation des Textes (VO / VF / VA / VCT / VCS / VE)
    local lang = (NecrosisConfig and NecrosisConfig.Language) or (GetLocale and GetLocale()) or "enUS"
    if (lang == "ruRU") and self.Localization_Dialog_Ru then
        self:Localization_Dialog_Ru()
    elseif (lang == "deDE") and self.Localization_Dialog_De then
        self:Localization_Dialog_De()
    elseif (lang == "zhTW") and self.Localization_Dialog_Tw then
        self:Localization_Dialog_Tw()
    elseif (lang == "zhCN") and self.Localization_Dialog_Cn then
        self:Localization_Dialog_Cn()
    elseif (lang == "esES") and self.Localization_Dialog_Es then
        self:Localization_Dialog_Es()
    elseif (lang == "frFR") and self.Localization_Dialog_Fr then
        self:Localization_Dialog_Fr()
    elseif self.Localization_Dialog_En then
        self:Localization_Dialog_En()
    elseif self.Localization_Dialog_Fr then
        self:Localization_Dialog_Fr()
    elseif self.Localization_Dialog_Ru then
        self:Localization_Dialog_Ru()
    end

    -- Fallback tables en cas d'absence d'une localisation
    self.TooltipData = self.TooltipData or {}
    self.Localize = self.Localize or { Utilisation = "Use", Echange = "Trade" }
    self.ChatMessage = self.ChatMessage or {}
    self.Config = self.Config or {}

    -- On charge (ou on crée la configuration pour le joueur et on l'affiche sur la console
    if
        not NecrosisConfig.Version
        or type(NecrosisConfig.Version) == "string"
        or Necrosis.Data.LastConfig > NecrosisConfig.Version
    then
        NecrosisConfig = {}
        NecrosisConfig = Config
        NecrosisConfig.Version = Necrosis.Data.LastConfig
        self:Msg(self.ChatMessage.Interface.DefaultConfig, "USER")
    else
        self:Msg(self.ChatMessage.Interface.UserConfig, "USER")
    end

    self:CreateWarlockUI()
    self:CreateWarlockPopup()

    -----------------------------------------------------------
    -- Exécution des fonctions de démarrage
    -----------------------------------------------------------
    -- Affichage d'un message sur la console
    self:Msg(self.ChatMessage.Interface.Welcome, "USER")
    -- Création de la liste des sorts disponibles
    for index in ipairs(self.Spell) do
        self.Spell[index].ID = nil
    end
    self:SpellLocalize()
    self:SpellSetup()
    self:CreateMenu()
    self:ButtonSetup()

    -- Enregistrement de la commande console
    SlashCmdList["NecrosisCommand"] = Necrosis.SlashHandler
    SLASH_NecrosisCommand1 = "/necrosis"
    SLASH_NecrosisCommand2 = "/necrosisplus"

    -- Blizzard Interface Options Category (Wiki Ch 10)
    if not self.BlizzardOptionsPanel then
        local panel = CreateFrame("Frame", "NecrosisBlizzardOptionsPanel", UIParent)
        panel.name = "Necrosis Plus"

        local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 16, -16)
        title:SetText("Necrosis Plus " .. (self.Data.Version or "3.0"))

        local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        desc:SetText(
            "Warlock UI & Shard Management / Менеджер заклинаний, камней и демонов"
        )

        local openBtn = CreateFrame("Button", nil, panel, "OptionsButtonTemplate")
        openBtn:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
        openBtn:SetText("Открыть настройки Necrosis Plus")
        openBtn:SetWidth(200)
        openBtn:SetHeight(24)
        openBtn:SetScript("OnClick", function()
            InterfaceOptionsFrame_Show()
            Necrosis:OpenConfigPanel()
        end)

        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
        end
        self.BlizzardOptionsPanel = panel
    end

    -- On règle la taille de la pierre et des boutons suivant les réglages du SavedVariables
    NecrosisButton:SetScale(NecrosisConfig.NecrosisButtonScale / 100)
    NecrosisShadowTranceButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)
    NecrosisBacklashButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)
    NecrosisAntiFearButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)
    NecrosisCreatureAlertButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)

    -- On définit l'affichage des Timers Graphiques à gauche ou à droite du bouton
    if _G["NecrosisTimerFrame0"] then
        NecrosisTimerFrame0:ClearAllPoints()
        NecrosisTimerFrame0:SetPoint(
            NecrosisConfig.SpellTimerJust,
            NecrosisSpellTimerButton,
            "CENTER",
            NecrosisConfig.SpellTimerPos * 20,
            0
        )
    end

    -- On définit l'affichage des Timers Textes à gauche ou à droite du bouton
    if _G["NecrosisListSpells"] then
        NecrosisListSpells:ClearAllPoints()
        NecrosisListSpells:SetJustifyH(NecrosisConfig.SpellTimerJust)
        NecrosisListSpells:SetPoint(
            "TOP" .. NecrosisConfig.SpellTimerJust,
            "NecrosisSpellTimerButton",
            "CENTER",
            NecrosisConfig.SpellTimerPos * 23,
            5
        )
    end

    --On affiche ou on cache le bouton, d'ailleurs !
    if not NecrosisConfig.ShowSpellTimers then
        NecrosisSpellTimerButton:Hide()
    end

    -- Le Shard est-il verrouillé sur l'interface ?
    if NecrosisConfig.NoDragAll then
        self:NoDrag()
        NecrosisButton:RegisterForDrag("")
        NecrosisSpellTimerButton:RegisterForDrag("")
    else
        self:Drag()
        NecrosisButton:RegisterForDrag("LeftButton")
        NecrosisSpellTimerButton:RegisterForDrag("LeftButton")
    end

    -- Inventaire des pierres et des fragments possedés par le Démoniste
    self:BagExplore()

    -- Si la sphere doit indiquer la vie ou la mana, on y va
    Necrosis:UpdateHealth()
    Necrosis:UpdateMana()

    -- On vérifie que les fragments sont dans le sac défini par le Démoniste
    if NecrosisConfig.SoulshardSort then
        self:SoulshardSwitch("CHECK")
    end

    -- Initialisation des fichiers de langues -- Mise en place ponctuelle du SMS
    if self.Localization then
        self:Localization()
    elseif self.Localization_Speech_Ru and (lang == "ruRU") then
        self:Localization_Speech_Ru()
    elseif self.Localization_Speech_En then
        self:Localization_Speech_En()
    end
    if NecrosisConfig.SM then
        self.Speech.Rez = self.Speech.ShortMessage[1]
        self.Speech.TP = self.Speech.ShortMessage[2]
    end
end

------------------------------------------------------------------------------------------------------
-- FONCTION GERANT LA COMMANDE CONSOLE /NECRO
------------------------------------------------------------------------------------------------------

function Necrosis.SlashHandler(arg1)
    arg1 = arg1 or ""
    if arg1:lower():find("recall") then
        Necrosis:Recall()
    elseif arg1:lower():find("reset") and not InCombatLockdown() then
        NecrosisConfig = {}
        ReloadUI()
    elseif arg1:lower():find("glasofruix") then
        NecrosisConfig.Smooth = not NecrosisConfig.Smooth
        Necrosis:Msg("SpellTimer smoothing  : <lightBlue>Toggled")
    else
        Necrosis:OpenConfigPanel()
    end
end
