#!/bin/bash
#
GEOLOG_PATH="/home/schrottie/Google Drive/geolog/gcdir/found"
# GPX erzeugen
FILENAME=`date +%Y-%m-%d-%H-%M`.gpx

# GPX-Kopfbereich schreiben
echo '<?xml version="1.0" encoding="utf-8"?>' > ./$FILENAME;
echo '<gpx>' >> ./$FILENAME;

# Wegpunkte schreiben
cd "$GEOLOG_PATH"
CACHE_FOLDERS=`find . -maxdepth 1 -type d`

for i in $CACHE_FOLDERS ;

do

    # Hat der Cache eine OC-ID?
    if [ "$(grep "GCid" $i/cache.txt | awk '{print $2}')" = "" ] ; then
        echo "Kein GC-Cache, überspringe Eintrag!"
    else
        ID=$(grep "GCid" $i/cache.txt | awk '{print $2}')
        # ID steht, also noch die anderen Werte aus der cache.txt holen.
        NAME=$(grep "Name" $i/cache.txt | awk '{print $2}')
        LAT=$(grep "Lat" $i/cache.txt | awk '{print $2}')
        LON=$(grep "Lon" $i/cache.txt | awk '{print $2}')

        # Beim Cachetyp hat der korrekte Name Leerzeichen, also nacharbeiten.
        if [ $(grep "Type" $i/cache.txt | awk '{print $2}') = "Traditional" ] ; then
            TYPE="Traditional Cache"
        else
            if [ $(grep "Type" $i/cache.txt | awk '{print $2}') = "Virtual" ] ; then
                TYPE="Virtual Cache"
            else
                if [ $(grep "Type" $i/cache.txt | awk '{print $2}') = "Event" ] ; then
                    TYPE="Event Cache"
                else
                    if [ $(grep "Type" $i/cache.txt | awk '{print $2}') = "Webcam" ] ; then
                        TYPE="Webcam Cache"
                    else
                        if [ $(grep "Type" $i/cache.txt | awk '{print $2}') = "Unknown" ] ; then
                            TYPE="Unknown Cache"
                        else
                            if [ $(grep "Type" $i/cache.txt | awk '{print $2}') = "Letterbox" ] ; then
                            TYPE="Letterbox hybrid"
                            else
                                # Nur der Multi steht schon richtig in der Variable. ;)
                                TYPE=$(grep "Type" $i/cache.txt | awk '{print $2}')
                            fi
                        fi
                    fi
                fi
            fi
        fi
        # Und noch den Rest einsammeln.
        CONTAINER=$(grep "Container:" $i/cache.txt | awk '{print $2}')
        DIFF=$(grep "Difficulty" $i/cache.txt | awk '{print $2}')
        TERR=$(grep "Terrain" $i/cache.txt | awk '{print $2}')
        # Ab damit ins GPX.
        echo "Bearbeite: "$ID;
        echo '  <wpt lat="'$LAT'" lon="'$LON'">' >> ../../$FILENAME;
        echo '      <name>'$ID'</name>' >> ../../$FILENAME;
        echo '      <groundspeak:cache>' >> ../../$FILENAME;
        echo '          <groundspeak:name>'$NAME'</groundspeak:name>' >> ../../$FILENAME;
        echo '          <groundspeak:type>'$TYPE'</groundspeak:type>' >> ../../$FILENAME;
        echo '          <groundspeak:difficulty>'$DIFF'</groundspeak:difficulty>' >> ../../$FILENAME;
        echo '          <groundspeak:terrain>'$TERR'</groundspeak:terrain>' >> ../../$FILENAME;
        echo '      </groundspeak:cache>' >> ../../$FILENAME;
        echo '  </wpt>' >> ../../$FILENAME;
    fi

done

# Und das GPX ordnungsgemäß zumachen.
echo '</gpx>' >> ../../$FILENAME;
