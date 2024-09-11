apt-get install -y dbus-x11 supervisor xfce4 xfce4-terminal xterm xclip x11-utils
apt-get install -y --no-install-recommends curl openbox x11-xserver-utils

cat >/usr/bin/xfce4-session-logout <<EOL
#!/usr/bin/env bash
notify-send "Logout" "Please logout or destroy this desktop using the Kasm Control Panel" -i /usr/share/icons/ubuntu-mono-dark/actions/22/system-shutdown-panel-restart.svg
EOL
chmod +x /usr/bin/xfce4-session-logout

cat >/usr/bin/execThunar.sh <<EOL
#!/bin/sh
. $STARTUPDIR/generate_container_user
/usr/bin/Thunar --daemon
EOL
chmod +x /usr/bin/execThunar.sh

cat >/usr/bin/desktop_ready <<EOL
#!/usr/bin/env bash
if [ -z \${START_DE+x} ]; then \
  START_DE="xfce4-session"
fi
until pids=\$(pidof \${START_DE}); do sleep .5; done
EOL
chmod +x /usr/bin/desktop_ready

# Change the default behavior of the delete key which is to move to trash. This will now prompt the user to permanently
# delete the file instead of moving it to trash
mkdir -p /etc/xdg/Thunar/
cat >>/etc/xdg/Thunar/accels.scm <<EOL
(gtk_accel_path "<Actions>/ThunarStandardView/delete" "Delete")
(gtk_accel_path "<Actions>/ThunarLauncher/delete" "Delete")
(gtk_accel_path "<Actions>/ThunarLauncher/trash-delete-2" "")
(gtk_accel_path "<Actions>/ThunarLauncher/trash-delete" "")
EOL

# Support desktop icon trust
cat >>/etc/xdg/autostart/desktop-icons.desktop <<EOL
[Desktop Entry]
Type=Application
Name=Desktop Icon Trust
Exec=/dockerstartup/trustdesktop.sh
EOL
chmod +x /etc/xdg/autostart/desktop-icons.desktop

cat >/usr/bin/desktop_ready <<EOL
#!/usr/bin/env bash
if [ -z \${START_DE+x} ]; then \
  START_DE="xfce4-session"
fi
until pids=\$(pidof \${START_DE}); do sleep .5; done
EOL
chmod +x /usr/bin/desktop_ready

# Support desktop icon trust
cat >>/etc/xdg/autostart/desktop-icons.desktop <<EOL
[Desktop Entry]
Type=Application
Name=Desktop Icon Trust
Exec=/dockerstartup/trustdesktop.sh
EOL
chmod +x /etc/xdg/autostart/desktop-icons.desktop

# OpenBox tweaks
sed -i 's/NLIMC/NLMC/g' /etc/xdg/openbox/rc.xml
