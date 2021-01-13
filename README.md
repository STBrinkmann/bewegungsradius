# COVID-19 Bewegungsradius

Besuche die App auf [geobrinkmann.com/bewegungsradius](https://geobrinkmann.com/bewegungsradius/)

[<img src="https://img.br.de/70a46076-f9d8-44bd-9f5a-ede01f747bed.png?q=80&rect=0%2C0%2C7984%2C4495&w=2000" rel="BR_incidence" />](https://www.br.de/nachrichten/bayern/verwirrung-um-15-kilometer-regel-in-niederbayern,SLPUKZ4)

Die 15-Kilomenter Regel, nachdem sich Bewohner mit einer 7-Tage Inzidenz von über 200 nur noch 15 km um ihren Wohnort bewegen dürfen, sorgt für Verwirrung. Diese App soll dabei helfen, den individuellen Bewegungsradius zu ermitteln.\
Zunächst wird die aktuelle 7-Tage-Inzidenz für jeden Landkreis downloaded und in zwei Kategorien eingeteilt: < 200 und >= 200. Anschließend wird die Adresse georeferenziert und ein 15 km Buffer wird um die Gemeinde der Adresse gelegt. Der genaue Wert der 7-Tage-Inzidenz, sowie die Verfügbarkeiten von Intensivstationbetten (ITS) kann durch Anklicken eines Landkreisen ausgelesen werden.\
Aktuell ist das Geolocating - also nutzen des eigenen Standortes - noch nicht verfügbar, da kein _https_ Zertifikat zur Verfügung steht.


## Credits

* Geocoding [D. Kisler](https://datascienceplus.com/osm-nominatim-with-r-getting-locations-geo-coordinates-by-its-address/)
* GPS locater via Dr. Tom August's [shiny geolocation Javascript script](https://github.com/AugustT/shiny_geolocation) 
* API Aufrufe zu den aktuellen [COVID-19 Fallzahlen](https://services7.arcgis.com/mOBPykOjAyBO2ZKk/ArcGIS/rest/services/Covid19_RKI_Sums/FeatureServer/0/) und [ITS-Betten](https://www.divi.de/register/tagesreport) via [entorb's GitHub Seite](https://github.com/entorb/COVID-19-Coronavirus-German-Regions)


## Disclaimer
Dieses Tool dient nur zu Unterhaltungszwecken und stellt keine medizinische, rechtliche oder sonstige Form der Beratung dar. Benutzer sollten sich auf die offiziellen Richtlinien und Empfehlungen ihrer nationalen, staatlichen und lokalen Behörden beziehen.
Es werden keinerlei personenbezogener Daten gespeichert.