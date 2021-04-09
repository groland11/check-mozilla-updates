#!/usr/bin/env bash
# Copyright (c) 2019
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom
# the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall
# be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

DEBUG=0

function usage {
	echo "$(basename $0) [-d] [-f]"
	echo -e "\t-d\tEnable debug output"
	echo -e "\t-f\tDownload latest tarballs from Mozilla server (fetch)"
	echo
}

function log {
    if [[ ${DEBUG} == 1 || $(echo "$1" | grep ERROR) ]] ; then
		echo "$1"
	fi
}

function download {
    FILENAME=$(basename $1)
    if [ ! -f "${FILENAME}" ] ; then
        log "Downloading $1 ..."
        curl -m 3600 --tlsv1.2 --proto =https -O "$1"
    else
        log "${FILENAME} already exists"
    fi
}

# Function: checkVersion()
# Compare local version with remote version
#
# Parameters:
#  $1: local version
#  $2: remote version
#
# Return value:
#  0: local version is newer or identical
#  1: remote version is newer
#
function checkVersion() {
	V1=$(echo $1 | tr -d [:alpha:])
	V2=$(echo $2 | tr -d [:alpha:])
    log "Checking if version $V1 < $V2 ..."

	MAJ1=$(echo $V1 | cut -d. -f1)
	MIN1=$(echo $V1 | cut -d. -f2)
	REV1=$(echo $V1 | cut -d. -f3)

	MAJ2=$(echo $V2 | cut -d. -f1)
	MIN2=$(echo $V2 | cut -d. -f2)
	REV2=$(echo $V2 | cut -d. -f3)

	if [[ $MAJ1 -lt $MAJ2 ]] ; then
		return 1;
	fi

	if [[ $MAJ1 -eq $MAJ2 ]] ; then
		if [[ -n "$MIN2" ]] ; then
			if [[ -n "$MIN1" ]] ; then
				if [[ $MIN1 -lt $MIN2 ]] ; then
					return 1;
				fi
		
				if [[ $MIN1 -eq $MIN2 ]] ; then
					if [[ -n "$REV2" ]] ; then
						if [[ -n "$REV1" ]] ; then
							if [[ $REV1 -lt $REV2 ]] ; then
								return 1;
							fi
						else
							return 1;
						fi
					fi
				fi
			else
				return 1;
			fi
		fi
	fi
	
	return 0;
}

# Check command line parameters
DEBUG=0
FETCH=0

if [ "$1" == "-d" ] ; then
	DEBUG=1
elif [ "$1" == "-f" ] ; then
	FETCH=1
else
	usage
fi

shift
if [ "$1" == "-f" ] ; then
    FETCH=1
    log "Fetching latest versions from Mozilla download server"
elif [ -n "$1" ] ; then
    usage
fi

# Find executables
if [[ -f /usr/local/thunderbird/thunderbird ]] ; then
	THUNDERBIRD=/usr/local/thunderbird/thunderbird
else
	THUNDERBIRD=thunderbird
fi

if [[ -f /usr/local/firefox/firefox ]] ; then
	FIREFOX=/usr/local/firefox/firefox
else
	FIREFOX=firefox
fi

# Check Thunderbird
URL="https://ftp.mozilla.org/pub/thunderbird/releases/"
curl -s -f -m 10 --tlsv1.2 --proto =https ${URL} 1>/dev/null 2>&1
RET=$?
TB=$(curl -s -f -m 10 --tlsv1.2 --proto =https ${URL} | sed -n "s/^\s\+<td><a href=\".*\">\(.*\)\/<\/a><\/td>$/\1/gp" | sort -V | egrep -iv "b|esr|latest|updates" | tail -n 1)
if [[ ${RET} == 0 ]] ; then
	TBL=$(${THUNDERBIRD} -v | sed -n "s/^\s*Thunderbird\s*\(.*\)$/\1/gp")

    log "Latest Thunderbird Version: ${TB}"
    log "Local  Thunderbird Version: ${TBL}"
	checkVersion $TBL $TB
	if [[ $? -eq 1 ]] ; then
		echo "Update Thunderbird ($TBL -> $TB)"
        URL_DOWNLOAD="${URL}${TB}/linux-x86_64/en-US/thunderbird-${TB}.tar.bz2"
        download ${URL_DOWNLOAD}
	fi
else
	log "ERROR: Failed to access Thunderbird releases"
fi

# Check Firefox
URL="https://ftp.mozilla.org/pub/firefox/releases/"
curl -s -f -m 10 --tlsv1.2 --proto =https ${URL} 1>/dev/null 2>&1
RET=$?
FF=$(curl -s -f -m 10 --tlsv1.2 --proto =https ${URL} | sed -n "s/^\s\+<td><a href=\".*\">\(.*\)\/<\/a><\/td>$/\1/gp" | sort -V | egrep -iv "b|[[:alpha:]]{2,}" | tail -n 1)
if [[ ${RET} == 0 ]] ; then
	FFL=$(${FIREFOX} -v | sed -n "s/^.*Firefox\s*\(.*\)$/\1/gp")

    log "Latest Firefox Version: ${FF}"
    log "Local  Firefox Version: ${FFL}"
	checkVersion $FFL $FF
	if [[ $? -eq 1 ]] ; then
		echo "Update Firefox ($FFL -> $FF)"
        URL_DOWNLOAD="${URL}${FF}/linux-x86_64/en-US/firefox-${FF}.tar.bz2"
        download ${URL_DOWNLOAD}
	fi
else
	log "ERROR: Failed to access Firefox releases"
fi

