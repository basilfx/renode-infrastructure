#!/bin/bash

set -e
set -u

#change dir to script location
cd "${0%/*}"

TARGET="Release"
BASE=../..

REMOVE_WORKDIR=true

DATE=""
COMMIT=""

RPM_MIN_DIST="f23"

function usage {
    echo "$0 {version-number} [-d] [-n] [-h] [-l]"
}

function help {
    usage
    echo
    echo -e "-d\tuse Debug configuration"
    echo -e "-n\tcreate a nightly build with date and commit SHA"
    echo -e "-l\tleave .app directory as is"
    echo -e "-h\tprint this help message"
}

if [ $# -lt 1 ]
then
    usage
    exit
fi

VERSION=$1

shift
while getopts "dhnl" opt
do
    case $opt in
        d)
            TARGET="Debug"
            ;;
        n)
            DATE="+`date +%Y%m%d`"
            COMMIT="git`git rev-parse --short HEAD`"
            ;;
        h)
            help
            exit
            ;;
        l)
            REMOVE_WORKDIR=false
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            exit
            ;;
    esac
done

VERSION="$VERSION$DATE$COMMIT"

# create MacOS app structure
MACOS_APP_DIR=Emul8.app
mkdir -p $MACOS_APP_DIR/Contents/MacOS/
mkdir -p $MACOS_APP_DIR/Contents/Resources/

DIR=$MACOS_APP_DIR/Contents/MacOS

. common_copy_files.sh

cp macos/macos_run.* $MACOS_APP_DIR/Contents/MacOS
cp macos/Info.plist $MACOS_APP_DIR/Contents/
cp macos/emul8.icns $MACOS_APP_DIR/Contents/Resources

hdiutil create -volname Emul8_$VERSION -srcfolder $MACOS_APP_DIR -ov -format UDZO emul8_$VERSION.dmg

#cleanup unless user requests otherwise
if $REMOVE_WORKDIR
then
  rm -rf $MACOS_APP_DIR
fi
