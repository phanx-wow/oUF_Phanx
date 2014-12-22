### Version 6.0.3.73

* Fixed an error with monk chi and the Ascension talent
* Fixed an error when disabling the eclipse bar
* Removed custom soul shards element since oUF now supports them natively

### Version 6.0.3.72

* Fixed monk chi display
* Moved combo points to player frame

### Version 6.0.3.71

* Fixed secondary power orbs (chi, holy power, shadow orbs, wild mushrooms)
* Fixed dropdowns in the aura config panel not saving changes
* Minor changes to the aura filter config system

### Version 6.0.3.70

* Fixed an issue preventing the options panel from loading

### Version 6.0.3.69

* Changed aura filtering to use bitfields instead of fixed filters -- users should not notice any difference, but this will allow for greater filtering flexibility in the future.
* The focus frame castbar will no longer be displayed when your target frame is already displaying the same unit.
* Threat greater than 300% will no longer be displayed.
* Fixed coloring on "tap to all" mobs
* Fixed unwanted red coloring on the castbar safe zone texture
* Fixed heals and absorbs sometimes being displayed on dead units (workaround for Blizzard API bug)
* Updated Portuguese translations
* Version numbers now indicate releases rather than SVN revisions

### Version 5.4.8.469 (8 Sep 2014)

* Added absorb overlay on health bar
* Reduced size of threat text on target frame

### Version 5.4.8.462 (18 Aug 2014)

* Fixed demonic fury error on login
* Fixed checkboxes in the unit options panel

### Version 5.4.8.456 (8 Aug 2014)

* Fixed castbar appearance

### Version 5.4.8.452 (4 Aug 2014)

* Fixed possible eclipse bar error at login
* Fixed possible border overlapping on secondary power bars
* Added threat percent text on target frame
* Added a font scale option -- no UI yet, use "/run oUFPhanxConfig.fontScale = N" and "/reload", where N is a number from 0.5 to 1.5

### Version 5.4.8.446 (14 Jul 2014)

* Added "/pouf buffs" and "/pouf debuffs" commands to list buffs or debuffs on the target, for finding spell IDs
* Added an option to toggle the text shadow
* Added combopoint-like display for mage Arcane Charges
* Improvements and fixes for demonic fury, eclipse, stagger, rune, and totem bars

### Version 5.4.2.418 (7 Feb 2014)

* Added a stagger bar for brewmaster monks (untested)
* Fixed initial coloring of shaman totem bars
* Fixed display of "Ghost" on health bars
* Options are now load-on-demand

### Version 5.4.2.410 (22 Dec 2013)

* Added in-game unit options
* Combat feedback text is now a per-unit option
* Changed combat feedback text colors to more closely match those used in the default UI
* Changed combat feedback text initialization to hopefully resolve the bug reported by Dexter74 on WoWInterface

### Version 5.4.2.403 (17 Dec 2013)

* Added combat feedback text (optional, and disabled by default)
* Added the ability to see and mouse over all buffs while holding Shift out of combat
* Added a very minimal PvP status icon on the target frame (colored dot, top left corner)
* Added more spell IDs for Corruption (ಠ_ಠ Blizzard)
* Added German translations
* Added more Russian translations from Felixod on Curse (still incomplete)
* Removed support for the outdated oUF_CombatFeedback plugin

### Version 5.4.1.388 (25 Nov 2013)

* Updated for WoW 5.4
* Added Beacon of Light by default for paladins
* Fixed a random error that might randomly have occurred

### Version 5.3.0.383 (21 Jul 2013)

* Fixed aura switching on role change
* Fixed health updating on boss frames
* Fixed several issues with the config panels
* Added several auras for priests
* Added all MoP enchant procs to the aura blacklist since Blizzard doesn't flag them correctly
* Added partial Russian translation from Felixod

### Version 5.3.0.375 (29 May 2013)

* Updated for WoW 5.3
* Added Enslave Demon and Rain of Fire (Destruction version) to default aura filters
* Fixed buffs and debuffs not switching positions on the target frame when changing roles
* Fixed an issue causing druid mushrooms to not always appear at login
* Fixed an error that occurs when oUF attempts to update hidden frames

### Version 5.2.0.365 (8 Apr 2013)

* Fixed demonic fury bar

### Version 5.2.0.362 (3 Apr 2013)

* Added a workaround for the Blizzard bug causing boss frames not to update properly
* Fixed runes
* Fixed soul shards (untested)
* Fixed border expansion to properly contain extra elements (druid mana bar, etc) on load
* Updated Spanish localization

### Version 5.2.0.356 (31 Mar 2013)

* Fixed several issues with the custom aura options panel
* Fixed an issue preventing the threat highlight from being displayed
* Fixed an issue causing power bars to turn gray when the options panel is opened
* Added a separate options panel for options that require a UI reload, with several new options
* Added a workaround for a Blizzard bug causing dead units' healthbars to show non-zero values
* Added the Fire and Brimstone upgraded version of Conflagrate for warlocks
* Major organizational changes and cleanup — you should completely delete your old oUF_Phanx folder before installing this update, to avoid having tons of old files laying around

### Version 5.2.0.336 (24 Mar 2013)

* Added in-game options for adding custom aura filters (saved on a per-character basis)
* Updated magic dispel detection for warlocks with a Fel Imp summoned
* Updated some druid auras (thanks Funkydude)
* Moved party frames down to accomodate the new 5th boss frame
* Fixed an error when changing custom class colors
* Updated included oUF

### Version 5.2.0.323 (18 Mar 2013)

* Fixed druid mushrooms (last time, I promise!)
* Slightly adjusted default frame positions

### Version 5.2.0.320 (11 Mar 2013)

* Fixed druid mushrooms (hopefully for real this time)
* Added Incanter's Absorption and Pyroblast! mage buffs

### Version 5.2.0.318 (7 Mar 2013)

* Fixed druid mushrooms
* Fixed warlock power errors when entering vehicles
* Miscellaneous cleanup of old code

### Version 5.2.0.314 (5 Mar 2013)

* Fixed a typo in Weakened Soul for priests

### Version 5.2.0.313 (5 Mar 2013)

* Added basic display for druid mushrooms (mostly untested)
* Added Forbearance for paladins and Weakened Soul for priests
* Fixed border coloring
* Fixed Savage Roar for druids
* Updated some hunter auras (thanks ravagernl)
* Updated bundled oUF core
* Merged all options into a single panel
* Added French localization from Strigx on Curse
* Added parital German localization from Grafrotz on Curse

### Version 5.1.0.296 (7 Feb 2013)

* Fixed an issue with aura filtering
* Fixed an error that occurred when switching between roles (tank/healer/dps)
* Fixed an error that occurred when toggling the "Filter debuff highlight" option
* Updated many spell IDs

### Version 5.1.0.284 (20 Dec 2012)

* Added spell IDs for warlock Fury Ward and warrior Meat Cleaver
* Fixed spell IDs for druid Rejuvenation and warlock Corruption
* Fixed auto-whitelisting of auras cast by the unit's vehicle
* Fixed rune bar width
* Improved visual integration of eclipse bar, druid mana bar, rune bars, and totem bars
* Moved player frame orbs to the bottom to match the position of target frame orbs and avoid overlapping totem and rune bars

#### Version 5.1.0.275 (29 Nov 2012)

* Added Destabilize to the list of improperly flagged boss debuffs to show
* Fixed an error in the DebuffHighlight module

### Version 5.1.0.273 (29 Nov 2012)

* Updated for WoW 5.1
* Updated auras for druids and monks.
* Added Brazilian Portuguese localization.
* Added support for boss debuffs that Blizzard forgot to flag as boss debuffs. Currently only Brew Explosion is included; if you know of any others, please post a comment.
* Changed how frame borders are sized; old settings should upgrade automatically, but you may need to manually adjust the border size setting to your liking.
* Fixed an error relating to threat events firing without proper unit info.
* **The download for this version also includes oUF, since the download page for oUF is very out of date.**

### Version 5.0.5.265 (2 Nov 2012)

* Added runes for death knights
* Added totems for shamans
* Minor update to aura filter list for warlocks
* Removed support for oUF_boring_totembar plugin  
  *Totems are now supported natively by oUF, so there's no need for a plugin.*
* Removed PT Serif font  
  *If you were using it, just keep the file and don’t change the font option dropdown or — better yet — install [SharedMedia](http://www.curse.com/addons/wow/sharedmedia) and follow the “MyMedia” instructions.*

### Version 5.0.5.256 (28 Oct 2012)

* Removed pet battle hiding code, since oUF does this itself now ([get the latest version of oUF from Haste's GitHub repo](https://github.com/haste/oUF/zipball/master))
* Fixed some issues with the castbar safezone and background
* Fixed orb color not updating when [class colors](http://www.wowinterface.com/downloads/info12513-ClassColors.html) are changed
* Updated auras for feral/guardian druids (thanks Shiryu), shadow priests (thanks Fumler), and mistweaver monks

### Version 5.0.5.249 (15 Oct 2012)

* Frames are now hidden during pet battles
* Unfiltered buffs can now be shown out of combat by pressing Shift and mousing over the frame; it's currently not possible to mouse over the icons in this mode, so more improvements will be forthcoming

### Version 5.0.5.245 (25 Sep 2012)

* Make an extra shadow orb to make oUF happy

### Version 5.0.5.244 (25 Sep 2012)

* Added an optional glow to highlight important border states
* Added auras for monks and pandaren
* Updated auras for all classes
* Updated raid debuff auras
* Updated the resurrection element
* Updated the dispel highlight element
* Updated the warlock power element
* Updated group leader and master looter icons
* Updated combo points, chi, holy power, and shadow orbs

### Version 5.0.4.224 (28 Aug 2012)

* Updated for WoW 5.0.4
* Added graphical orb display, and removed text display, for combo points, secondary resources, and Maelstrom Weapon
* Added auras to pet frame (untested)
* Added auras cast by the player's vehicle on friendly targets and hostile player targets
* Fixed mirror timer styling
* Fixed power color option
* Fixed Ghost detection
* Updated Resurrection element to use LibResInfo instead of LibResComm (no longer needs other players in your group to have the same library installed)
* Replaced the Expressway font with PT Sans
* Added zhCN translations from wowuicn on CurseForge

### Version 5.0.3.217-beta (19 Jul 2012)

* Added a burning embers display for destruction warlocks. Needs a little polish.
* Added a demonic fury display for demonology warlocks. Needs a lot of polish.
* Added zhCN localization from wowuicn on CurseForge.

### Version 5.0.3.214-beta (18 Jul 2012)

* Added a chi display for monks.
* Added a shadow orb display for shadow priests.
* Added a soul shard display for affliction warlocks.
* <i>Burning Embers and Demonic Fury are partly implemented, but not yet fully functional.</i>
* Added tanking/healing checks for monks.
* Cast bars now show the time remaining, rather than the time elapsed.

### Version 5.0.1.207-beta (13 Jul 2012)

* **This beta version works only on MoP beta servers, and requires [the latest beta version of oUF from GitHub](https://github.com/haste/oUF).**
* Preliminary update for MoP API changes in WoW and oUF.
* Fixed the styling of mirror timer bars (breath, etc.)
* Fixed the power color option
* Replaced the Expressway font with PT Sans
* Auras cast by the player's vehicle should now be correctly shown.
* Combo points are now displayed graphically, rather than with text.
* Maelstrom Weapon stacks for enhancement shamans are now displayed graphically, rather than with text.
* **Chi, holy power, shadow orbs, burning embers, demonic fury, and soul shards are currently NOT displayed in any form.**
* **Plugin support has not been tested.** Please report any issues you encounter with plugins that are listed as supported in the addon description.
* **Eclipse bar has not been tested.** Please report any issues you encounter with it.

### Version 4.3.0.191 (23 Dec 2011)

* Fixed another issue affecting aura filtering

### Version 4.3.0.189 (15 Dec 2011)

* Fixed an issue affecting aura filtering

### Version 4.3.0.188 (12 Dec 2011)

* Allow debuffs cast by the player's vehicle to appear on the target frame (untested)

### Version 4.3.0.186 (11 Dec 2011)

* Updated for WoW 4.3
* Fixed threat highlight element
* Added Envenom self-buff for rogues
* Added support for oUF druid mana bar element
* Removed support for oUF_DruidMana plugin

### Version 4.2.0.180 (1 Jul 2011)

* Updated for WoW 4.2

### Version 4.1.0.179 (28 Apr 2011)

* Turned off some more debugging messages (hopefully that’s all of them!)

### Version 4.1.0.178 (28 Apr 2011)

* Removed a lingering reference to pet happiness

### Version 4.1.0.177 (28 Apr 2011)

* Removed support for pet happiness since that was removed in WoW 4.1
* Turned off some stray debugging messages

### Version 4.1.0.176 (28 Apr 2011)

* Fixed the Dispel and Resurrection elements
* Fixed the statusbar and font dropdowns to correctly preview the currently selected texture or font file on the dropdown value text
* Fixed the initializing for LibSharedMedia-3.0 support
* Added code to hide focus-related entries in unit frame right-click menus
* Added the Serendipity buff for priests (WoWI feature ticket #7324)
* Added separate options for health bar background and power bar background
* Added the PT Serif Font
* Removed the Andika Basic Custom and Droid Serif fonts
* Updated Spanish translations

### Version 4.0.6.157 (22 Feb 2011)

* Greatly improved the moonkin eclipse bar
* Added options for disabling the eclipse bar, or just the eclipse icons (requires a reload to take effect)
* Added support for the default UI’s beginner tooltips on the player and target frame
* Updated Spanish localization

### Version 4.0.6.151 (20 Feb 2011)

* Fixed an error in the dispel element for priests
* Fixed an error with the “Show threat levels” option
* Added an option to disable the new eclipse bar — type “/run PoUFDB.useEclipseBar = false; ReloadUI()” in-game
* Changed the boss and party frames to be positioned relative to the UIParent instead of the Minimap, to make sure they’re always on the screen even for people who have moved their minimap around

### Version 4.0.6.148 (20 Feb 2011)

* Added boss frames
* Added an eclipse bar for moonkins (mostly untested because I don’t have a moonkin)
* Added a background intensity option to change how bright the health bar background color is relative to the foreground color (works in reverse for the power bar)
* Added the bear Berserk proc to the default filter list for druids
* Fixed dispel highlighting for hostile units (maybe)

### Version 4.0.3.131 (23 Jan 2011)

* Fixed the health bar color options
* Added options for coloring the power bar

### Version 4.0.3.127 (19 Jan 2011)

* Fixed party pet frames
* Added some basic options for health bar coloring
* Added Fire! and Sniper Training buffs for hunters
* Added Archangel and Dark Archangel buffs for priests
* Added Lifeblood buff from herbalism
* Added full support for localization
* Added Spanish localization
* Added Andika Basic font
* Updated tanking and healing checks

### Version 4.0.3.117 (22 Dec 2010)

* Added phase and quest boss icons
* Updated aura filters for priests and rogues

### Version 4.0.1.109 (6 Nov 2010)

* Comment out unused (unfinished) soul shard texture code

### Version 4.0.1.108 (6 Nov 2010)

* Added new default font — Droid Serif
* Added holy power text
* Added shadow orbs text
* Fixed border color option — now applies to the health bar immediately as intended
* Fixed border size option — now saves between sessions
* Fixed soul shards text
* Removed unused embedded libraries
* Updated aura filters

### Version 4.0.1.99 (16 Oct 2010)

* Updated for oUF 1.5.2 and WoW 4.0
* Added basic text-based holy power and soul shard display
* Added built-in AFK element (based on oUF_AFK by Sonomus, with permission)
* Fixed safe zone display on channeled spells
* Fixed saved variables handling
* Disabled spell tooltip modification by default

### Version 3.3.5.88 (12 Aug 2010)

* Fixed auras

### Version 3.3.5.85 (12 Aug 2010)

* Added configuration panel; type "/pouf" or browse the Interface Options window to find them.
* Added embedded libraries required for configuration panel and resurrection status text; if you do not need these features, you can safely delete the "Libs" folder.

### Version 3.3.5.80 (11 Aug 2010)

* Fixed dispel and threat highlight elements getting stuck (for real this time)
* Fixed a typo in aura filter for DKs
* Fixed the castbar border when borderSize setting is changed

### Version 3.3.5.76 (9 Aug 2010)

* Fixed threat highlighting getting stuck sometimes
* Add offensive dispel and spellsteal support to dispel highlighting (untested)
* Added resurrection status text (requires LibResComm-1.0, not embedded yet)

### Version 3.3.5.73 (8 Aug 2010)

* Fixed aura timers for people using OmniCC 3 Beta instead of the stable release OmniCC 2
* Changed ugly yellow color on uninterruptible casts

### Version 3.3.5.71 (8 Aug 2010)

* Added partypet frames
* Added focus and focustarget frames
* Added buffs on party frames
* Added buffs on target frames in addition to debuffs
* Fixed safe zone for channeled spells
* Fixed healing bar overlapping the power bar background

### Version 3.3.5.69 (8 Aug 2010)

* oUF 1.4 support
* Rewritten from scratch
* Updated looks inspired by oUF_PredatorSimple and oUF_Neav
* Now has castbars for player, pet, and target
* Now has party frames
* Now has filtered aura display (see description for details)

### Version 3.3.0.45-beta (14 Jan 2010)

* Fix tank checking for druids not in a form and death knights not in a presence
* Fix statusbar dropdown so the last statusbar doesn't hang off the bottom

### Version 3.3.0.44-beta (11 Jan 2010)

* Fixed border debuff coloring for debuffs the player can't dispel, and for tanks
* Fixed tank checking for lower levels and for players who didn't learn all their stances/forms/presences (you cheap lazy bastards!)
* Fixed font string placement to prevent overlaps

### Version 3.3.0.43-beta (10 Jan 2010)

* Fixed file path for default font
* Fixed error for classes that can't dispel any debuffs
* Fixed error when changing border style option
* Embedded LibHealComm-4.0

### Version 3.3.0.40-beta (8 Jan 2010)

* Fixed error when not using LibSharedMedia-3.0
* Added embedded libraries

### Version 3.3.0.36-beta (7 Jan 2010)

* Added in-game options panel
* Added support for LibSharedMedia-3.0
* Added resurrection status text via LibResComm-1.0
* Removed aura display for all units
* **Due to many changes in file structure, it is recommended that you delete your existing oUF_Phanx folder before installing this update.**

### Version 3.2.0.22-beta (14 Jun 2009)

* Fix druid mana text
* Fix aura placement on player unit

### Version 3.1.3.18-beta (10 Jun 2009)

* Fix overlapping health and power text on target/focus frames
* Fix threat highlight failing to update when passing through a loading screen
* Add incoming heals module

### Version 3.1.3.15-beta (5 Jun 2009)

* Add font and texture files
* Add option to disable textured border
* General cleanup throughout
* Remove unused files

### Version 3.1.3.13-beta (28 Apr 2009)

* First public release
