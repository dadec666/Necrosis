--[[
    Necrosis - Midnight (12.0+) Compatibility Layer
    Provides backward-compatible wrappers for deprecated APIs
--]]

-- ============================================================================
-- GetSpellInfo Compatibility Wrapper (12.0+)
-- ============================================================================
if not _G.GetSpellInfo then
    function _G.GetSpellInfo(spellID)
        if not spellID then return nil end
        spellID = tonumber(spellID)
        if not spellID or spellID <= 0 then return nil end

        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if not spellInfo then return nil end

        -- Return in old format: name, rank, icon, castTime, minRange, maxRange, spellId
        return spellInfo.name, nil, spellInfo.iconID, nil, nil, nil, spellID
    end
end

-- ============================================================================
-- GetSpellCooldown Compatibility Wrapper (12.0+)
-- Same four values as the historical API (startTime, duration, isEnabled, modRate). When the cooldown cannot be read
-- (secret value or empty API answer) the first three stay 0, 0, 1 so existing callers keep working; use
-- NecrosisCompat.IsSpellCooldownUnknown(spellID) to tell "ready" from "unknown" (issue #46).
-- Only installed when the client has no native GetSpellCooldown.
-- ============================================================================
NecrosisCompat = NecrosisCompat or {}

local function ReadSpellCooldown(spellID)
    spellID = tonumber(spellID)
    if not spellID or spellID <= 0 then return nil end
    local info = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(spellID)
    if not info then return nil end
    if issecretvalue and (issecretvalue(info.startTime) or issecretvalue(info.duration) or issecretvalue(info.isEnabled)) then
        return nil
    end
    return info
end

-- true when the cooldown of this spell cannot be read right now
function NecrosisCompat.IsSpellCooldownUnknown(spellID)
    return ReadSpellCooldown(spellID) == nil
end

if not _G.GetSpellCooldown then
    function _G.GetSpellCooldown(spellID)
        local info = ReadSpellCooldown(spellID)
        if not info then return 0, 0, 1 end

        -- Return in old format: startTime, duration, isEnabled, modRate
        return info.startTime or 0, info.duration or 0, info.isEnabled and 1 or 0, info.modRate
    end
end

-- ============================================================================
-- GetItemInfo Compatibility Wrapper (12.0+)
-- Only installed when the client has no global GetItemInfo. C_Item.GetItemInfo takes an item ID, name or link
-- and (on Forever, issue #46) returns separate values, not a table: pass them through unchanged. A table return
-- (some builds) is converted to the legacy order. Never replaces a native GetItemInfo.
-- ============================================================================
if not _G.GetItemInfo then
    function _G.GetItemInfo(item)
        if not item or not (C_Item and C_Item.GetItemInfo) then return nil end

        local first = C_Item.GetItemInfo(item)
        if type(first) == "table" then
            return first.itemName, first.itemLink, first.quality, first.itemLevel,
                   first.requiredLevel, first.itemType, first.itemSubType,
                   first.stackCount, first.equipLoc, first.icon, first.sellPrice,
                   first.classID, first.subClassID
        end
        return C_Item.GetItemInfo(item)
    end
end

-- ============================================================================
-- IsAddOnLoaded Compatibility Wrapper (12.0+)
-- ============================================================================
if not _G.IsAddOnLoadedOriginal then
    _G.IsAddOnLoadedOriginal = _G.IsAddOnLoaded
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        function _G.IsAddOnLoaded(addOnName)
            return C_AddOns.IsAddOnLoaded(addOnName)
        end
    end
end

-- ============================================================================
-- GetAddOnMetadata Compatibility Wrapper (12.0+)
-- ============================================================================
if not _G.GetAddOnMetadataOriginal then
    _G.GetAddOnMetadataOriginal = _G.GetAddOnMetadata
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        function _G.GetAddOnMetadata(addOnName, field)
            return C_AddOns.GetAddOnMetadata(addOnName, field)
        end
    end
end

-- ============================================================================
-- UnitAura Compatibility Wrapper (12.0+)
-- ============================================================================
if not _G.UnitAuraOriginal then
    _G.UnitAuraOriginal = _G.UnitAura or function() return nil end
    function _G.UnitAura(unit, index, filter)
        if C_UnitAuras and C_UnitAuras.GetAuraDataByUnit then
            local auras = C_UnitAuras.GetAuraDataByUnit(unit, filter)
            if not auras or not auras[index] then return nil end

            local aura = auras[index]
            -- Return in old format: name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyCustom, isBossAura, isCastByPlayer, nameplateShowAll, timeMod, ...
            return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration,
                   aura.expirationTime, aura.sourceUnit, aura.canStealOrPurge, aura.nameplateShowPersonal,
                   aura.spellId, aura.canApplyCustom, aura.isBossAura, aura.isCastByPlayer, aura.nameplateShowAll, aura.timeMod
        else
            return _G.UnitAuraOriginal(unit, index, filter)
        end
    end
end

-- ============================================================================
-- UnitBuff Compatibility Wrapper (12.0+)
-- ============================================================================
if not _G.UnitBuff then
    function _G.UnitBuff(unit, index)
        if C_UnitAuras and C_UnitAuras.GetAuraDataByUnit then
            local auras = C_UnitAuras.GetAuraDataByUnit(unit, "HELPFUL")
            if not auras or not auras[index] then return nil end

            local aura = auras[index]
            return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration,
                   aura.expirationTime, aura.sourceUnit, aura.canStealOrPurge, aura.nameplateShowPersonal,
                   aura.spellId, aura.canApplyCustom, aura.isBossAura, aura.isCastByPlayer, aura.nameplateShowAll, aura.timeMod
        end
        return nil
    end
end

-- ============================================================================
-- UnitDebuff Compatibility Wrapper (12.0+)
-- ============================================================================
if not _G.UnitDebuff then
    function _G.UnitDebuff(unit, index)
        if C_UnitAuras and C_UnitAuras.GetAuraDataByUnit then
            local auras = C_UnitAuras.GetAuraDataByUnit(unit, "HARMFUL")
            if not auras or not auras[index] then return nil end

            local aura = auras[index]
            return aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration,
                   aura.expirationTime, aura.sourceUnit, aura.canStealOrPurge, aura.nameplateShowPersonal,
                   aura.spellId, aura.canApplyCustom, aura.isBossAura, aura.isCastByPlayer, aura.nameplateShowAll, aura.timeMod
        end
        return nil
    end
end

-- ============================================================================
-- GetSpellPowerCost Compatibility Wrapper (12.0+)
-- ============================================================================
if not _G.GetSpellPowerCost then
    function _G.GetSpellPowerCost(spellID)
        if not spellID then return nil end
        spellID = tonumber(spellID)
        if not spellID or spellID <= 0 then return nil end

        -- In WOW 12.0.1, use C_Spell.GetSpellInfo to get power cost
        if C_Spell and C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(spellID)
            if spellInfo and spellInfo.powerCost then
                -- Return as a table similar to old format
                return { { powerType = "MANA", cost = spellInfo.powerCost } }
            end
        end
        return nil
    end
end

-- ============================================================================
-- GetSpellSubtext Compatibility Wrapper (12.0+)
-- Spell ranks were removed in WOW 12.0.1
-- ============================================================================
if not _G.GetSpellSubtext then
    function _G.GetSpellSubtext(spellID)
        -- Spell ranks no longer exist in WOW 12.0.1
        return nil
    end
end

-- ============================================================================
-- Spell Book API Compatibility Wrappers (12.0+)
-- ============================================================================
if not _G.MAX_SKILLLINE_TABS then
    _G.MAX_SKILLLINE_TABS = 1  -- WOW 12.0.1 uses different spell system
end

if not _G.BOOKTYPE_SPELL then
    _G.BOOKTYPE_SPELL = 1
end

if not _G.GetSpellTabInfo then
    function _G.GetSpellTabInfo(tabIndex)
        -- Return empty for spell book tabs (not used in 12.0.1)
        return nil, nil, nil, nil
    end
end

if not _G.GetSpellBookItemName then
    function _G.GetSpellBookItemName(spellBookSlot, bookType)
        -- Return nil for spell book queries (not used in 12.0.1)
        return nil, nil, nil
    end
end

-- ============================================================================
-- C_Spell.GetSpellName (returns just the name, not the old GetSpellInfo format)
-- ============================================================================
if C_Spell and not C_Spell.GetSpellNameOriginal then
    C_Spell.GetSpellNameOriginal = C_Spell.GetSpellName
    -- The new API already exists, just ensure it works
end

-- ============================================================================
-- C_PetBattles.IsInBattle Compatibility Wrapper (12.0+)
-- ============================================================================
-- In Midnight 12.0.1, pet battles system was removed or changed
-- This provides a safe wrapper that returns false when the API is unavailable
if not C_PetBattles then
    C_PetBattles = {}
end

if not C_PetBattles.IsInBattle then
    function C_PetBattles.IsInBattle()
        -- Pet battles don't exist or are disabled in this version
        return false
    end
end

-- Legacy function name compatibility
if not _G.C_PetBattles_IsInBattle then
    function _G.C_PetBattles_IsInBattle()
        -- Wrapper for old-style function call syntax
        return C_PetBattles.IsInBattle()
    end
end

-- ============================================================================
-- C_Club API Compatibility Wrappers (12.0+)
-- ============================================================================
-- Discord communities/clubs may not exist or have changed in Midnight
if not C_Club then
    C_Club = {}
end

if not C_Club.GetStreamInfo then
    function C_Club.GetStreamInfo(clubId, streamId)
        -- Communities not available or streamInfo structure changed
        return nil
    end
end

if not C_Club.GetClubInfo then
    function C_Club.GetClubInfo(clubId)
        -- Communities not available
        return nil
    end
end

-- ============================================================================
-- C_Calendar API Compatibility Wrappers (12.0+)
-- ============================================================================
if not C_Calendar then
    C_Calendar = {}
end

if not C_Calendar.GetNumDayEvents then
    function C_Calendar.GetNumDayEvents(monthOffset, day)
        -- Calendar API changed or not available
        return 0
    end
end

if not C_Calendar.GetDayEvent then
    function C_Calendar.GetDayEvent(monthOffset, day, eventIndex)
        -- Calendar API changed or not available
        return nil
    end
end

-- ============================================================================
-- LFGListInviteDialog_Show Compatibility Wrapper (160001+)
-- ============================================================================
if not _G.LFGListInviteDialog_Show then
    function _G.LFGListInviteDialog_Show(partyLeaderName)
        -- LFG system changed or not available in Forever
        return nil
    end
end

-- ============================================================================
-- ActionButton_Update Compatibility Wrapper (160001+)
-- ============================================================================
if not _G.ActionButton_Update then
    function _G.ActionButton_Update(button)
        -- Action button system changed in Forever
        return nil
    end
end

-- ============================================================================
-- LEARNED_SPELL_IN_TAB Event Compatibility (160001+)
-- ============================================================================
-- Register a handler that converts SPELLS_CHANGED to legacy LEARNED_SPELL_IN_TAB
if not _G.NECROSIS_SPELL_EVENT_HOOKED then
    _G.NECROSIS_SPELL_EVENT_HOOKED = true

    -- Deprecated event - now use SPELLS_CHANGED
    -- We'll intercept SPELLS_CHANGED if needed
end

-- ============================================================================
-- GetItemCount Compatibility Wrapper (160001+)
-- Uses C_Item.GetItemCount if available
-- ============================================================================
if not _G.GetItemCount then
    function _G.GetItemCount(itemID, includeBank, includeEquipped)
        -- Forever 160001+ uses C_Item.GetItemCount
        if C_Item and C_Item.GetItemCount then
            return C_Item.GetItemCount(itemID) or 0
        end
        -- Fallback: return 0 if API unavailable
        return 0
    end
end

-- ============================================================================
-- GetItemInfoInstant Compatibility Wrapper (160001+)
-- Moved to C_Item.GetItemInfoInstant, same return signature
-- ============================================================================
if not _G.GetItemInfoInstant then
    function _G.GetItemInfoInstant(item)
        if C_Item and C_Item.GetItemInfoInstant then
            return C_Item.GetItemInfoInstant(item)
        end
        return nil
    end
end
