#!/bin/sh
xset -dpms
xset s off
xset s noblank
feh --randomize --bg-max /home/kiosk/background/* #sets background image
$($extraInitCommands)
#xrandr -s $($KioskResolution)
#/home/kiosk/.autorefresh.sh &
#unclutter & #hides the mouse when it is not moving


while true; do
	#xfreerdp /v:'$($RDPURL)' /d:'$($RDPDomain)' /u:'$($RDPUserName)' /p:'$($PlainTextRDPPassword)' /f /cert-ignore /fonts /gdi:hw
    #sed -e 's|"exit_type":"Crashed"|"exit_type":"Normal"|g' -i "/home/kiosk/.config/chromium/Default/Preferences"
    #chromium-browser --start-fullscreen --disable-prompt-on-repost --disable-session-crashed-bubble --kiosk --password-store=basic --no-first-run --disable-features=TranslateUI --app='$($BrowserURL)'
    sleep 5
done