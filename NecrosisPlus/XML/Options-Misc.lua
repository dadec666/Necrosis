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
-- $LastChangedDate: 2009-08-17 15:50:02 +1000 (Mon, 17 Aug 2009) $
------------------------------------------------------------------------------------------------------

-- luacheck: globals Necrosis NecrosisAntiFearButton NecrosisBacklashButton NecrosisButton NecrosisConfig NecrosisCreatureAlertButton NecrosisDestroyCount NecrosisDestroyCountHigh NecrosisDestroyCountLow NecrosisDestroyShard NecrosisDestroyShardBag NecrosisGeneralFrame NecrosisHiddenButtons NecrosisHiddenSize NecrosisHiddenSizeHigh NecrosisHiddenSizeLow NecrosisHiddenSizeText NecrosisLock NecrosisMiscConfig NecrosisMoveShard NecrosisShadowTranceButton NecrosisShardBag NecrosisShardBagHigh NecrosisShardBagLow NecrosisShardBagText NecrosisSpellTimerButton

-- On définit G comme étant le tableau contenant toutes les frames existantes.
local _G = _G
Necrosis = Necrosis or _G.Necrosis or {}
_G.Necrosis = Necrosis

------------------------------------------------------------------------------------------------------
-- CREATION DE LA FRAME DES OPTIONS
------------------------------------------------------------------------------------------------------

function Necrosis:SetMiscConfig()
    local frame = _G["NecrosisMiscConfig"]
    if not frame then
        -- Création de la fenêtre
        frame = CreateFrame("Frame", "NecrosisMiscConfig", NecrosisGeneralFrame)
        frame:SetFrameStrata("DIALOG")
        frame:SetMovable(false)
        frame:EnableMouse(true)
        frame:SetWidth(350)
        frame:SetHeight(452)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT")

        -- Déplacement des fragments
        frame = CreateFrame("CheckButton", "NecrosisMoveShard", NecrosisMiscConfig, "UICheckButtonTemplate")
        frame:EnableMouse(true)
        frame:SetWidth(24)
        frame:SetHeight(24)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("LEFT", NecrosisMiscConfig, "BOTTOMLEFT", 25, 400)

        frame:SetScript("OnClick", function(btn)
            NecrosisConfig.SoulshardSort = btn:GetChecked()
            if NecrosisConfig.SoulshardSort then
                NecrosisDestroyShardBag:Enable()
            else
                NecrosisDestroyShardBag:Disable()
            end
        end)

        local FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
        FontString:Show()
        FontString:ClearAllPoints()
        FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
        FontString:SetTextColor(1, 1, 1)
        frame:SetFontString(FontString)

        -- Destruction des fragments quand le sac est plein
        frame = CreateFrame("CheckButton", "NecrosisDestroyShardBag", NecrosisMiscConfig, "UICheckButtonTemplate")
        frame:EnableMouse(true)
        frame:SetWidth(24)
        frame:SetHeight(24)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("LEFT", NecrosisMiscConfig, "BOTTOMLEFT", 50, 380)

        frame:SetScript("OnClick", function(btn)
            NecrosisConfig.SoulshardDestroy = btn:GetChecked()
        end)

        FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
        FontString:Show()
        FontString:ClearAllPoints()
        FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
        FontString:SetTextColor(1, 1, 1)
        frame:SetFontString(FontString)
        --frame:SetDisabledTextColor(0.75, 0.75, 0.75)

        -- Choose the bag for storing soul shards || Choix du sac à fragments
        frame = CreateFrame("Slider", "NecrosisShardBag", NecrosisMiscConfig, "OptionsSliderTemplate")
        frame:SetMinMaxValues(0, 4)
        frame:SetValueStep(1)
        frame:SetWidth(150)
        frame:SetHeight(15)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", NecrosisMiscConfig, "BOTTOMLEFT", 225, 340)

        frame:SetScript("OnEnter", function(slider)
            GameTooltip:SetOwner(slider, "ANCHOR_RIGHT")
            GameTooltip:SetText(5 - slider:GetValue())
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        frame:SetScript("OnMouseUp", function(slider)
            GameTooltip:SetText(5 - slider:GetValue())
            NecrosisConfig.SoulshardContainer = 4 - slider:GetValue()
            Necrosis:SoulshardSwitch("MOVE")
        end)
        frame:SetScript("OnValueChanged", function(slider)
            GameTooltip:SetText(5 - slider:GetValue())
        end)

        NecrosisShardBagLow:SetText("5")
        NecrosisShardBagHigh:SetText("1")

        -- Set the number of shards to keep || Destruction des fragments après X
        frame = CreateFrame("CheckButton", "NecrosisDestroyShard", NecrosisMiscConfig, "UICheckButtonTemplate")
        frame:EnableMouse(true)
        frame:SetWidth(24)
        frame:SetHeight(24)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("LEFT", NecrosisMiscConfig, "BOTTOMLEFT", 25, 280)

        frame:SetScript("OnClick", function(btn)
            NecrosisConfig.DestroyShard = btn:GetChecked()
            Necrosis:BagExplore()
        end)

        FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
        FontString:Show()
        FontString:ClearAllPoints()
        FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
        FontString:SetTextColor(1, 1, 1)
        frame:SetFontString(FontString)

        frame = CreateFrame("Slider", "NecrosisDestroyCount", NecrosisMiscConfig, "OptionsSliderTemplate")
        frame:SetMinMaxValues(1, 32)
        frame:SetValueStep(1)
        frame:SetWidth(150)
        frame:SetHeight(15)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", NecrosisMiscConfig, "BOTTOMLEFT", 225, 255)

        frame:SetScript("OnEnter", function(slider)
            GameTooltip:SetOwner(slider, "ANCHOR_RIGHT")
            GameTooltip:SetText(slider:GetValue())
        end)
        frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        frame:SetScript("OnValueChanged", function(slider)
            GameTooltip:SetText(slider:GetValue())
        end)
        frame:SetScript("OnMouseUp", function(slider)
            GameTooltip:SetText(slider:GetValue())
            NecrosisConfig.DestroyCount = slider:GetValue()
            NecrosisDestroyShard:SetChecked(true)
            NecrosisConfig.DestroyShard = true
            Necrosis:BagExplore()
        end)

        NecrosisDestroyCountLow:SetText("1")
        NecrosisDestroyCountHigh:SetText("32")
        --[[
		FontString = frame:CreateFontString(nil, nil, "ChatFontNormal")
		FontString:SetFont("Fonts\\ARIALN.TTF", 12)
		FontString:SetTextColor(1, 1, 1)
--]]
        -- Verrouillage de Necrosis
        frame = CreateFrame("CheckButton", "NecrosisLock", NecrosisMiscConfig, "UICheckButtonTemplate")
        frame:EnableMouse(true)
        frame:SetWidth(24)
        frame:SetHeight(24)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("LEFT", NecrosisMiscConfig, "BOTTOMLEFT", 25, 225)

        frame:SetScript("OnClick", function(btn)
            if btn:GetChecked() then
                Necrosis:NoDrag()
                NecrosisButton:RegisterForDrag("")
                NecrosisSpellTimerButton:RegisterForDrag("")
                NecrosisConfig.NoDragAll = true
            else
                if not NecrosisConfig.NecrosisLockServ then
                    Necrosis:Drag()
                end
                NecrosisButton:RegisterForDrag("LeftButton")
                NecrosisSpellTimerButton:RegisterForDrag("LeftButton")
                NecrosisConfig.NoDragAll = false
            end
        end)

        FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
        FontString:Show()
        FontString:ClearAllPoints()
        FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
        FontString:SetTextColor(1, 1, 1)
        frame:SetFontString(FontString)

        -- Affichage des boutons cachés
        frame = CreateFrame("CheckButton", "NecrosisHiddenButtons", NecrosisMiscConfig, "UICheckButtonTemplate")
        frame:EnableMouse(true)
        frame:SetWidth(24)
        frame:SetHeight(24)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("LEFT", NecrosisMiscConfig, "BOTTOMLEFT", 25, 200)

        frame:SetScript("OnClick", function(btn)
            if btn:GetChecked() then
                NecrosisShadowTranceButton:Show()
                NecrosisBacklashButton:Show()
                NecrosisAntiFearButton:Show()
                NecrosisCreatureAlertButton:Show()
                NecrosisShadowTranceButton:RegisterForDrag("LeftButton")
                NecrosisBacklashButton:RegisterForDrag("LeftButton")
                NecrosisAntiFearButton:RegisterForDrag("LeftButton")
                NecrosisCreatureAlertButton:RegisterForDrag("LeftButton")
            else
                NecrosisShadowTranceButton:Hide()
                NecrosisBacklashButton:Hide()
                NecrosisAntiFearButton:Hide()
                NecrosisCreatureAlertButton:Hide()
                NecrosisShadowTranceButton:RegisterForDrag("")
                NecrosisBacklashButton:RegisterForDrag("")
                NecrosisAntiFearButton:RegisterForDrag("")
                NecrosisCreatureAlertButton:RegisterForDrag("")
            end
        end)

        FontString = frame:CreateFontString(nil, nil, "GameFontNormalSmall")
        FontString:Show()
        FontString:ClearAllPoints()
        FontString:SetPoint("LEFT", frame, "RIGHT", 5, 1)
        FontString:SetTextColor(1, 1, 1)
        frame:SetFontString(FontString)

        -- Tailles boutons cachés
        frame = CreateFrame("Slider", "NecrosisHiddenSize", NecrosisMiscConfig, "OptionsSliderTemplate")
        frame:SetMinMaxValues(50, 200)
        frame:SetValueStep(5)
        frame:SetWidth(150)
        frame:SetHeight(15)
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", NecrosisMiscConfig, "BOTTOMLEFT", 225, 150)

        local STx, STy, BLx, BLy, AFx, AFy, CAx, CAy
        local function UpdateHiddenCenters()
            local scale = (NecrosisConfig.ShadowTranceScale or 100) / 100
            local x, y = NecrosisShadowTranceButton:GetCenter()
            STx, STy = (x or 0) * scale, (y or 0) * scale
            x, y = NecrosisBacklashButton:GetCenter()
            BLx, BLy = (x or 0) * scale, (y or 0) * scale
            x, y = NecrosisAntiFearButton:GetCenter()
            AFx, AFy = (x or 0) * scale, (y or 0) * scale
            x, y = NecrosisCreatureAlertButton:GetCenter()
            CAx, CAy = (x or 0) * scale, (y or 0) * scale
        end
        frame:SetScript("OnEnter", function(slider)
            UpdateHiddenCenters()

            NecrosisShadowTranceButton:Show()
            NecrosisBacklashButton:Show()
            NecrosisAntiFearButton:Show()
            NecrosisCreatureAlertButton:Show()
            GameTooltip:SetOwner(slider, "ANCHOR_RIGHT")
            GameTooltip:SetText(slider:GetValue() .. "%")
        end)
        frame:SetScript("OnLeave", function()
            if not NecrosisHiddenButtons:GetChecked() then
                NecrosisShadowTranceButton:Hide()
                NecrosisBacklashButton:Hide()
                NecrosisAntiFearButton:Hide()
                NecrosisCreatureAlertButton:Hide()
            end
            GameTooltip:Hide()
        end)
        frame:SetScript("OnValueChanged", function(slider)
            if slider:GetValue() ~= NecrosisConfig.ShadowTranceScale then
                if not (STx and STy and BLx and BLy and AFx and AFy and CAx and CAy) then
                    UpdateHiddenCenters()
                end
                if GameTooltip:IsOwned(slider) then
                    GameTooltip:SetText(slider:GetValue() .. "%")
                end
                NecrosisConfig.ShadowTranceScale = slider:GetValue()

                NecrosisShadowTranceButton:ClearAllPoints()
                NecrosisShadowTranceButton:SetPoint(
                    "CENTER",
                    "UIParent",
                    "BOTTOMLEFT",
                    STx / (NecrosisConfig.ShadowTranceScale / 100),
                    STy / (NecrosisConfig.ShadowTranceScale / 100)
                )
                NecrosisShadowTranceButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)

                NecrosisBacklashButton:ClearAllPoints()
                NecrosisBacklashButton:SetPoint(
                    "CENTER",
                    "UIParent",
                    "BOTTOMLEFT",
                    BLx / (NecrosisConfig.ShadowTranceScale / 100),
                    BLy / (NecrosisConfig.ShadowTranceScale / 100)
                )
                NecrosisBacklashButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)

                NecrosisCreatureAlertButton:ClearAllPoints()
                NecrosisCreatureAlertButton:SetPoint(
                    "CENTER",
                    "UIParent",
                    "BOTTOMLEFT",
                    CAx / (NecrosisConfig.ShadowTranceScale / 100),
                    CAy / (NecrosisConfig.ShadowTranceScale / 100)
                )
                NecrosisCreatureAlertButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)

                NecrosisAntiFearButton:ClearAllPoints()
                NecrosisAntiFearButton:SetPoint(
                    "CENTER",
                    "UIParent",
                    "BOTTOMLEFT",
                    AFx / (NecrosisConfig.ShadowTranceScale / 100),
                    AFy / (NecrosisConfig.ShadowTranceScale / 100)
                )
                NecrosisAntiFearButton:SetScale(NecrosisConfig.ShadowTranceScale / 100)
            end
        end)

        NecrosisHiddenSizeLow:SetText("50 %")
        NecrosisHiddenSizeHigh:SetText("200 %")
    end

    NecrosisMoveShard:SetChecked(NecrosisConfig.SoulshardSort)
    NecrosisDestroyShardBag:SetChecked(NecrosisConfig.SoulshardDestroy)
    NecrosisShardBag:SetValue(4 - NecrosisConfig.SoulshardContainer)
    NecrosisDestroyShard:SetChecked(NecrosisConfig.DestroyShard)

    if NecrosisConfig.DestroyCount then
        NecrosisDestroyCount:SetValue(NecrosisConfig.DestroyCount)
    else
        NecrosisDestroyCount:SetValue(32)
    end

    NecrosisLock:SetChecked(NecrosisConfig.NoDragAll)
    NecrosisHiddenSize:SetValue(NecrosisConfig.ShadowTranceScale)

    NecrosisMoveShard:SetText(self.Config.Misc["Deplace les fragments"])
    NecrosisDestroyShardBag:SetText(self.Config.Misc["Detruit les fragments si le sac plein"])
    NecrosisShardBagText:SetText(self.Config.Misc["Choix du sac contenant les fragments"])
    NecrosisDestroyShard:SetText(self.Config.Misc["Nombre maximum de fragments a conserver"])
    NecrosisLock:SetText(self.Config.Misc["Verrouiller Necrosis sur l'interface"])
    NecrosisHiddenButtons:SetText(self.Config.Misc["Afficher les boutons caches"])
    NecrosisHiddenSizeText:SetText(self.Config.Misc["Taille des boutons caches"])

    if NecrosisConfig.SoulshardSort then
        NecrosisDestroyShardBag:Enable()
    else
        NecrosisDestroyShardBag:Disable()
    end

    NecrosisMiscConfig:Show()
end
