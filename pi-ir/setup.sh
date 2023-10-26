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
sudo apt install \
  vim \
  build-essential \
  python3 \
  python3-pygame \
  python3-rpi.gpio

# Change desktop background (path is in the config)
sudo cp desktop-items-0.conf /etc/xdg/pcmanfm/LXDE-pi/
sudo cp desktop-items-1.conf /etc/xdg/pcmanfm/LXDE-pi/

grep -qxF \
  "@python3 /home/ghost/repos/amlabs-halloween/pi-ir/${GHOST}.py" \
  /etc/xdg/lxsession/LXDE-pi/autostart || \
  sudo echo \
  "@python3 /home/ghost/repos/amlabs-halloween/pi-ir/${GHOST}.py" >> \
  /etc/xdg/lxsession/LXDE-pi/autostart
