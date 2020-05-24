# osu-LWin-Keybind
An AutoHotKey script for using the left Windows key as a keybind in the rhythm game osu!.

It makes it emulate the Z key only while in-game; when not, it acts normally.  
That means you have to bind whatever it is you want the LWin key to do, to Z instead.

Uses AutoHotInterception because for some reason the LWin key is disabled at a very low level in osu!, so more absolute emulation is needed. 
Using just AutoHotKey for this only <i>kinda</i> works, but this works perfectly.

## Download: <a href="https://github.com/Calmoon/osu-LWin-Keybind/releases/latest/download/osu.LWin.Keybind.exe">Latest release</a>
## IMPORTANT: You need the <a href="http://www.oblita.com/interception">Interception driver</a> installed for this to work.


### Common problems and their fixes:
- If you ever start using a new keyboard and this stops working, delete the keyboardHWID.ini file that is generated on the first run and run the script again.
- If you disconnect then connect you keyboard again while this is running, it'll stop working. Just restart the script.
