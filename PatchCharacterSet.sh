#!/bin/bash

CSET="ISO_IR 100"
VERS="0.1a"

echo ""
echo "PatchCharacterSet Module v$VERS"
echo "------------------------------"
echo ""

if [ "$#" -ne 2 ]; then
    echo "Usage: PatchCharaceterSet [input folder] [output folder]"
    echo "       PatchCharaceterSet %pid %pod"
    echo ""
    exit 0;
fi

if [ ! -d "$1" ]; then
    echo "ERROR: Input folder does not exist $1"
    echo ""
    exit 1;
fi
if [ ! -d "$2" ]; then
    echo "ERROR: Output folder does not exist $2"
    echo ""
    exit 1;
fi

cd $1

if which dcmodify >/dev/null; then
    echo "Now patching the DICOMs to have characeter set $CSET"
    if dcmodify -nb -m "(0008,0005)=$CSET" *.dcm; then
	if mv $1/* $2; then
            echo "Completed moving files."
        else
            echo "ERROR: Moving files not successful!"
            echo "ERROR: $1 -> $2"
            exit 1;
        fi
    else
        echo "ERROR: dcmodify return with error."
        exit 1;
    fi
else
    echo "ERROR: dcmodify command not found."
    exit 1;
fi

echo "Done."
echo ""
exit 0;
