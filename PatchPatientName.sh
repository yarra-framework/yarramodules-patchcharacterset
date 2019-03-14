#!/bin/bash

CSET="ISO_IR 192"
VERS="0.1b"

echo ""
echo "PatchPatientName Module v$VERS"
echo "------------------------------"
echo ""

# Print usage information
if [ "$#" -ne 3 ]; then
    echo "Usage: PatchPatientName [input folder] [output folder] [TWIX file]"
    echo "       PatchPatientName %pid %pod %rid/%rif"
    echo ""
    echo "Requires the binary GetSeqParams in the script folder (from SetDCMTags repo)"
    echo ""
    exit 0;
fi

# Check if input and output folders exist
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
if [ ! -f "$3" ]; then
    echo "ERROR: TWIX file does not exist $3"
    echo ""
    exit 1;
fi

# Check if GetSeqParams binary exists in script path
ModuleDir="$0"
ModuleDir="$(dirname $ModuleDir)"

if [ ! -f "$ModuleDir/GetSeqParams" ]; then
    echo "ERROR: GetSeqParams tool does not exist $3"
    echo ""
    exit 1;
fi

# Get patient name from TWIX file
PatName=$($ModuleDir/GetSeqParams $3 show PatientName)

if [ $? -eq 0 ]; then
    echo "Using name '$PatName'" 
else
    echo "ERROR: Unable to read patient name" 
    echo "$PatName"
    exit 1;
fi

# Now patch the DICOMs with the extracted name and characeted set
cd $1

if which dcmodify >/dev/null; then
    echo "Patching the DICOMs to have characeter set $CSET"
    if dcmodify -nb -m "(0008,0005)=$CSET" -m "(0010,0010)=$PatName" *.dcm; then
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





