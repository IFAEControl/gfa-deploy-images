#!/bin/bash

# TODO: Add die

ROOT="$1"

echo "" > /tmp/gfa_venv_pip_log

function echoerr() {
    echo "$@" 1>&2
}

function die() {
    echoerr "ERROR"
    exit 1
}

echo "Activating python3 venv"
mkdir -p "$ROOT/gfa_venv" || die
python3 -m venv "$ROOT/gfa_venv" || die
source "$ROOT/gfa_venv/bin/activate"  || die

echo "Installing libraries and dependencies"
# guiqwt pip package is broken, so we install dependencies manually
echo -e "\tApplying workarounds for broken pip packages"
pip install numpy &>> /tmp/gfa_venv_pip_log || die
pip install PyQt5 Cython &>> /tmp/gfa_venv_pip_log || die
QT_API=pyqt5 pip install guidata &>> /tmp/gfa_venv_pip_log || die

echo "Installing gfagui"
pip install -U --upgrade-strategy eager gfagui &>> /tmp/gfa_venv_pip_log || die

echo -ne "\a"
