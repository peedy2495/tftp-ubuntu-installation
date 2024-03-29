#!/bin/bash
if lspci|grep VGA|grep -q AMD; then
    echo "AMD GPU installation not implemented, jet ... sorry"

elif lspci|grep VGA|grep -q NVIDIA; then
    curtin in-target --target=/target -- apt-get update
    curtin in-target --target=/target -- apt-get install -y --install-recommends nvidia-driver-535
    curtin in-target --target=/target -- apt-get remove -y xserver-xorg-video-nouveau
    curtin in-target --target=/target -- apt-get autoremove -y
    curtin in-target --target=/target -- apt-get install --reinstall -y libxatracker2 libxvmc1 xserver-xorg-video-amdgpu xserver-xorg-video-ati xserver-xorg-video-fbdev xserver-xorg-video-intel xserver-xorg-video-qxl xserver-xorg-video-radeon xserver-xorg-video-vesa

else
    # Are we in a VM? Download packages for proxy-caching, only
    curtin in-target --target=/target -- apt-get update
    curtin in-target --target=/target -- apt-get install -y --install-recommends nvidia-driver-535
    curtin in-target --target=/target -- apt-get install -y --install-recommends libxatracker2 libxvmc1 xserver-xorg-video-amdgpu xserver-xorg-video-ati xserver-xorg-video-fbdev xserver-xorg-video-intel xserver-xorg-video-qxl xserver-xorg-video-radeon xserver-xorg-video-vesa
fi
