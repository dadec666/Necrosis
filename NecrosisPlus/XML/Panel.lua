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

-- luacheck: globals Necrosis NecrosisConfig NecrosisGeneralFrame NecrosisGeneralPageText NecrosisMessagesConfig NecrosisSphereConfig NecrosisButtonsConfig NecrosisMenusConfig NecrosisTimersConfig NecrosisMiscConfig

local _G = _G
local tinsert = table.insert
local InCombatLockdown = InCombatLockdown
Necrosis = Necrosis or _G.Necrosis or {}
_G.Necrosis = Necrosis

local PANEL_FRAME_NAMES = {
    "NecrosisMessagesConfig",
    "NecrosisSphereConfig",
    "NecrosisButtonsConfig",
    "NecrosisMenusConfig",
    "NecrosisTimersConfig",
    "NecrosisMiscConfig",
}

local TAB_ICONS = {
    "Interface\\Icons\\Ability_Creature_Cursed_03",
    "Interface\\Icons\\INV_Misc_Gem_Amethyst_02",
    "Interface\\Icons\\Trade_Engineering",
    "Interface\\Icons\\INV_Wand_1H_Stratholme_D_02",
    "Interface\\Icons\\Spell_Nature_TimeStop",
    "Interface\\Icons\\Ability_Creature_Disease_05",
}

local BACKDROP_DARK = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local helpShownOnce = false
local activePanelID = 1

------------------------------------------------------------------------------------------------------
-- TAINT-FREE MODERN DROPDOWN & CONTROL STYLING
------------------------------------------------------------------------------------------------------

local dropdownListFrame
local dropdownListButtons = {}
local dropdownTarget
local dropdownItemCount = 0
local dropdownInfoScratch = {}

local function EnsureDropdownList()
    if dropdownListFrame then
        return dropdownListFrame
    end
    local list = CreateFrame("Frame", "NecrosisModernDropdownList", UIParent)
    list:SetFrameStrata("FULLSCREEN_DIALOG")
    list:SetClampedToScreen(true)
    list:EnableMouse(true)
    list:SetBackdrop(BACKDROP_DARK)
    list:SetBackdropColor(0.08, 0.08, 0.11, 0.98)
    list:SetBackdropBorderColor(0.45, 0.38, 0.65, 1.0)
    list:Hide()
    list:SetScript("OnHide", function()
        dropdownTarget = nil
    end)
    dropdownListFrame = list
    return list
end

function Necrosis.DropDown_CreateInfo()
    dropdownInfoScratch.text = nil
    dropdownInfoScratch.checked = nil
    dropdownInfoScratch.func = nil
    return dropdownInfoScratch
end

function Necrosis.DropDown_AddButton(info)
    if not dropdownTarget or not info then
        return
    end
    local list = EnsureDropdownList()
    dropdownItemCount = dropdownItemCount + 1
    local idx = dropdownItemCount
    local btn = dropdownListButtons[idx]
    if not btn then
        btn = CreateFrame("Button", nil, list)
        btn:SetHeight(20)
        btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        btn:SetBackdropColor(0, 0, 0, 0)

        local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        txt:SetPoint("LEFT", btn, "LEFT", 16, 0)
        txt:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
        txt:SetJustifyH("LEFT")
        btn._text = txt

        local dot = btn:CreateTexture(nil, "OVERLAY")
        dot:SetWidth(6)
        dot:SetHeight(6)
        dot:SetPoint("LEFT", btn, "LEFT", 6, 0)
        dot:SetTexture(0.68, 0.58, 0.94, 1.0)
        dot:Hide()
        btn._dot = dot

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.24, 0.20, 0.36, 0.95)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0)
        end)
        btn:SetScript("OnClick", function(self)
            local target = dropdownTarget
            local fn = self._func
            local label = self._text:GetText()
            list:Hide()
            if target then
                target._selectedID = self:GetID()
                if target._text and label then
                    target._text:SetText(label)
                end
            end
            if fn then
                fn(self)
            end
        end)
        dropdownListButtons[idx] = btn
    end

    btn:SetID(idx)
    btn._func = info.func
    btn._text:SetText(info.text or "")
    if dropdownTarget._selectedID == idx or info.checked then
        btn._dot:Show()
        btn._text:SetTextColor(1, 0.95, 1)
    else
        btn._dot:Hide()
        btn._text:SetTextColor(0.86, 0.86, 0.90)
    end
    btn:ClearAllPoints()
    btn:SetPoint("TOPLEFT", list, "TOPLEFT", 4, -4 - (idx - 1) * 20)
    btn:SetPoint("TOPRIGHT", list, "TOPRIGHT", -4, -4 - (idx - 1) * 20)
    btn:Show()
end

function Necrosis:CreateModernDropdown(name, parent)
    local dd = CreateFrame("Button", name, parent)
    dd:SetWidth(145)
    dd:SetHeight(24)
    dd:SetBackdrop(BACKDROP_DARK)
    dd:SetBackdropColor(0.11, 0.10, 0.16, 0.95)
    dd:SetBackdropBorderColor(0.32, 0.27, 0.48, 0.95)

    local txt = dd:CreateFontString(name and (name .. "Text") or nil, "OVERLAY", "GameFontHighlightSmall")
    txt:SetPoint("LEFT", dd, "LEFT", 8, 0)
    txt:SetPoint("RIGHT", dd, "RIGHT", -22, 0)
    txt:SetJustifyH("LEFT")
    dd._text = txt

    local arrow = dd:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    arrow:SetPoint("RIGHT", dd, "RIGHT", -7, 0)
    arrow:SetText("▼")
    arrow:SetTextColor(0.68, 0.58, 0.94)

    dd:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.58, 0.51, 0.79, 1.0)
    end)
    dd:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.32, 0.27, 0.48, 0.95)
    end)
    dd:SetScript("OnClick", function(self)
        local list = EnsureDropdownList()
        if list:IsShown() and dropdownTarget == self then
            list:Hide()
            return
        end
        for i = 1, #dropdownListButtons do
            dropdownListButtons[i]:Hide()
        end
        dropdownTarget = self
        dropdownItemCount = 0
        if self._initFunc then
            self._initFunc(self)
        end
        if dropdownItemCount > 0 then
            list:SetWidth(math.max(self:GetWidth(), 145))
            list:SetHeight(dropdownItemCount * 20 + 8)
            list:ClearAllPoints()
            list:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
            list:Show()
        end
    end)
    dd:SetScript("OnHide", function(self)
        if dropdownListFrame and dropdownListFrame:IsShown() and dropdownTarget == self then
            dropdownListFrame:Hide()
        end
    end)

    return dd
end

function Necrosis.DropDown_SetWidth(dd, width)
    if dd and width then
        dd:SetWidth(width + 20)
    end
end

function Necrosis.DropDown_Initialize(dd, initFunc)
    if dd then
        dd._initFunc = initFunc
    end
end

function Necrosis.DropDown_SetSelectedID(dd, id)
    if dd then
        dd._selectedID = id
    end
end

function Necrosis.DropDown_SetText(dd, text)
    if dd and dd._text then
        dd._text:SetText(text or "")
    end
end

local function StyleWidgetTree(frame)
    local children = { frame:GetChildren() }
    for i = 1, #children do
        local child = children[i]
        local objType = child:GetObjectType()
        if objType == "Slider" and not child._styled then
            child._styled = true
            child:SetBackdrop(BACKDROP_DARK)
            child:SetBackdropColor(0.05, 0.05, 0.07, 0.95)
            child:SetBackdropBorderColor(0.30, 0.25, 0.44, 0.95)
            child:SetHeight(10)
            local thumb = child:GetThumbTexture()
            if thumb then
                thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
                thumb:SetWidth(10)
                thumb:SetHeight(14)
                thumb:SetVertexColor(0.65, 0.56, 0.88, 1.0)
            end
            local valText = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            valText:SetPoint("LEFT", child, "RIGHT", 8, 0)
            valText:SetTextColor(0.76, 0.70, 0.95)
            child._valText = valText
            local function UpdateValText(s)
                local v = math.floor((s:GetValue() or 0) + 0.5)
                if s:GetName() == "NecrosisShardBag" then
                    v = 5 - v
                end
                s._valText:SetText(v)
            end
            UpdateValText(child)
            child:HookScript("OnValueChanged", UpdateValText)
        elseif objType == "Button" and not child._styled then
            local txt = child:GetText()
            if txt == ">>>" or txt == "<<<" then
                child._styled = true
                child:SetBackdrop(BACKDROP_DARK)
                child:SetBackdropColor(0.14, 0.12, 0.20, 0.95)
                child:SetBackdropBorderColor(0.38, 0.32, 0.56, 0.95)
                child:SetNormalTexture("")
                child:SetPushedTexture("")
                child:SetHighlightTexture("")
                child:HookScript("OnEnter", function(b)
                    b:SetBackdropColor(0.24, 0.20, 0.36, 0.98)
                    b:SetBackdropBorderColor(0.58, 0.51, 0.79, 1.0)
                end)
                child:HookScript("OnLeave", function(b)
                    b:SetBackdropColor(0.14, 0.12, 0.20, 0.95)
                    b:SetBackdropBorderColor(0.38, 0.32, 0.56, 0.95)
                end)
            end
        elseif objType == "Frame" then
            StyleWidgetTree(child)
        end
    end
end


------------------------------------------------------------------------------------------------------
-- MODERN CONFIG WINDOW
------------------------------------------------------------------------------------------------------

function Necrosis:OpenConfigPanel()
    if InCombatLockdown() then
        self:Msg(
            (self.ChatMessage and self.ChatMessage.Error and self.ChatMessage.Error.InCombat)
                or "Cannot open settings in combat.",
            "USER"
        )
        return
    end

    if not helpShownOnce and self.ChatMessage and self.ChatMessage.Help and self.ChatMessage.Help[1] then
        helpShownOnce = true
        for i = 1, #self.ChatMessage.Help, 1 do
            self:Msg(self.ChatMessage.Help[i], "USER")
        end
    end

    local frame = _G["NecrosisGeneralFrame"]
    if not frame then
        frame = CreateFrame("Frame", "NecrosisGeneralFrame", UIParent)
        frame:SetFrameStrata("DIALOG")
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)
        frame:EnableMouse(true)
        frame:SetToplevel(true)
        frame:SetWidth(610)
        frame:SetHeight(500)
        frame:SetBackdrop(BACKDROP_DARK)
        frame:SetBackdropColor(0.07, 0.07, 0.09, 0.94)
        frame:SetBackdropBorderColor(0.32, 0.27, 0.48, 1.0)
        tinsert(UISpecialFrames, "NecrosisGeneralFrame")

        frame:ClearAllPoints()
        if NecrosisConfig.FramePosition and NecrosisConfig.FramePosition.NecrosisGeneralFrame then
            local pos = NecrosisConfig.FramePosition["NecrosisGeneralFrame"]
            frame:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
        end

        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnMouseUp", function()
            Necrosis:OnDragStop(NecrosisGeneralFrame)
        end)
        frame:SetScript("OnDragStart", function()
            Necrosis:OnDragStart(NecrosisGeneralFrame)
        end)
        frame:SetScript("OnDragStop", function()
            Necrosis:OnDragStop(NecrosisGeneralFrame)
        end)

        -- Header bar
        local header = CreateFrame("Frame", "NecrosisConfigHeader", frame)
        header:SetHeight(34)
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
        header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        header:SetBackdropColor(0.11, 0.10, 0.15, 1.0)

        local accentLine = header:CreateTexture(nil, "ARTWORK")
        accentLine:SetHeight(1)
        accentLine:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
        accentLine:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
        accentLine:SetTexture(0.58, 0.51, 0.79, 0.85)

        local headerIcon = header:CreateTexture(nil, "ARTWORK")
        headerIcon:SetWidth(20)
        headerIcon:SetHeight(20)
        headerIcon:SetPoint("LEFT", header, "LEFT", 10, 0)
        headerIcon:SetTexture("Interface\\AddOns\\NecrosisPlus\\UI\\Shard")

        local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleText:SetPoint("LEFT", headerIcon, "RIGHT", 8, 0)
        titleText:SetTextColor(0.86, 0.82, 0.98)
        titleText:SetText(self.Data.Label or "Necrosis Plus")

        -- Active section title on the right side of header
        local pageText = header:CreateFontString("NecrosisGeneralPageText", "OVERLAY", "GameFontNormalSmall")
        pageText:SetPoint("RIGHT", header, "RIGHT", -38, 0)
        pageText:SetJustifyH("RIGHT")
        pageText:SetWidth(260)
        pageText:SetTextColor(0.68, 0.65, 0.78)

        -- Modern flat close button
        local closeBtn = CreateFrame("Button", "NecrosisGeneralCloseButton", header)
        closeBtn:SetWidth(24)
        closeBtn:SetHeight(24)
        closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)
        closeBtn:SetBackdrop(BACKDROP_DARK)
        closeBtn:SetBackdropColor(0.16, 0.14, 0.22, 0.9)
        closeBtn:SetBackdropBorderColor(0.35, 0.30, 0.48, 0.8)

        local closeLabel = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        closeLabel:SetPoint("CENTER", 0, 1)
        closeLabel:SetText("×")
        closeLabel:SetTextColor(0.85, 0.85, 0.9)

        closeBtn:SetScript("OnEnter", function(btn)
            btn:SetBackdropColor(0.65, 0.18, 0.22, 0.95)
            btn:SetBackdropBorderColor(0.85, 0.3, 0.35, 1)
            closeLabel:SetTextColor(1, 1, 1)
        end)
        closeBtn:SetScript("OnLeave", function(btn)
            btn:SetBackdropColor(0.16, 0.14, 0.22, 0.9)
            btn:SetBackdropBorderColor(0.35, 0.30, 0.48, 0.8)
            closeLabel:SetTextColor(0.85, 0.85, 0.9)
        end)
        closeBtn:SetScript("OnClick", function()
            frame:Hide()
        end)

        -- Left sidebar navigation
        local sidebar = CreateFrame("Frame", "NecrosisConfigSidebar", frame)
        sidebar:SetWidth(175)
        sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
        sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 22)
        sidebar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        sidebar:SetBackdropColor(0.05, 0.05, 0.07, 0.98)

        local sideDivider = sidebar:CreateTexture(nil, "ARTWORK")
        sideDivider:SetWidth(1)
        sideDivider:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, 0)
        sideDivider:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", 0, 0)
        sideDivider:SetTexture(0.24, 0.21, 0.34, 0.9)

        -- Right content container
        local content = CreateFrame("Frame", "NecrosisConfigContent", frame)
        content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, -4)
        content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 24)

        -- Footer hint bar
        local footer = CreateFrame("Frame", "NecrosisConfigFooter", frame)
        footer:SetHeight(22)
        footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
        footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        footer:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        footer:SetBackdropColor(0.09, 0.09, 0.12, 1.0)

        local footerText = footer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        footerText:SetPoint("LEFT", footer, "LEFT", 10, 0)
        footerText:SetText("ESC — закрыть  •  Перетаскивание за окно")

        local creditText = footer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        creditText:SetPoint("RIGHT", footer, "RIGHT", -10, 0)
        creditText:SetText("Necrosis Plus 3.3.5a")

        -- Sidebar tabs (preserving NecrosisGeneralTab1..6 global names)
        for i = 1, 6 do
            local tab = CreateFrame("CheckButton", "NecrosisGeneralTab" .. i, sidebar)
            tab:SetHeight(36)
            tab:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, -10 - (i - 1) * 40)
            tab:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -7, -10 - (i - 1) * 40)
            tab:SetBackdrop(BACKDROP_DARK)
            tab:SetBackdropColor(0.09, 0.09, 0.12, 0.6)
            tab:SetBackdropBorderColor(0.18, 0.16, 0.26, 0.5)

            local activeBar = tab:CreateTexture(nil, "OVERLAY")
            activeBar:SetWidth(3)
            activeBar:SetPoint("TOPLEFT", tab, "TOPLEFT", 0, 0)
            activeBar:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
            activeBar:SetTexture(0.58, 0.51, 0.79, 1.0)
            activeBar:Hide()
            tab._activeBar = activeBar

            local icon = tab:CreateTexture(nil, "ARTWORK")
            icon:SetWidth(20)
            icon:SetHeight(20)
            icon:SetPoint("LEFT", tab, "LEFT", 8, 0)
            icon:SetTexture(TAB_ICONS[i])
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            label:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            label:SetPoint("RIGHT", tab, "RIGHT", -6, 0)
            label:SetJustifyH("LEFT")
            label:SetText((self.Config and self.Config.Panel and self.Config.Panel[i]) or ("Tab " .. i))
            label:SetTextColor(0.80, 0.80, 0.86)
            tab._label = label

            tab:SetScript("OnEnter", function(btn)
                if activePanelID ~= i then
                    btn:SetBackdropColor(0.15, 0.14, 0.22, 0.9)
                    btn._label:SetTextColor(1, 1, 1)
                end
                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                GameTooltip:SetText((self.Config and self.Config.Panel and self.Config.Panel[i]) or "")
            end)
            tab:SetScript("OnLeave", function(btn)
                if activePanelID ~= i then
                    btn:SetBackdropColor(0.09, 0.09, 0.12, 0.6)
                    btn._label:SetTextColor(0.80, 0.80, 0.86)
                end
                GameTooltip:Hide()
            end)
            tab:SetScript("OnClick", function()
                Necrosis:SetPanel(i)
            end)
        end

        frame:Show()
        self:SetPanel(1)
    else
        if frame:IsVisible() then
            frame:Hide()
        else
            frame:Show()
            self:SetPanel(activePanelID)
        end
    end
end

------------------------------------------------------------------------------------------------------
-- PANEL SWITCHING
------------------------------------------------------------------------------------------------------

function Necrosis:SetPanel(PanelID)
    activePanelID = PanelID
    for index = 1, 6, 1 do
        local tab = _G["NecrosisGeneralTab" .. index]
        if tab then
            if index == PanelID then
                tab:SetChecked(1)
                tab:SetBackdropColor(0.20, 0.17, 0.30, 0.95)
                tab:SetBackdropBorderColor(0.58, 0.51, 0.79, 0.9)
                if tab._activeBar then
                    tab._activeBar:Show()
                end
                if tab._label then
                    tab._label:SetTextColor(1, 0.96, 1)
                end
            else
                tab:SetChecked(nil)
                tab:SetBackdropColor(0.09, 0.09, 0.12, 0.6)
                tab:SetBackdropBorderColor(0.18, 0.16, 0.26, 0.5)
                if tab._activeBar then
                    tab._activeBar:Hide()
                end
                if tab._label then
                    tab._label:SetTextColor(0.80, 0.80, 0.86)
                end
            end
        end
    end
    if NecrosisGeneralPageText and self.Config and self.Config.Panel then
        NecrosisGeneralPageText:SetText(self.Config.Panel[PanelID] or "")
    end

    for i = 1, #PANEL_FRAME_NAMES do
        local p = _G[PANEL_FRAME_NAMES[i]]
        if p and i ~= PanelID then
            p:Hide()
        end
    end

    if PanelID == 1 then
        self:SetMessagesConfig()
    elseif PanelID == 2 then
        self:SetSphereConfig()
    elseif PanelID == 3 then
        self:SetButtonsConfig()
    elseif PanelID == 4 then
        self:SetMenusConfig()
    elseif PanelID == 5 then
        self:SetTimersConfig()
    elseif PanelID == 6 then
        self:SetMiscConfig()
    end

    local activeFrame = _G[PANEL_FRAME_NAMES[PanelID]]
    if activeFrame then
        if not activeFrame._modernStyled then
            activeFrame._modernStyled = true
            StyleWidgetTree(activeFrame)
        end
        if _G["NecrosisConfigContent"] then
            activeFrame:ClearAllPoints()
            activeFrame:SetPoint("BOTTOMLEFT", NecrosisConfigContent, "BOTTOMLEFT", 18, -10)
        end
    end
end
