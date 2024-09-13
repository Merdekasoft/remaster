#!/bin/bash

# Mendapatkan daftar SSID Wi-Fi yang tersedia
wifi_list=$(nmcli -t -f SSID dev wifi | sort -u)

# Memeriksa jika daftar SSID tidak kosong
if [ -z "$wifi_list" ]; then
    echo "No Wi-Fi networks found"
    exit 1
fi

# Menggunakan Rofi untuk menampilkan daftar dan memilih SSID
selected_ssid=$(echo "$wifi_list" | rofi -dmenu -p "Select Wi-Fi Network:")

# Jika SSID dipilih, koneksikan
if [ -n "$selected_ssid" ]; then
    nmcli dev wifi connect "$selected_ssid"
else
    echo "No network selected"
fi
