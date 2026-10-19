SNES JUKEBOX - ULTRAPACK ALBUM EDITION v1.2

INSTALL
Load SNES-Jukebox-Album-Edition-v1.2.pk3 with UZDoom 4.14.3 or
GZDoom 4.14+. This is a standalone replacement for the original UltraPack;
load this file instead of loading both jukeboxes together.
Replace older Album Editions too; do not load multiple Album Edition versions.
v1.1 isolates script include paths to prevent collisions with other mods,
including Griffin Voxel Blood's menu.zs / GVGoreMenu.
With Stewie, J may already switch companions. Use Options > SNES Jukebox
or bind a different key through the jukebox's KEYS tab.
All 974 original SPC tracks, the switching sounds, metadata, and original
credits are included. Your original download has not been modified.

OPEN THE MENU
Press J (when that key was not already assigned), or open
Options > SNES Jukebox - Albums. Console: snesjukebox
If J is already in use, bind Open SNES Jukebox in Customize Controls or
in the jukebox's KEYS tab.

FEATURES
- TINYBABY font, privately named SJFONT so other mods' fonts stay intact.
- 66 alphabetized game albums, with every original track number and title.
- Play an individual track or select an album as your playback collection.
- Shuffle without immediately repeating the current song, sequential play,
  and repeat-current-track mode.
- Favorites saved in your engine profile; favorites-only playback.
- Next, previous (in collection order), restart, stop, and restore map music.
- Automatic track advance within one map: two minutes by default.
  Choose 30, 60, 90, 120, 180, 300, 600, 900 seconds, or Off.
- Autoplay, map-change behavior, music volume, switching sounds,
  track notifications, and persistent now-playing HUD.
- Mouse, keyboard, and standard menu controller navigation; key rebinding.

CONTROLS
Left/right on tabs selects a tab; Enter/down enters its list.
Up/down selects a row. Enter activates it. Left/right changes settings.
Page Up / Page Down or the page buttons browses longer lists.
Backspace toggles a favorite in an album track list or Favorites.
In KEYS, Enter binds a key and Backspace clears that binding.
Escape returns from an album to the library, then closes the menu.

The original commands remain: nextsong, origsong, and song <1-974>.
New commands: prevsong, snesjukebox, event sj_stop, event sj_favorite.
The original nomusic and noinfo settings are retained: nomusic disables
map-entry autoplay, while noinfo suppresses the in-game track overlay.
Manual track selection still works with autoplay disabled.

PLAYBACK DETAILS
Shuffle and sequential modes advance during one map by default (120 seconds).
Old v1.1 zero-interval profiles now use 120 seconds. Explicit Off is -1.
Auto-advance is a chosen time interval, not detection of a composition's end.
Repeat Track loops without timed rewinds; Next still moves forward.
Play This Album honors shuffle. Picking a track selects that album for
subsequent songs; browsing albums alone leaves the playing collection intact.
Same Track on map change restarts that song on the new map.
The Previous button moves backward in collection order, not listening history.
Favorites and settings persist when the engine saves its configuration.
Audio controls are local; this mod does not change actors or gameplay.
Use a new game when switching from the original jukebox: existing saves
can retain the original ACS scripts and are not a supported upgrade path.

CREDITS
Original SNES UltraPack compilation and track metadata: Cryomundus.
Original jukebox: TerminusEST13, CombineKegan and contributors listed
in the included original info.txt. Original music remains credited to
the respective games and composers, shown in the menu and LANGUAGE.txt.
TINYBABY font reused from your TuinDoomRPG/src/TINYBABY.lmp.
The engine controller and album menu replace the old ACS controller;
the extracted original source is preserved in the workspace's original folder.

BUILD / VERIFY
PowerShell: powershell -NoProfile -ExecutionPolicy Bypass -File tools/package.ps1
Requires Node.js and Windows PowerShell/.NET. The build validates all 974
metadata entries against their audio files and generates the album catalog.
test/run-check.ps1 compiles in the locally available UZDoom 4.14.3.
Add -Visual for the integration harness and real engine screenshots.
Add -Commands to check the legacy commands and a transition to MAP02.
Test paths in that script refer to this workspace's existing engine/IWAD.
Runtime tested in UZDoom 4.14.3. GZDoom and multiplayer were not run separately.
