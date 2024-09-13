#!/bin/bash

capacity=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

if [[ "$status" == "Charging" ]]; then
    case $capacity in
        [0-15]*) echo "%{T4}%{T-}" ;;   # Charging 0-15%
        [16-30]*) echo "%{T4}%{T-}" ;;  # Charging 16-30%
        [31-45]*) echo "%{T4}%{T-}" ;;  # Charging 31-45%
        [46-60]*) echo "%{T4}%{T-}" ;;  # Charging 46-60%
        [61-75]*) echo "%{T4}%{T-}" ;;  # Charging 61-75%
        [76-90]*) echo "%{T4}%{T-}" ;;  # Charging 76-90%
        *)        echo "%{T4}%{T-}" ;;  # Charging 91-100%
    esac
else
    case $capacity in
        [0-15]*) echo "%{T4}%{T-}" ;;   # Discharging 0-15%
        [16-30]*) echo "%{T4}%{T-}" ;;  # Discharging 16-30%
        [31-45]*) echo "%{T4}%{T-}" ;;  # Discharging 31-45%
        [46-60]*) echo "%{T4}%{T-}" ;;  # Discharging 46-60%
        [61-75]*) echo "%{T4}%{T-}" ;;  # Discharging 61-75%
        [76-90]*) echo "%{T4}%{T-}" ;;  # Discharging 76-90%
        *)        echo "%{T4}%{T-}" ;;  # Discharging 91-100%
    esac
fi
