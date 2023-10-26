#!/usr/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Must provide 'red', 'pink', or 'yellow' argument"
  exit 1
fi

GHOST=$1
if ! [[ "${GHOST}" =~ ^(red|pink|yellow)$ ]]; then
  echo "Invalid color. Must provide 'red', 'pink', or 'yellow' argument"
  exit 1
fi

sudo apt update
sudo apt upgrade
sudo apt install -y \
  vim \
  build-essential \
  python3 \
  python3-pygame \
  python3-rpi.gpio \
  unclutter

# Change desktop background (path is in the config)
sudo cp desktop-items-0.conf /etc/xdg/pcmanfm/LXDE-pi/
sudo cp desktop-items-1.conf /etc/xdg/pcmanfm/LXDE-pi/

# Hide mouse pointer unless moved
grep -qxF \
  "@unclutter -idle 0.1" \
  /etc/xdg/lxsession/LXDE-pi/autostart || \
  sudo echo \
  "@unclutter -idle 0.1" >> \
  /etc/xdg/lxsession/LXDE-pi/autostart
# Launch python script on boot
grep -qxF \
  "@python3 /home/ghost/repos/amlabs-halloween/pi-ir/${GHOST}.py" \
  /etc/xdg/lxsession/LXDE-pi/autostart || \
  sudo echo \
  "@python3 /home/ghost/repos/amlabs-halloween/pi-ir/${GHOST}.py" >> \
  /etc/xdg/lxsession/LXDE-pi/autostart
