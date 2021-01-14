COVID-19 Bewegungsradius
================

# COVID-19 Bewegungsradius

Besuche die App auf
[geobrinkmann.com/bewegungsradius](https://geobrinkmann.com/bewegungsradius/)

[<img src="https://img.br.de/70a46076-f9d8-44bd-9f5a-ede01f747bed.png?q=80&rect=0%2C0%2C7984%2C4495&w=2000" rel="BR_incidence" />](https://www.br.de/nachrichten/bayern/verwirrung-um-15-kilometer-regel-in-niederbayern,SLPUKZ4)

Die 15-Kilomenter Regel, nachdem sich Bewohner mit einer 7-Tage Inzidenz
von über 200 nur noch 15 km um ihren Wohnort bewegen dürfen, sorgt für
Verwirrung. Diese App soll dabei helfen, den individuellen
Bewegungsradius zu ermitteln.  
Zunächst wird die aktuelle 7-Tage-Inzidenz für jeden Landkreis
downloaded und in zwei Kategorien eingeteilt: \< 200 und \>= 200.
Anschließend wird die Adresse georeferenziert und ein 15 km Buffer wird
um die Gemeinde der Adresse gelegt. Der genaue Wert der 7-Tage-Inzidenz,
sowie die Verfügbarkeiten von Intensivstationbetten (ITS) kann durch
Anklicken eines Landkreisen ausgelesen werden.  
Aktuell ist das Geolocating - also nutzen des eigenen Standortes - noch
nicht verfügbar, da kein *https* Zertifikat zur Verfügung steht.

## Die Corona-Regeln in den Bundesländern

| Bundesland             | 15-km Regel                                                                                                    | Mehr Infos                                                                                                                                       |
| :--------------------- | :------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| Baden-Württemberg      | Wird aktuell nicht umgesetzt                                                                                   | [url](https://www.baden-wuerttemberg.de/de/service/aktuelle-infos-zu-corona/)                                                                    |
| Bayern                 | Ab der Gemeindegrenze                                                                                          | [url](https://www.corona-katastrophenschutz.bayern.de/faq/index.php)                                                                             |
| Berlin                 | Ab der Stadtgrenze                                                                                             | [url](https://www.rbb24.de/politik/thema/2020/coronavirus/beitraege_neu/2020/04/berlin-corona-massnahmen-lockerung-ausgang-kontakt-erlaubt.html) |
| Brandenburg            | Für touristische Ausflüge, Sport und Bewegung im Freien, um den jeweiligen Landkreis bzw. die kreisfreie Stadt | [url](https://kkm.brandenburg.de/kkm/de/)                                                                                                        |
| Bremen                 | Wird aktuell nicht umgesetzt                                                                                   | [url](https://www.bremen.de/corona)                                                                                                              |
| Hamburg                | Wird aktuell nicht umgesetzt                                                                                   | [url](https://www.hamburg.de/coronavirus/)                                                                                                       |
| Hessen                 | Ab der Gemeindegrenze; betroffene Landkreise: Gießen, Limburg-Weilburg, Fulda, Vogelsbergkreis                 | [url](https://www.faz.net/aktuell/rhein-main/corona-weitere-kreise-in-hessen-fuehren-15-kilometer-regel-ein-17143539.html)                       |
| Mecklenburg-Vorpommern | Ab der Wohnadresse                                                                                             | [url](https://www.regierung-mv.de/corona/Corona-Regeln-seit-10.01.2021/)                                                                         |
| Niedersachsen          | Ab der Wohnadresse, durch Kommunen geregelt                                                                    | [url](https://www.niedersachsen.de/Coronavirus)                                                                                                  |
| Nordrhein-Westfalen    | Ab der Gemeindegrenze; betroffene Landkreise: Höxter, Minden-Lübbecke, Oberbergischer Kreis, Recklinghausen    | [url](https://www.land.nrw/corona)                                                                                                               |
| Rheinland-Pfalz        | Ab der Gemeindegrenze, durch Kommunen geregelt                                                                 | [url](https://corona.rlp.de/index.php?id=34836)                                                                                                  |
| Saarland               | Für touristische Ausflüge, um die Wohnadresse                                                                  | [url](https://www.saarland.de/DE/portale/corona/home/home_node.html)                                                                             |
| Sachsen                | Ab der Wohnadresse                                                                                             | [url](https://www.coronavirus.sachsen.de/index.html)                                                                                             |
| Sachsen-Anhalt         | Ab der Gemeindegrenze                                                                                          | [url](https://coronavirus.sachsen-anhalt.de/)                                                                                                    |
| Schleswig-Holstein     | Ab der Gemeindegrenze, durch Kommunen geregelt                                                                 | [url](https://www.schleswig-holstein.de/DE/Schwerpunkte/Coronavirus/FAQ/Dossier/Allgemeines_Verwaltung.html)                                     |
| Thüringen              | Ab der Gemeindegrenze, nicht verpflichtend                                                                     | [url](https://corona.thueringen.de/)                                                                                                             |

## Credits

  - Geocoding [D.
    Kisler](https://datascienceplus.com/osm-nominatim-with-r-getting-locations-geo-coordinates-by-its-address/)
  - GPS locater via Dr. Tom August’s [shiny geolocation Javascript
    script](https://github.com/AugustT/shiny_geolocation)
  - API Aufrufe zu den aktuellen [COVID-19
    Fallzahlen](https://services7.arcgis.com/mOBPykOjAyBO2ZKk/ArcGIS/rest/services/Covid19_RKI_Sums/FeatureServer/0/)
    und [ITS-Betten](https://www.divi.de/register/tagesreport) via
    [entorb’s GitHub
    Seite](https://github.com/entorb/COVID-19-Coronavirus-German-Regions)

## Disclaimer

Dieses Tool dient nur zu Unterhaltungszwecken und stellt keine
medizinische, rechtliche oder sonstige Form der Beratung dar. Benutzer
sollten sich auf die offiziellen Richtlinien und Empfehlungen ihrer
nationalen, staatlichen und lokalen Behörden beziehen. Es werden
keinerlei personenbezogener Daten gespeichert.
