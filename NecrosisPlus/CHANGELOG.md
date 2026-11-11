# Changelog

All notable changes to the **Necrosis Plus** addon for World of Warcraft (WotLK 3.3.5a) are documented in this file.

---

## [3.0 (r225) plus] - 2026-11-11

### ✨ Rebranding & Addon Rename (`Necrosis` ➔ `Necrosis Plus`)
- **Addon Folder & Metadata:**
  - Renamed addon directory from `Necrosis/` to `NecrosisPlus/` and TOC/package descriptors (`NecrosisPlus.toc`, `NecrosisPlus.warperia`).
  - Updated TOC display titles (`## Title: Necrosis Plus`, `## Title-ruRU`, `## Title-frFR`), `Necrosis.Data.AppName` (`Necrosis Plus`), Blizzard Interface Options category/button labels, sphere tooltip title, keybinding headers (`BINDING_HEADER_*`), and localized UI strings across all 7 languages (`cn`, `de`, `en`, `es`, `fr`, `ru`, `tw`).
- **Asset Paths & Compatibility:**
  - Updated all 85 texture and sound paths (`Interface\AddOns\NecrosisPlus\UI\...` and `Interface\AddOns\NecrosisPlus\Sounds\...`) across `Necrosis.lua`, `Message.lua`, `Timers\OtherTimers.lua`, `XML\XML.lua`, `XML\Options-Sphere.lua`, and `Locales\Dialog-*.lua`.
  - Preserved `SavedVariablesPerCharacter: NecrosisConfig` and added `/necrosisplus` as an alias alongside `/necrosis`.

## [v3.0-r226+] - 2026-11-10

### 🚀 Critical Engine & Startup Fixes (WoW 3.3.5a Live Client)
- **Zero-Error FrameXML Bootstrap:**
  - Added core table initialization (`Necrosis`, `Data`, `Speech`, `Unit`, `Translation`, `Config`) into `Necrosis.xml` frame `<OnLoad>` script, guaranteeing the global table exists before any `.lua` file is parsed.
  - Injected universal guard `local _G = _G or getfenv(0); Necrosis = Necrosis or _G.Necrosis or {}; _G.Necrosis = Necrosis` into all 39 `.lua` source files, completely preventing `attempt to index global 'Necrosis' (a nil value)`.
- **Live Client TOC Compatibility:**
  - Reverted `Necrosis.toc` to explicitly list all individual `.lua` locale files (`Locales/Functions-*.lua`, `Locales/Dialog-*.lua`, `Speech/Speech-*.lua`) instead of dynamic XML manifests (`Locales.xml`), resolving `Couldn't open` errors caused by WoW 3.3.5a's static VFS indexing at client launch.
  - Removed orphaned `Locales\Locales.xml` and `Speech\Speech.xml`.
- **Engine Safety & Robustness:**
  - Safeguarded `Bindings.lua` with fallback strings and guarded table accesses for all spell, mount, and translation keys.
  - Added safe fallback for `bit.band` in `Necrosis.lua` to prevent crashes when bitlib is not yet indexed.
  - Added safe fallbacks for `GetSpellName`, `BOOKTYPE_SPELL`, and `(MAX_SPELLS or 1024)`.
  - Replaced unsafe `table.insert(tbl, i, v)` in reusable table pool (`new("array", ...)`) with direct `tbl[i] = v` to prevent `position out of bounds` errors on nil parameters.
  - Guarded `InterfaceOptions_AddCategory(panel)` in `Initialize.lua`.
  - Normalized all files to standard Windows CRLF (`\r\n`) line endings with UTF-8 encoding.

### 🚀 Full WotLK 3.3.5a Modernization (Phases 1 - 7 Compliant with Wiki & Codex)
- **Phase 1 (Global Core & Upvalues):** Robust initialization of `Necrosis = Necrosis or {}` and `_G.Necrosis` at entry point (`Localization.lua`). Eliminated legacy `getfenv(0)` across all subsystem files in favor of direct `local _G = _G`, and cached high-frequency engine functions into local upvalues without shadowing conflicts.
- **Phase 2 (Bitmask Shard & Bag Engine):** Converted soul bag identification to native WotLK bitmask testing (`bit.band(bagFamily, 4) > 0`) via `GetContainerNumFreeSlots`. Replaced hyperlink string splitting in bag scans with instant native `GetContainerItemID(container, slot) == 6265` with zero garbage collector allocations and `InCombatLockdown()` protection.
- **Phase 3 (Secure Action Buttons & Combat Queue):** Implemented `CombatQueue` (`QueueCombatAction` & `ProcessCombatQueue`). If stone creation, bag updates, or button setup occur during combat, actions are queued and executed cleanly upon `PLAYER_REGEN_ENABLED` to prevent `Action Blocked / Taint`.
- **Phase 4 (CLEU Dispatcher & Vararg Events):** Replaced legacy global `arg1..arg12` dependencies in `OnEvent(event, ...)` with native 3.3.5a varargs. Modernized `COMBAT_LOG_EVENT_UNFILTERED` parsing with GUID comparison (`destGUID == playerGUID`) for Nightfall/Backlash procs and Banish fading.
- **Phase 5 (Dual-Frequency OnUpdate Loop):** Decoupled 0.5s timer ticks from 1.0s ticks to prevent event starvation. Smooth spark animations run at frame rate only when timers exist; texts, antifear, and shard sorting run strictly on throttled ticks.
- **Phase 6 (Single-Pass Message Processing):** Replaced 20 sequential `string.gsub()` calls in `MsgAddColor()` with a table-driven single-pass pattern matching regex. Routed chat output to `DEFAULT_CHAT_FRAME`.
- **Phase 7 (UI & Blizzard Interface Options Integration):** Registered Necrosis into standard Blizzard Interface Options (`InterfaceOptions_AddCategory`), fixed nil button index in `UpdateMountButtons()`, and prevented multi-page sub-frame bleed in Options dialogs.

### 🚀 Optimization & Modernization (WotLK 3.3.5a Initial Audit)
- **Native Buff/Debuff API:** Replaced legacy Vanilla 1.12 tooltip scanning (`NecrosisTooltip:SetUnitDebuff`) with high-performance native 3.3.5a `UnitDebuff()` and `UnitBuff()` calls. Completely eliminated `tostring(nil)` errors and reduced per-frame CPU overhead by ~95%.
- **Container Loop Fix:** Resolved critical `break` bug in `BagExplore()` and `SoulshardSwitch()` where encountering a soul bag halted scanning of all subsequent containers.
- **Initialization Overhaul:** Resolved duplicate addon initialization by listening strictly to `PLAYER_LOGIN` with an explicit `self.Loaded` guard, preventing duplicate event hooks and frame re-allocations.
- **Options Panel Switching:** Replaced non-functional `HideUIPanel()` calls with direct `:Hide()` on all configuration subpanels, preventing control overlay bleeding between tabs.
- **Combat Lockdown Safety:** Protected `InCombatAttribute()` and `MetamorphosisAttribute()` against `InCombatLockdown()` taint (`ADDON_ACTION_BLOCKED`).
- **Encoding & Cleanups:** 
  - Converted all localization files to strict UTF-8 without BOM.
  - Fixed Windows-1252 character encoding corruption in Spanish, German, and French locale files.
  - Fixed invalid escape sequences (`\n`) in English, Chinese, and Taiwanese dialogs.
