oUF_Phanx
=========

* Copyright (c) 2008-2013 Phanx <addons@phanx.net>
* See the accompanying LICENSE file for more information
* http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
* http://wow.curseforge.com/addons/ouf-phanx/


Description
-----------

oUF_Phanx is a PvE-oriented layout for oUF.


### Features:

* Aggro highlighting
* Buff and debuff filtering, with in-game options
* Debuff highlighting, with defensive and offensive dispel priorities
* Incoming heals overlaid on health bars
* Bar display for druid mana, eclipse power, runes, and totems
* Combo-point style display for chi, holy power, shadow orbs, burning
  embers, demonic fury, soul shards, and Maelstom Weapon stacks
* Casting bars on player, pet, target, and focus frames
* Resurrection and Soulstone status text
* AFK timers on player and party frames
* Optional combat feedback text
* More detailed health and power text on mouseover

Hold Shift out of combat to temporarily disable buff filtering.
Some elements auto-adjust based on role (healer, tank, damage).
No timers for druid mushrooms or death knight ghouls yet.


### Supported Units

* Player
* Pet
* Target
* Target of target
* Focus
* Target of focus
* Party
* Party pets
* Arena enemies
* Arena enemy pets
* Bosses

Raid frames will *not* be added; use Grid or another raid frame addon
of your choice, or even the default raid frames if you like.


### Supported Plugins

* oUF_MovableFrames
* oUF_SmoothUpdate
* oUF_SpellRange

If you’d like to see support for another plugin, please post a feature
request ticket with a link to the plugin's download page.


Usage
-----

Some basic options can be changed in the configuration panel. Find it in
the Interface Options window or by typing “/pouf”.

A few additional options are available by editing the “oUF_Phanx.lua”
file in your SavedVariables directory. Note that you must have logged
in with the addon enabled, and then logged out or reloaded your UI, at
least once before this file will appear. Also, you must log out before
editing this file, or your changes will have no effect.

If you want to change something that doesn’t have an option to change,
you will need to modify the layout’s code yourself, and I will *not*
provide any support or assistance for this. If you need help modifying
the code, post a thread in the oUF forum on WoWInterface:

http://www.wowinterface.com/forums/forumdisplay.php?f=87


Dependencies
------------

Requires oUF 1.6 or higher:
http://www.wowinterface.com/downloads/info9994-oUF.html


Localization
------------

Works in English, Deutsch, Español, Français, Italiano, Português,
Русский, 한국어, 简体中文, and 繁體中文 game clients.

Completely translated into English, Deutsch, and Español.

Partially translated into Français, Português, Русский, and 简体中文.

To add or update translations for any language, see the Localization tab
on the CurseForge project page:

http://wow.curseforge.com/addons/ouf-phanx/localization/


Feedback
--------

Bugs, errors, or other problems:
	Submit a bug report ticket on either download page.

Feature requests or other suggestions:
	Submit a feature request ticket system on either download page.

General questions or comments:
	Post a comment on the WoWInterface download page.

If you need to contact me privately for a reason other than those listed
above, you can send me a private message on either download site, or
email me at <addons@phanx.net>.