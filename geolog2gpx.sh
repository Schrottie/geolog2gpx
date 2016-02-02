#!/bin/bash
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# Author: Schrottie, mbirth

usage() {
echo "$@ [-o] [-g] [-b] [-l] [-h]"
echo " Erzeugen eines GPX-File aus dem Datenbestand der Perlprogramme"
echo " geolog und ocprop."
echo "Optionen:"
echo " -o Nur Geocaches von Opencaching.de berücksichtigen."
echo " -g Nur Geocaches von Geocaching.com berücksichtigen."
echo " -b Alle Geocaches berücksichtigen."
echo " -h Diese Hilfe anzeigen."
}

OCONLY=0
GCONLY=0
BOTHOCGC=0

while getopts ogbh OPT; do
case "$OPT" in
        h)
            usage $(basename $0)
            exit 0
            ;;
        o)
            OCONLY=1
            ;;
        g)
            GCONLY=1
            ;;
        b)
            BOTHOCGC=1
            ;;
        \?)
            usage $(basename $0) >&2
            exit 1
            ;;
    esac
done
shift `expr $OPTIND - 1`

BASEPATH=`dirname "$0"`
SEDFILE="$BASEPATH/htmlentities.sed"

if [ -z "$1" ]; then
    GEOLOG_PATH="/home/schrottie/Google Drive/geolog/gcdir/found"
else
    GEOLOG_PATH="$1"
fi


# GPX erzeugen
FILENAME=`date +%Y-%m-%d-%H-%M`.gpx
GPXDATE=$(date +%Y-%m-%dT%H:%M:%SZ)

# GPX-Kopfbereich schreiben
echo '<?xml version="1.0" encoding="utf-8"?>' > ./$FILENAME;
echo '<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="1.0" creator="Opencaching.de - http://www.opencaching.de/" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0/1 http://www.groundspeak.com/cache/1/0/1/cache.xsd" xmlns="http://www.topografix.com/GPX/1/0">' >> ./$FILENAME;
echo '  <name>Cache listing generated from geolog-ocprop-database</name>' >> ./$FILENAME;
echo '  <desc>This is a waypoint file generated from linux shell</desc>' >> ./$FILENAME;
echo '  <author>geolog2gpx</author>' >> ./$FILENAME;
echo '  <email>schrottie@gmail.com</email>' >> ./$FILENAME;
echo '  <url>https://github.com/Schrottie/geolog2gpx</url>' >> ./$FILENAME;
echo '  <urlname>Geolog2GPX</urlname>' >> ./$FILENAME;
echo '  <time>'$GPXDATE'</time>' >> ./$FILENAME;

# Wegpunkte schreiben
find "$GEOLOG_PATH" -mindepth 1 -maxdepth 1 -type d -print0 | \
while IFS= read -r -d '' i; do

	if [ $GCONLY == 1 ] ; then
		# Nur Caches mit GC-ID berücksichtigen!
		ID=$(grep -a "GCid:" "$i/cache.txt" | awk '{print $2}')
		if [ "$ID" = "" ] ; then
			echo "Kein GC-Cache: $i, überspringe Eintrag!"
			continue
		fi
	else
	if [ $OCONLY == 1 ] ; then
		# Nur Caches mit OC-ID berücksichtigen!
		ID=$(grep -a "OCId:" "$i/note.txt" | awk '{print $2}')
		if [ "$ID" = "" ] ; then
			echo "Kein OC-Cache: $i, überspringe Eintrag!"
			continue
		fi
	else
	if [ $BOTHOCGC == 1 ] ; then
		# Alle Caches berücksichtigen!
		ID=$(grep -a "GCid:" "$i/cache.txt" | awk '{print $2}')
		if [ "$ID" = "" ] ; then
			ID=$(grep -a "OCId:" "$i/note.txt" | awk '{print $2}')
		fi
	fi
	fi
	fi

    # ID steht, also noch die anderen Werte aus der cache.txt holen.
    NAME=$(grep -a "Name:" "$i/cache.txt" | cut -d' ' -f2- | iconv -f iso-8859-1 -t utf-8 | sed -f "$SEDFILE")
    LAT=$(grep -a "Lat:" "$i/cache.txt" | awk '{print $2}')
    LON=$(grep -a "Lon:" "$i/cache.txt" | awk '{print $2}')
    TYPE=$(grep -a "Type:" "$i/cache.txt" | cut -d' ' -f2-)
    CONTAINER=$(grep -a "Container:" "$i/cache.txt" | awk '{print $2}')
    DIFF=$(grep -a "Difficulty:" "$i/cache.txt" | awk '{print $2}')
    TERR=$(grep -a "Terrain:" "$i/cache.txt" | awk '{print $2}')
    
    # Ab damit ins GPX.
    echo "Bearbeite: $ID";
    echo '  <wpt lat="'$LAT'" lon="'$LON'">' >> ./$FILENAME;
    echo '      <name>'$ID'</name>' >> ./$FILENAME;
    echo '      <groundspeak:cache>' >> ./$FILENAME;
    echo '          <groundspeak:name>'$NAME'</groundspeak:name>' >> ./$FILENAME;
    echo '          <groundspeak:type>'$TYPE'</groundspeak:type>' >> ./$FILENAME;
    echo '          <groundspeak:difficulty>'$DIFF'</groundspeak:difficulty>' >> ./$FILENAME;
    echo '          <groundspeak:terrain>'$TERR'</groundspeak:terrain>' >> ./$FILENAME;
    echo '      </groundspeak:cache>' >> ./$FILENAME;
    echo '  </wpt>' >> ./$FILENAME;

done

# Und das GPX ordnungsgemäß zumachen.
echo '</gpx>' >> ./$FILENAME;

