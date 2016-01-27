geolog2gpx - Geolog-Datenbasis via CManager mit Opencaching.de abgleichen
=========================================================================

Nun wird es ganz speziell und vermutlich werden diesen Fall nur sehr wenige haben,
aber ich habe das nun mal zusammengefrickelt und damit auch gleich etliche, ähh,
zwei Leute beschäftigt und so will ich es auch nicht unerwähnt lassen. Und
vielleicht kann ja jemand etwas damit anfangen.

Zur Ausgangslage: Ich habe schon vor geraumer Zeit meinen Account bei
Geocaching.com deaktiviert und verwende seither (aktiv) nur noch Opencaching.de.
Wenn ich mal an einem bei Geocaching.com gelisteten Cache vorbeikomme, dann suche
ich da auch schon mal, gleiches gilt, wenn ich mit Freunden unterwegs bin und
diese nach solchen Dosen suchen gehen. Verwaltet werden alle Funde via
geolog/ocprop und das brachte ein ganz bestimmtes Problem, um dessen Lösung es im
Folgenden geht.

Um hin und wieder mal zu schauen, ob ein bereits via Geocaching.com gefundener
Cache bei Opencaching.de nachgelistet wurde, bietet sich ja inzwischen CManager an.
Das Duo geolog/ocprop kann das zwar grundsätzlich auch, jedoch dauert der Abgleich
hier sehr lange und jeder (oft nur vermeintliche) Treffer muss von Hand bestätigt
oder abgelehnt werden.

CManager wiederum erfordert ein GPX-File, was man jedoch mit geolog nicht erzeugen
kann. Geolog legt die Daten für jeden Cache in einem eigenen Verzeichnis ab und
erzeugt daraus lediglich Webseiten mit allerlei Statistikgedöns. Und genau das ist
auch der grund, weshalb ich das verwende: Mit einfachen Mitteln lässt sich durch
geolog/ocprop eine gemeinsame Statistik erzeugen, die sowohl reine GC-Funde, also
auch reine OC-Funde und/oder Mixfunde darstellen kann. Und damit wäre das oft zu
hörende Argument, man hätte zwar grundsätzliches Interesse an Opencaching.de, nutze
es aber nicht, weil das ja nicht in die Statistik einfließt, ganz trefflich widerlegt.

Nachdem nun CManager erschien, hatte ich dafür lediglich eine ziemlich alte
myFinds.gpx zur Verfügung, die bei weitem nicht alle Funde enthielt, die ich via
Geocaching.com gemacht habe. Via geolog hatte ich jedoch die kompletten Daten am Start,
denn wann immer ich nach Deaktivierung meines GC-Accounts einen GC-Fund gemacht habe,
habe ich einfach einen „alten“ Eintrag im Datenbestand von geolog dupliziert und mit
den korrekten Daten versehen, damit die Gesamtübersicht weiterhin korrekt ist.

Aber wie nun aus den geolog-Daten ein GPX bauen? Hier habe ich kurzerhand auf ein
Shellscript zurückgegriffen, das rekursiv das gesamte Fundverzeichnis von geolog
durchackert und aus den jeweiligen Unterverzeichnissen alle nötigen Daten bezieht. Dabei
war der erste Versuch sogar viel zu umständlich, da ich nicht wusste, welche Daten
CManager wirklich erwartet. Eine Anfrage beim Entwickler ergab, das im Grunde ein ganz
rudimentäres GPX vollkommen ausreichend ist:

```xml
<?xml version="1.0" encoding="utf-8"?>
<gpx>
    <wpt lat="52.123456789" lon="13.123456789">
        <name>GC01234</name>
        <groundspeak:cache>
            <groundspeak:name>Cachename</groundspeak:name>
            <groundspeak:type>Unknown Cache</groundspeak:type>
            <groundspeak:difficulty>2.5</groundspeak:difficulty>
            <groundspeak:terrain>2.5</groundspeak:terrain>
        </groundspeak:cache>
    </wpt>
</gpx>
```

Und da diese Angaben nun wirklich recht einfach aus den geolog-Verzeichnissen extrahiert
werden können, war das entsprechende Shellscript ganz fix gestrickt.

Beim Öffnen des dadurch erzeugten GPX mit CManager gab es dann allerdings noch ein paar
Holperer. Bei einigen Fällen wurde eine Koordinate nicht korrekt extrahiert und somit
stand der Ownername vor der Longitude. Zunächst wollte ich das im Script auch noch
berücksichtigen und solche fehlerhaften Strings automatisch korrigieren, aber irgendwie
tat sich keine richtige Idee auf und Google war zur Abwechslung auch keine wirkliche Hilfe.

Das war aber ganz fix im Editor via Search&Replace behoben und CManager tat artig seinen
Dienst. CManager gibt übrigens, sofern so ein fehlerhafter String enthalten ist, ganz
brav eine entsprechende Meldung aus.

Damit weiß man, wonach man im GPX suchen muss und kann das entsprechend einfach
korrigieren. Genau das habe ich dann auch noch getan und schon ging die Suche los. Und
siehe da, prompt gab es Treffer, die es eigentlich nicht hätte geben sollen. Immerhin
lief ja bisher auch regelmäßig ocprop durch.

Aber wie schon erwähnt, ist es bei ocprop recht umständlich, jeden vermeintlichen
Treffer korrekt zu bewerten und manchmal haut man schneller auf nein als man mag. Und
da liegt ja der klare Vorteil von CManager, der erstmal alles zusammensucht und dann
auf einen Blick zur gemütlichen Prüfung präsentiert.

Übrigens ist mir durchaus klar, das dieses Script nicht wirklich elegant ist. Aber es
funktioniert.

Aber vielleicht hat ja der Eine oder Andere Lust, hier noch etwas mehr Hirnschmalz zu
investieren und erweitert es so, dass man damit ein mehr oder weniger vollständiges
GPX erzeugen kann. Kleinere Dinge, wie bspw. Funddatum und dergleichen ins richtige
Format bringen, habe ich schon gelöst. Das ist hier nur nicht mehr enthalten, weil
CManager letztlich deutlich weniger Angaben erwartete als ich angenommen habe. Und da
ja „FoundGPX.exe“ aktuell nicht mehr weiterentwickelt wird – deshalb habe ich ja auch
das Ganze hier in Gang gebracht – hat man so evtl. einen brauchbaren Nachfolger.
Zumindest für Linuxer.


Besonderheiten?
---------------

Ja, gibt es auch noch. Ich selbst bin ein Entweder-oder-Logger. Das heißt, sobald
ein Cache bei Opencaching.de existiert, wird er nur dort geloggt. Als ich noch einen
GC-Account hatte, habe ich dann die betreffenden Logs bei GC gelöscht. Das geht
jetzt natürlich nicht mehr. Funde der Post-GC-Ära wurde dort natürlich nicht geloggt,
sondern sind nur in meinem geolog-Bestand verzeichnet. Und darin hat ein Cache nun
entweder einen Wegpunkt von OC oder einen von GC. Im Normalfall hingegen sind beide
vertreten.

Dementsprechend ist auch das Script gehalten. es schaut nur, ob ein Cache einen
GC-Wegpunkt hat. Ist dieser vorhanden, dann ist in meinem Fall klar, das gegen OC
geprüft werden soll, da dort bisher kein Log für diesen Cache existiert. Wer jedoch
grundsätzlich auf beiden Plattformen loggt, kann1 das Script also noch entsprechend
anpassen und die Caches ausschließen, die bereits eine OC-ID haben.

Die GC-ID wird ja, wie oben im Script zu sehen, mittels

    $(grep "GCid" $i/cache.txt | awk '{print $2}')

aus der cache.txt ausgelesen. Eine OC-ID hingegen befindet sich immer in der
note.txt, die bspw. auch Angaben zu Erstfunden und Fundreihenfolgen enthalten kann.
So sie denn entsprechend gepflegt wurde. An die OC-ID kommt man dann mittels

    $(grep "OCId" $i/note.txt | awk '{print $2}')

Und ja, die unterschiedliche Schreibweise ‚id‘ und ‚Id‘ ist durchaus richtig so.
Darüber bin ich bei meinen ersten Versuchen nämlich auch gestolpert…
