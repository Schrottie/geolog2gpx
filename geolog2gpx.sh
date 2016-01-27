#!/bin/bash

if [ -z "$1" ]; then
    GEOLOG_PATH="/home/schrottie/Google Drive/geolog/gcdir/found"
else
    GEOLOG_PATH="$1"
fi

# GPX erzeugen
FILENAME=`date +%Y-%m-%d-%H-%M`.gpx

# GPX-Kopfbereich schreiben
echo '<?xml version="1.0" encoding="utf-8"?>' > ./$FILENAME;
echo '<gpx>' >> ./$FILENAME;

# Wegpunkte schreiben
CACHE_FOLDERS=`find "$GEOLOG_PATH" -maxdepth 1 -type d`

for i in $CACHE_FOLDERS; do
    ID=$(grep -a "GCid" $i/cache.txt | awk '{print $2}')

    # Hat der Cache eine OC-ID?
    if [ "$ID" = "" ] ; then
        echo "Kein GC-Cache: $i, überspringe Eintrag!"
        continue
    fi
    # ID steht, also noch die anderen Werte aus der cache.txt holen.
    NAME=$(grep -a "Name" $i/cache.txt | awk '{print $2}')
    LAT=$(grep -a "Lat" $i/cache.txt | awk '{print $2}')
    LON=$(grep -a "Lon" $i/cache.txt | awk '{print $2}')
    TYPE_RAW=$(grep -a "Type" $i/cache.txt | awk '{print $2}')

    # Beim Cachetyp hat der korrekte Name Leerzeichen, also nacharbeiten.
    case "$TYPE_RAW" in
        "Traditional"|"Virtual"|"Event"|"Webcam"|"Unknown")
            TYPE="$TYPE_RAW Cache"
            ;;
        "Letterbox")
            TYPE="Letterbox hybrid"
            ;;
        *)
            # Nur der Multi steht schon richtig in der Variable. ;)
            TYPE="$TYPE_RAW"
            ;;
    esac

    # Und noch den Rest einsammeln.
    CONTAINER=$(grep -a "Container:" $i/cache.txt | awk '{print $2}')
    DIFF=$(grep -a "Difficulty" $i/cache.txt | awk '{print $2}')
    TERR=$(grep -a "Terrain" $i/cache.txt | awk '{print $2}')
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
