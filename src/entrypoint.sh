#!/bin/bash

X -config /etc/X11/xorg.conf -noreset -nolisten tcp &
sleep 5
DISPLAY=:0 openbox-session &
sleep 1
x11vnc -passwd q1w2e3 -forever -shared -rfbport 5900 -display :0 &
sleep 1
DISPLAY=:0 xterm &
DISPLAY=:0 google-chrome --no-sandbox
cat /var/log/Xorg.0.log
sleep 600
