#!/bin/bash

apt-get update
apt-get -qq install -y openbox openbox-menu xorg libnvidia-gl-550-server dbus-x11 gnome-icon-theme libcanberra-gtk-module libcanberra-gtk3-module libgl1-mesa-dri libgl1-mesa-glx libnotify-bin rtkit xserver-xorg-video-nvidia-550-server nvidia-driver-550-server tightvncserver expect x11vnc xterm python3-xdg
apt-get -qq install -y wget software-properties-common
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get -qq install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

cat >/usr/share/glvnd/egl_vendor.d/10_nvidia.json <<EOF
{
  "file_format_version": "1.0.0",
  "ICD": {
    "library_path": "libEGL_nvidia.so.0"
  }
}
EOF

vncpwd_prog=/usr/bin/vncpasswd
mypass="q1w2e3"

/usr/bin/expect <<EOF
spawn "$vncpwd_prog -f /etc/vncpasswd"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect eof
exit
EOF

wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg &&
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/VirtualGL.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main" >/etc/apt/sources.list.d/virtualgl.list
apt-get update
apt-get -qq install -y virtualgl

apt-get -qq install -y locales && locale-gen en_US.UTF-8

mkdir /tmp/xdg

export XDG_RUNTIME_DIR=/tmp/xdg
