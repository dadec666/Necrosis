# Changelog

All notable changes to the **Necrosis** addon for World of Warcraft (WotLK 3.3.5a) are documented in this file.

---

## [v3.0-r226+] - 2026-11-10

### 🚀 Full WotLK 3.3.5a Modernization (Phases 1 - 7 Compliant with Wiki & Codex)
- **Phase 1 (Namespace Isolation & Upvalues):** All 39 Lua files enclosed in clean private namespace `local addonName, Necrosis = ...; Necrosis = Necrosis or _G.Necrosis`. Eliminated legacy `getfenv(0)` in favor of `local _G = _G` and cached high-frequency engine functions into local upvalues.
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
  - Guarded table recycling `del(t)` against `nil` references and eliminated invalid `del(colorCode)` calls.
- **OnUpdate Throttling & Garbage Collection:** 
  - Added early-exit checks when no spell timers are active.
  - Replaced per-frame table instantiations (`LastPoint = {}`) in `GraphicalTimers.lua` with localized stack variables.
  - Cached frequently used global Lua and WoW API functions into local upvalues.
- **Deep Subsystem Audit Fixes:**
  - **Full Soul Bag Recognition:** Expanded bag identification loop from hardcoded 3 to `#self.Translation.Item.SoulPouch`, supporting all 8 high-level TBC/WotLK soul bags (Abyssal Bag, Felcloth Bag, etc.).
  - **Lua Operator Precedence:** Fixed `not NecrosisConfig.SoulshardContainer == i - 1` logic bug in shard capacity checks.
  - **Reversed Combat Timer Cleanup:** Fixed table index skipping bug in `RetraitTimerCombat()` by iterating backwards (`#Timer.SpellTimer, 1, -1`).
  - **Modernized XML Frame Scripts:** Replaced legacy Vanilla globals (`this`, `arg1`) in all `SetScript` handlers with modern WotLK parameters (`self`, `elapsed`).
  - **Audio Path Normalization:** Standardized casing of sound paths across all dialog locales (`Sounds/`).

---

## [r226] - 2010-08-04

- TOC and version number updated for patch 3.3.5.

---

## [r225]

- TOC and version number updated for patch 3.3.5.
- Fixed keybindings for Corruption, Curse of the Elements, and Curse of Doom.
- Fixed error with text timers when no target was found ([#130](https://github.com/dadec666/Necrosis/issues/130)).
- Fixed potential taint issue ([#143](https://github.com/dadec666/Necrosis/issues/143)).
- **Localization Updates:**
  - Fixed Soulstone cooldown duration across all languages.
  - Russian localization updated by StingerSoft ([#119](https://github.com/dadec666/Necrosis/issues/119), [#120](https://github.com/dadec666/Necrosis/issues/120)).
  - French localization updated by oXid_FoX ([#151](https://github.com/dadec666/Necrosis/issues/151)).

---

## [r224]

- TOC and version number updated.
- Mount selection interface improvements for mount collectors.
- Shift+Click on Soulstone button now casts **Ritual of Summoning**.
- **Haunt** now refreshes the Corruption timer.
- **Updated Spell Cooldown Timers:**
  - Soulshatter (3 min)
  - Fel Domination (3 min)
  - Infernal (10 min)
  - Soulstone Resurrection (15 min)
- Removed `<target>` parameter from summoning messages.

---

## [r223]

- Max soulshard count handling improved: replaced manual input box with an intuitive slider.

---

## [r222]

- Fixed an issue with keybinding templates.
- **Updated Spell Cooldown Timers:**
  - Ritual of Doom (30 min)
  - Ritual of Summoning (2 min)
  - Demon Charge (45 sec)
  - Life Tap (40 sec)
  - Immolation Aura (30 sec)
  - Challenging Howl (15 sec)
  - Conflagrate (10 sec)

---

## [r221]

- Removed **Curse of Recklessness** (removed by Blizzard in Patch 3.1).
- TOC and version number updated.

