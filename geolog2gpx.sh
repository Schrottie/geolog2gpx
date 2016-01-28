#!/bin/bash

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

    ID=$(grep -a "GCid:" "$i/cache.txt" | awk '{print $2}')

    # Hat der Cache eine OC-ID?
    if [ "$ID" = "" ] ; then
        echo "Kein GC-Cache: $i, überspringe Eintrag!"
        continue
    fi
    # ID steht, also noch die anderen Werte aus der cache.txt holen.
    NAME=$(grep -a "Name:" "$i/cache.txt" | cut -d' ' -f2-)
    LAT=$(grep -a "Lat:" "$i/cache.txt" | awk '{print $2}')
    LON=$(grep -a "Lon:" "$i/cache.txt" | awk '{print $2}')
    TYPE=$(grep -a "Type:" "$i/cache.txt" | cut -d' ' -f2-)

    # Und noch den Rest einsammeln.
    CONTAINER=$(grep -a "Container:" "$i/cache.txt" | awk '{print $2}')
    DIFF=$(grep -a "Difficulty:" "$i/cache.txt" | awk '{print $2}')
    TERR=$(grep -a "Terrain:" "$i/cache.txt" | awk '{print $2}')
    # Ab damit ins GPX.
    echo "Bearbeite: $ID ($i)";
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
