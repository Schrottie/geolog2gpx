#!/bin/bash
#
#
#
#

GEOLOG_PATH="/home/schrottie/Google Drive/geolog/gcdir/found"
# FINDER=""

# leere Datei erzeugen
FILENAME=`date +%Y-%m-%d-%H-%M`.gpx
touch ./$FILENAME
GPXDATE=$(date +%Y-%m-%dT%H:%M:%SZ)

# GPX-Kopfbereich schreiben
echo '<?xml version="1.0" encoding="utf-8"?>' >> ./$FILENAME;
echo '<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" version="1.0" creator="Opencaching.de - http://www.opencaching.de/" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0/1 http://www.groundspeak.com/cache/1/0/1/cache.xsd" xmlns="http://www.topografix.com/GPX/1/0">' >> ./$FILENAME;
echo '  <name>Cache listing generated from Opencaching.de</name>' >> ./$FILENAME;
echo '  <desc>This is a waypoint file generated from linux shell</desc>' >> ./$FILENAME;
echo '  <author>geolog2gpx</author>' >> ./$FILENAME;
echo '  <email>schrottie@gmail.com</email>' >> ./$FILENAME;
echo '  <url>blog.dafb-o.de</url>' >> ./$FILENAME;
echo '  <urlname>Altmetall</urlname>' >> ./$FILENAME;
echo '  <time>'$GPXDATE'</time>' >> ./$FILENAME;

# Wegpunkte schreiben
cd "$GEOLOG_PATH"
CACHE_FOLDERS=`find . -maxdepth 1 -type d`

for i in $CACHE_FOLDERS ;

do

	# Hat der Cache eine OC-ID?
	if [ "$(grep "OCId" $i/note.txt | awk '{print $2}')" = "" ] ; then
		# Nein. Hat er eine GC-ID?
		if [ "$(grep "GCid" $i/cache.txt | awk '{print $2}')" = "" ] ; then
			# Nein, dann muss es eine NC-ID sein!
			ID=$(grep "NCId" $i/note.txt | awk '{print $2}')
		else
			ID=$(grep "GCid" $i/cache.txt | awk '{print $2}')
		fi
	else
		ID=$(grep "OCId" $i/note.txt | awk '{print $2}')
	fi
	# ID steht, also noch die anderen Werte aus der cache.txt holen.
	NAME=$(grep "Name" $i/cache.txt | awk '{print $2}')
	OWNER=$(grep -w "Owner:" $i/cache.txt | awk '{print $2}')
	OWNERID=$(grep "Ownerid" $i/cache.txt | awk '{print $2}')
	LAT=$(grep "Lat" $i/cache.txt | awk '{print $2}')
	LON=$(grep "Lon" $i/cache.txt | awk '{print $2}')
	if [ "TYPE=$(grep "Type" $i/cache.txt | awk '{print $2}')" = "Traditional" ] ; then
		TYPE="Traditional Cache"
	else
		if [ "TYPE=$(grep "Type" $i/cache.txt | awk '{print $2}')" = "Virtual" ] ; then
			TYPE="Virtual Cache"
		else
			if [ "TYPE=$(grep "Type" $i/cache.txt | awk '{print $2}')" = "Event" ] ; then
				TYPE="Event Cache"
			else
				if [ "TYPE=$(grep "Type" $i/cache.txt | awk '{print $2}')" = "Webcam" ] ; then
					TYPE="Webcam Cache"
				else
					if [ "TYPE=$(grep "Type" $i/cache.txt | awk '{print $2}')" = "Unknown" ] ; then
						TYPE="Unknown Cache"
					else
						TYPE=$(grep "Type" $i/cache.txt | awk '{print $2}')
					fi
				fi
			fi
		fi
	fi
	CONTAINER=$(grep "Container" $i/cache.txt | awk '{print $2}')
	DIFF=$(grep "Difficulty" $i/cache.txt | awk '{print $2}')
	HIDDEN=$(grep "Hidden" $i/cache.txt | awk '{print $2}')
	TERR=$(grep "Terrain" $i/cache.txt | awk '{print $2}')
	HIDDEN=$(grep "Hidden" $i/cache.txt | awk '{print $2}' | sed -r 's/([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})/\3-\2-\1/')
	COUNTRY=$(grep "Country" $i/cache.txt | awk '{print $2}')
	STATE=$(grep "State" $i/cache.txt | awk '{print $2}')
	# Und noch das Funddatum aus der note.txt.
	# FOUND=$(grep "Found" $i/note.txt | awk '{print $2}')
echo "Bearbeite: "$ID;
echo '	<wpt lat="'$LAT'" lon="'$LON'">' >> ../../$FILENAME;
echo '	    <time>'$HIDDEN'T00:00:00Z</time>' >> ../../$FILENAME;
echo '	    <name>'$ID'</name>' >> ../../$FILENAME;
echo '	    <desc>'$NAME'</desc>' >> ../../$FILENAME;
echo '	    <src>geolog-database</src>' >> ../../$FILENAME;
echo '	    <urlname>Bellevue</urlname>' >> ../../$FILENAME;
echo '	    <sym>Geocache Found</sym>' >> ../../$FILENAME;
echo '	    <type>Geocache|'$TYPE'</type>' >> ../../$FILENAME;
echo '	      <groundspeak:name>'$NAME'</groundspeak:name>' >> ../../$FILENAME;
echo '	      <groundspeak:placed_by>'$OWNER'</groundspeak:placed_by>' >> ../../$FILENAME;
echo '	      <groundspeak:owner id="'$OWNERID'">'$OWNER'</groundspeak:owner>' >> ../../$FILENAME;
echo '	      <groundspeak:type>'$TYPE'</groundspeak:type>' >> ../../$FILENAME;
echo '	      <groundspeak:container>'$CONTAINER'</groundspeak:container>' >> ../../$FILENAME;
echo '	      <groundspeak:difficulty>'$DIFF'</groundspeak:difficulty>' >> ../../$FILENAME;
echo '	      <groundspeak:terrain>'$TERR'</groundspeak:terrain>' >> ../../$FILENAME;
echo '	      <groundspeak:country>'$COUNTRY'</groundspeak:country>' >> ../../$FILENAME;
echo '	      <groundspeak:state>'$STATE'</groundspeak:state>' >> ../../$FILENAME;
echo '	    </groundspeak:cache>' >> ../../$FILENAME;
echo '	</wpt>' >> ../../$FILENAME;
done

# Und das GPX ordnungsgemäß zumachen.
echo '</gpx>' >> ../../$FILENAME;
