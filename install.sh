#!/bin/bash

KLIPPER_PATH="${HOME}/klipper"
CARRIAGE_CHANGER_PATH="${HOME}/klipper-carriage-changer"

set -eu
export LC_ALL=C


function preflight_checks {
    if [ "$EUID" -eq 0 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

function check_download {
    local carriage_changer_dir_name carriage_changer_base_name
    carriage_changer_dir_name="$(dirname ${CARRIAGE_CHANGER_PATH})"
    carriage_changer_base_name="$(basename ${CARRIAGE_CHANGER_PATH})"

    if [ ! -d "${CARRIAGE_CHANGER_PATH}" ]; then
        echo "[DOWNLOAD] Downloading Carriage Changer repository..."
        if git -C $carriage_changer_dir_name clone https://github.com/DavidPeterWatson/klipper-carriage-changer.git $carriage_changer_base_name; then
            chmod +x ${CARRIAGE_CHANGER_PATH}/install.sh
            printf "[DOWNLOAD] Download complete!\n\n"
        else
            echo "[ERROR] Download of Carriage Changer git repository failed!"
            exit -1
        fi
    else
        printf "[DOWNLOAD] Carriage Changer repository already found locally. Continuing...\n\n"
    fi
}

function link_extension {
    echo "[INSTALL] Linking extension to Klipper..."
    ln -srfn "${CARRIAGE_CHANGER_PATH}/carriage_changer.py" "${KLIPPER_PATH}/klippy/extras/carriage_changer.py"
    ln -srfn "${CARRIAGE_CHANGER_PATH}/carriage.py" "${KLIPPER_PATH}/klippy/extras/carriage.py"
    ln -srfn "${CARRIAGE_CHANGER_PATH}/berth.py" "${KLIPPER_PATH}/klippy/extras/berth.py"
    ln -srfn "${CARRIAGE_CHANGER_PATH}/dock.py" "${KLIPPER_PATH}/klippy/extras/dock.py"
    ln -srfn "${CARRIAGE_CHANGER_PATH}/carriage_movement.cfg" "${KLIPPER_PATH}/klippy/extras/carriage_movement.cfg"
    ln -srfn "${CARRIAGE_CHANGER_PATH}/gcode_shell_command.py" "${KLIPPER_PATH}/klippy/extras/gcode_shell_command.py"
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}


printf "\n======================================\n"
echo "- Carriage Changer install script -"
printf "======================================\n\n"


# Run steps
preflight_checks
check_download
link_extension
restart_klipper
