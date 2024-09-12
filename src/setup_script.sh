#!/bin/bash

apt-get update
apt-get install -y openbox xorg libnvidia-gl-550-server dbus-x11 gnome-icon-theme libcanberra-gtk-module libcanberra-gtk3-module libgl1-mesa-dri libgl1-mesa-glx libnotify-bin rtkit xserver-xorg-video-nvidia-550-server nvidia-driver-550-server
apt-get install -y wget software-properties-common
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb

cat >/usr/share/glvnd/egl_vendor.d/10_nvidia.json <<EOF
{
  "file_format_version": "1.0.0",
  "ICD": {
    "library_path": "libEGL_nvidia.so.0"
  }
}
EOF

wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg &&
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/VirtualGL.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main" >/etc/apt/sources.list.d/virtualgl.list
apt-get update
apt-get install -y virtualgl

mkdir /tmp/xdg

apt-get -y install supervisor
export XDG_RUNTIME_DIR=/tmp/xdg
