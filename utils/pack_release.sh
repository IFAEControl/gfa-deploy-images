#!/bin/bash

# Parameters order
#   1: root of this repository
#   2: tar of the firmware files
#   3: api version number
#   4: gfaaccesslib
#   5: gfafunctionality
#   6: gfagui


function echoerr() {
    echo "$@" 1>&2
}

function get_commit() {
    (
        cd "$1" || exit 1
        git rev-parse HEAD || exit 1
    )
}

function get_parameter() {
    grep "$2" "$1" | cut -d' ' -f 2 | tr -d '\n'
}

function pack() {
    (

        local out_file
        cd "$1" || exit
        out_file="$(basename "$1").zip"
        git ls-files | grep -v id_rsa_docker | zip -@ "$OLDPWD/$out_file" > /dev/null || exit 1
    )
}

if [ $# -ne 6 ]; then
    echoerr "Invalid number of arguments: $#"
    exit 1 
fi

if [ "$(basename "$2" | rev | cut -d. -f1 | rev)" != "tar" ]; then
    echoerr "Second argument should be a tar file (the firmware)"
    exit 1
fi

API_VERSION="$3"

ROOT="$1"

DATE=$(date +%Y%m%d%H%M)
mkdir "$ROOT/$DATE" || exit 1
(
    cd "$ROOT/$DATE" || exit 1

    for i in "${@:4}"; do
        pack "$i" || exit 1
    done

    cp "$2"  . || exit 1
)


LIB_COMMIT=$(get_commit "$4")
FUNCTIONALITY_COMMIT=$(get_commit "$5")
GUI_COMMIT=$(get_commit "$6")

TMP_DIR="$(mktemp -d)"
tar -xvf "$2"  -C "$TMP_DIR" || exit 1
SERVER_COMMIT=$(get_parameter "$TMP_DIR/info_versions" gfaserver)
MODULELIB_COMMIT=$(get_parameter "$TMP_DIR/info_versions" gfamodulelib)
MODULE_COMMIT=$(get_parameter "$TMP_DIR/info_versions" "gfamodule ")
YOCTO_COMMIT=$(get_parameter "$TMP_DIR/info_versions" gfayocto)
rm -rf "$TMP_DIR" || exit 1

cd "$ROOT" || exit 1
echo "$DATE;$API_VERSION;$LIB_COMMIT;$FUNCTIONALITY_COMMIT;$GUI_COMMIT;$SERVER_COMMIT;$MODULELIB_COMMIT;$MODULE_COMMIT;$YOCTO_COMMIT" >> releases_details.csv
