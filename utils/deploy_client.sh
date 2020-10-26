#!/bin/bash

# TODO: Add die

ROOT="$1"
RELEASE="$2"

echo "" > /tmp/gfa_venv_pip_log

function echoerr() {
    echo "$@" 1>&2
}

function die() {
    echoerr "ERROR"
    exit 1
}

function install() {
    (
        cd "$1" || exit 1
	if stat requirements.txt &> /dev/null; then
		QT_API=pyqt5 pip install -r requirements.txt &>> /tmp/gfa_venv_pip_log || exit 1
	fi

        if stat setup.py &> /dev/null; then
		python3 setup.py install &>> /tmp/gfa_venv_pip_log || exit 1
	fi
    ) || die
}

echo "Activating python3 venv"
mkdir -p "$ROOT/gfa_venv" || die
python3 -m venv "$ROOT/gfa_venv" || die
source "$ROOT/gfa_venv/bin/activate"  || die

echo "Copying gfa related libraries"
cp "$RELEASE"/*.zip "$ROOT/gfa_venv" || die
cd "$ROOT/gfa_venv" || die
rm -rf gfagui gfa*functionality gfa*accesslib

echo "Unziping libraries"
for i in *.zip; do
    unzip "$i" -d "$(basename $i .zip)" &> /dev/null   || die
done

echo "Installing libraries and dependencies"

pip install numpy &>> /tmp/gfa_venv_pip_log || die

# some pip packages are broken, so we install dependencies manually
echo -e "\tApplying workarounds for broken pip packages"
pip install sip &>> /tmp/gfa_venv_pip_log || die
pip install PyQt5 Cython &>> /tmp/gfa_venv_pip_log || die
QT_API=pyqt5 pip install guidata &>> /tmp/gfa_venv_pip_log || die

# Install dependencies of gfa_accesslib
# TOOD: Remove it in future releases, we should use requirements.txt
pip install pytz

git clone https://github.com/IFAEControl/pyqt_tools &> /dev/null
install pyqt_tools || die

for i in gfa*accesslib/python gfa*functionality "gfagui"; do
    echo -e "\tInstalling $i and dependencies"
    install "$i" || die
done

echo -ne "\a"
