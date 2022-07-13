;; ============================================================================================================================================================
;; ============================================================================================================================================================
;; TEIL I: variablenteil
;; ============================================================================================================================================================
;; ============================================================================================================================================================


breed
[
  individual individuals
]

individual-own
[
  ;; characteristics of nodes
  age                   ;; age of an invividual
  age-group
  salary-group          ;; income of an individual
  ;;ed-level            ;; educational level of an individual
  ;;esor                ;; ecological sense of responsibiliy of an individual
  typ                   ;; type of individual
  aoev                  ;; acceptance of electric vehicles

  ;; belonging to group
  adopted_neighbors     ;; how many neighbors have adopted the e-vehicle
  adopt?                 ;; adopted or not

  ;; tam-factors (calculated variables)
  utility-u             ;; utility, perceived usefulness
  belief-e              ;; belief, desire, perceived ease of use
  attitude-a            ;; attitude toward using
  behavior-bi           ;; behavioral intention to use

  ;; time factor
  adoption-check-timer
]

globals
[
  ;; generel network setup
  initial-e-car-count
  tsize
  ;;adopt

  ;; external factors
  subsidies          ;; subsidies on e-cars
  infrastructure     ;; availability of infrastructure
  tax                ;; fuel tax
  price_ev           ;; price of conventional cars

  ;; tam-factors (calculated variables)

  thold                 ;; "Actual system use" / threshold for adoption

]

;; ============================================================================================================================================================
;; ============================================================================================================================================================
;; ende variablenteil
;; ============================================================================================================================================================
;; ============================================================================================================================================================


;; ============================================================================================================================================================
;; ============================================================================================================================================================
;; TEIL II: methoden und mechanismen
;; ============================================================================================================================================================
;; ============================================================================================================================================================

;; ============================================================================================================================================================
;; setup der individuen im netzwerk
;; ============================================================================================================================================================


to setup-individuals

  set-default-shape individual "circle"

  ;;set adopt? false
  set tsize 0.5
  set initial-e-car-count 0.026

  create-individual number-of-nodes
  [
    setxy (random-xcor * 0.95) (random-ycor * 0.95)                                                       ;; for visual reasons, we don't put any nodes *too* close to the edges
  ]

;; zuerst sollen alle turtles not-adopted ins modell geworfen werden
  ask individual [not-adopted]


;; prozentuale Werte aus Tabelle von Wolf (2015) übernommen
  ask n-of (count individual * 0.15) individual [set typ "Comfort-oriented Individualists"]
  ask n-of (count individual * 0.16) individual with [typ = 0] [set typ "Cost-oriented Pragmatics"]
  ask n-of (count individual * 0.34) individual with [typ = 0] [set typ "Innovation-oriented Progressives"]
  ask n-of (count individual * 0.35) individual with [typ = 0] [set typ "Eco-oriented Opinion Leaders"]

;; age-group: prozentuale Anteile sollen entnommen werden aus ESS (2018 | siehe R-file, GitHub --- gerundete Werte)
  ask n-of (count individual * 0.18) individual [set age-group 1 set age (30 - random 12)]
  ask n-of (count individual * 0.16) individual with [age-group = 0] [set age-group 2 set age (42 - random 12)]
  ask n-of (count individual * 0.21) individual with [age-group = 0] [set age-group 3 set age (54 - random 12)]
  ask n-of (count individual * 0.23) individual with [age-group = 0] [set age-group 4 set age (66 - random 12)]
  ask n-of (count individual * 0.16) individual with [age-group = 0] [set age-group 5 set age (78 - random 12)]
  ask n-of (count individual * 0.06) individual with [age-group = 0] [set age-group 5 set age (90 - random 12)]

;; salary-groups: nach Wolf (2015) --- work in progress, funktioniert aktuell nur mit "up-to-n-of", nicht mit "n-of"
  ask n-of (count individual with [typ = "Comfort-oriented Individualists"] * 0.76) individual [set salary-group "<2500€ p. m."]
  ask n-of (count individual with [typ = "Comfort-oriented Individualists"] * 0.24) individual [set salary-group ">2500€ p. m."]

  ask n-of (count individual with [typ = "Cost-oriented Pragmatics"] * 0.77) individual [set salary-group "<2500€ p. m."]
  ask n-of (count individual with [typ = "Cost-oriented Pragmatics"] * 0.23) individual [set salary-group ">2500€ p. m."]

  ask n-of (count individual with [typ = "Innovation-oriented Progressives"] * 0.74) individual [set salary-group "<2500€ p. m."]
  ask n-of (count individual with [typ = "Innovation-oriented Progressives"] * 0.26) individual [set salary-group ">2500€ p. m."]

  ask n-of (count individual with [typ = "Eco-oriented Opinion Leaders"] * 0.72) individual [set salary-group "<2500€ p. m."]
  ask n-of (count individual with [typ = "Eco-oriented Opinion Leaders"] * 0.28) individual [set salary-group ">2500€ p. m."]


;; acceptance of electric vehicle - Attitude Toward Using (A)
  ask individual with [typ = "Comfort-oriented Individualists"] [set aoev 3]
  ask individual with [typ = "Cost-oriented Pragmatics"] [set aoev 3]
  ask individual with [typ = "Innovation-oriented Progressives"] [set aoev 9]
  ask individual with [typ = "Eco-oriented Opinion Leaders"] [set aoev 13]

;; initial car assignment
  ;;ask n-of (count individual * initial-e-car-count) individual with [typ = "Innovation-oriented Progressives" or typ =  "Eco-oriented Opinion Leaders"] [set adopt? true set color green set shape "car" set size tsize * 2]

;; anfrage für individuals dass der anteil von 2,6% die procedure von "adopted" (siehe unten) haben soll
  ask n-of (count individual * initial-e-car-count) turtles [adopted]

;; die funktionieren alle nicht, ich weiß aber nicht warum
  ask individual [ count_neighbor ]
  ;;ask individual [set adopted_neighbors (count (link-neighbors with [adopt? = true]))]
  ;;ask one-of turtles [set adopted_neighbors sum [count turtles]]
  ;;ask individual with [adopt? = false] [count_neighbor]
  ;;ask individual [set adopted_neighbors count individual with [any? link-neighbors with [shape = "car"]]]

end

;; ============================================================================================================================================================
;; ende setup individuen
;; ============================================================================================================================================================



;; ============================================================================================================================================================
;; beschreibung adoption der individuen
;; ============================================================================================================================================================

to adopted  ;; turtle procedure für alle, die adaptieren
  set adopt? true
  set color green
  set shape "car"
  set size tsize * 2
end

to not-adopted  ;; turtle procedure für alle, die nicht adaptieren
  set adopt? false
  set color blue
  set shape "circle"
  set size tsize * 0.9
end

to count_neighbor
  show count (link-neighbors with [shape = "car"])
  ;;if count link-neighbors with [adopt? = true] > 0 [set adopted_neighbors [count turtles [link-neighbors with [shape = "car"]]]]
  ;;show adopted_neighbors
  ;;set adopted_neighbors (count (link-neighbors with [shape = "car"]))
end

;; ============================================================================================================================================================
;; ende beschreibung adoption der individuen
;; ============================================================================================================================================================



;; ============================================================================================================================================================
;; methoden zur verrechnung der globals für externe variablen mit den eingestellten faktoren in den slidern
;; ============================================================================================================================================================

to multiply-infrastructure
  set infrastructure (infrastructure * infrastructure-factor)
end

to multiply-tax
  set tax (tax * tax-factor)
end

to multiply-subsidies
  set subsidies (subsidies * subsidies-factor)
end

to multiply-price_ev
  set price_ev (price_ev * price_ev-factor)
end

to infl-infrastructure
  set belief-e infrastructure + (adopted_neighbors / 10)
end

;; ============================================================================================================================================================
;; ende verrechnungsmethoden
;; ============================================================================================================================================================



;; ============================================================================================================================================================
;; ausbreitungsmechanismen und GO
;; ============================================================================================================================================================

to spread-ev ;; könnte schon funktionieren: methode, die von link-neighbors aus auf die bisher "not-adapted turtles" einwirken soll
  ask turtles with [adopt?]
    [ ask link-neighbors with [not adopt?]
        [ if random-float 100 < thold
            [ adopted ] ]
    ]
end

;; aktuell eher noch pseudocode
;to adoption-check
;  ask turtles with [adopt? and adoption-check-timer = 0]
;  [
;    if (utility-u + belief-e + attitude-a) of turtles > 30 [adopted] ;; 30 hier erstmal als zufälliger Wert ausgewählt; die summenfunktion stimmt noch nicht ganz
;  ]
;end

;; help
;to go
;  if all? turtles [adopt? = false]
;    [ stop ]
;  ask turtles
;  [
;     set adoption-check-timer adoption-check-timer + 1
;     if adoption-check-timer >= adoption-check-frequency
;       [ set adoption-check-timer 0 ]
;  ]
;  spread-ev
;  adoption-check
;  tick
;end

;; ============================================================================================================================================================
;; ende ausbreitungsmechanismen und GO
;; ============================================================================================================================================================



;; ============================================================================================================================================================
;; setup netzwerk
;; ============================================================================================================================================================

to setup-spatially-clustered-network
  let num-links (average-node-degree * number-of-nodes) / 2
  while [count links < num-links ]
  [
    ask one-of turtles
    [
      let choice (min-one-of (other turtles with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-link-with choice ]
    ]
  ]
  ; make the network look a little prettier
  repeat 10
  [
    layout-spring turtles links 0.3 (world-width / (sqrt number-of-nodes)) 1
  ]
end

to setup

  clear-all
  setup-individuals
  setup-spatially-clustered-network
  reset-ticks

end

;; ============================================================================================================================================================
;; ende setup netzwerk
;; ============================================================================================================================================================
@#$#@#$#@
GRAPHICS-WINDOW
277
10
855
589
-1
-1
18.415
1
10
1
1
1
0
0
0
1
-15
15
-15
15
1
1
1
ticks
30.0

SLIDER
12
10
238
43
number-of-nodes
number-of-nodes
10
1000
200.0
1
1
NIL
HORIZONTAL

BUTTON
95
94
165
127
SETUP
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
51
238
84
average-node-degree
average-node-degree
3
15
9.0
1
1
NIL
HORIZONTAL

SLIDER
14
301
240
334
subsidies-factor
subsidies-factor
-1
1
0.0
0.1
1
factor
HORIZONTAL

SLIDER
14
258
240
291
infrastructure-factor
infrastructure-factor
-1
1
0.4
0.1
1
factor
HORIZONTAL

SLIDER
14
215
239
248
tax-factor
tax-factor
-1
1
0.8
0.1
1
factor
HORIZONTAL

SLIDER
14
345
240
378
price_ev-factor
price_ev-factor
-1
1
0.1
0.1
1
factor
HORIZONTAL

BUTTON
168
94
238
127
GO
NIL
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
# Agentenbasierte Modellierung: Verbreitung einer Innovation in einem Netzwerk mit äußeren Einflüssen unter Nutzung des TAM

## FRAGESTELLUNG
> **Welchen Einfluss haben verschiedene Policies des Staates auf die Adaptionsentscheidung eines Individuums (Kauf eines E-Autos) in einem sozialen Netzwerk auf Basis des TAM (Technology Acceptance Model)?**

## Anmerkungen / Aktuelles (während Arbeitsprozess aktualisieren)
+ Innovation = E-Fahrzeuge
	+ Festlegung d. Schwellenwertes: wie hoch? Auf Grundlage von Forschung bestimmbar?
	+ Zusammenstellung d. Formel für die Errechnung, welchen Wert ein Turtle erreicht
	+ Variationsparameter für die externen Variablen über Zeit?
	+ Größe des Netzwerkeffektes: wie bestimmbar?
+ Grundwert für Attitude Toward Using: von uns festgelegt auf Wolf et al. (2015) und deren 
+ Usefulness (U) und Ease of Use (E) müssen von den Individuen eingeschätzt werden können
	+ Hier evtl. Summen-Aggregation besser, z. B.: Grundwert Usefulness E-Auto auf 1 setzen, dann +5 für hohe Subventionen, +2 für etwas Subvention, +0 für keine Subvention (stark vereinfacht)

## Ideen (während Arbeitsprozess aktualisieren)
### Freundschafts- und Familienbeziehungen als Grundlage für das Netzwerk

**Familie:**

+ wir haben Infos aus dem ESS, dass der Average hier bei 2,6 liegt, also können wir von aufgerundet 3 ausgehen (einziges Problem: Average verzerrt evtl. weil wir viele Singles mit einzelnen Haushalten in D. haben --- das nur, dass wir es wissen)

**Freundeskreis:**

+ Ich habe [das hier](https://www.spektrum.de/frage/wie-viele-freunde-kann-ein-mensch-haben/1883803) und [das hier](https://www.quarks.de/gesellschaft/darum-haben-nicht-alle-menschen-in-deinem-leben-platz/) gefunden. Hier steht was von eine Bekannten-Netzwerk von ca. 150 pro Person, aber Freunde sind pro Person bei ca. 10-15 --- zu **engen Vertrauten** (die für uns eigentlich relevanter wären) zählen die meisten Menschen 3-5
+ Die Zahlen werden [bei Gillespie et al. (2015)](https://journals.sagepub.com/doi/full/10.1177/0265407514546977) z. B. wissenschaftlich nochmal bestätigt
+ Dabei gehen eigentlich alle diese Netzwerk-Größen-Überlegungen auf die [Dunbar-Zahl von 150](https://de.wikipedia.org/wiki/Dunbar-Zahl) zurück. Diese kommt aus der Anthropologie/Evolutionsforschung und behandelt die Netzwerkgröße von Primaten, siehe [hier](https://www.sciencedirect.com/science/article/pii/004724849290081J)

**Gewichtung von gleichem Typ bei Nachbarschafts-Faktor**

### Nutzung der "Acceptance of Electric Vehicles" aus Wolf et al. (2015) als Ausgangswert (also Attitude Toward Usings) für die Kalkulation, ob ein Turtle adaptiert oder nicht

+ Beeinflussung daher möglich über Slider der externen Einflüsse, welche *Usefulness* und *Ease of Use* erhöhen/vermindern
+ Beeinflussung ebenfalls über Knoten im jeweiligen Netzwerk als Netzwerkeffekt --- Knoten mit E-Auto beeinflussen andere (evtl. mit Gewichtung: Opinion-Leaders könnten andere eher beeinflussen (als Opinion-Leader = deren Ziel), als Individualisten (kein Interesse daran, was andere für ein Auto fahren sollten)

## Das TAM nach Davis et al. (1989)
Das TAM stellt einen Ansatz für das Nutzungsverhalten eines Individuums gegenüber einer Innovation dar. Dabei werden die jeweiligen Einflüsse des wahrgenommenen Nutzens (Utility) und des tatsächlichen Nutzens (Belief, Desire) auf die damit verbunden Absicht der Nutzung betrachtet. Eine gesteigerte Absicht der Nutzung resultiert schlussendlich zu einer Nutzung jener Technologie (E-Auto). 

Die komplexeren Modelle (TAM2, UTAUT) sind weniger praxiserprobt und komplexer, weshalb sie nicht bzw. nur in Teilen für vorliegende geplante Simulation genutzt werden können und sollen.

### Bestandteile des TAM
**External Variables**: wirken auf U und E ein

+ Beeinflussen, ob diese steigen oder sinken und damit auch, ob eine Innovation adaptiert wird

**Perceived Usefulness (U)**: „wahrgenommene Nützlichkeit“; nach außen, Utility

+ Wahrnehmung eines Individuums: durch die Innovation wird Leben bereichert/verbessert/vereinfacht
+ Je größer der individuelle Nutzen eingeschätzt wird, desto höher U – je größer U, desto größer die Wahrscheinlichkeit der Adaption
+ „Was habe ich davon, wenn ich die Innovation adaptiere?“; Kosten-Nutzen-Abwägung; Aspekte von Rational Choice-Theorie (zielt also eher auf z. B. Subventionen ab)

**Perceived Ease of Use (E)**: „wahrgenommene Benutzerfreundlichkeit“; nach innen, Belief/Desire

+ Abwägung des Individuums: Größe des Aufwandes, den eine Technologieadaption mit sich bringen würde
+ Je geringer dieser Aufwand, desto höher E – je höher E, desto höher die Wahrscheinlichkeit der Adaption der Technologie
+ „Wie einfach wäre es für mich, wenn ich die Technologie adaptiere, auch mit ihr umzugehen?“; Marktsondierung (zielt eher auf z. B. Infrastruktur oder auf die internen Motivationen/Charakteristika ab)

**Attitude toward Using (A)**: Voraussetzungen/Prädispositionen von Individuen (übersetzbar in Zahlenwert)

**Behavioral Intention to Use (BI)** à Individuen denken genauer über die Durchführung Adaption nach

+ Info: TAM geht davon aus (genau wie TRA), dass wenn ein BI geformt wurde, Individuen auch zwangsläufig danach handeln (d. h. aus positivem BI ergibt sich zwingend auch actual system use)

**Actual System Use**: eine Innovation wird vom Individuum adaptiert

## Basic principles
### Fragen an das Modell

> Ist eine stark ausgeprägte Adaption von E-Fahrzeugen Ausdruck von hohen individuellen Charakteristika der Akteure oder wird sie stärker bedingt durch externe Faktoren (staatlicher Eingriff)?

> Welche externen Faktoren (d. h. welche Szenarien) können die Verbreitung der Innovation (aus Sicht staatlichen Eingriffs) verbessern bzw. optimieren? (Das ist lt. Davis et al. (1989) ein Ziel des TAM, das zu ermöglichen)

### Dazugehörige Überlegungen und Zusammenhänge
**Komplexes System / externe Faktoren** 

+ Erstellen der Umwelt mit individuellen Charakteristika für die Akteure in Anlehnung an einen repräsentativen Datensatz der deutschen Gesellschaft
+ Externe Faktoren (denkbar und erweiterbar): Subventionen des Staats für E-Fahrzeuge, Vorhandensein von nötiger Infrastruktur, Treibstoff-Besteuerung, Preis für konventionelle Fahrzeuge
+ Wahrgenommener Nutzen des E-Fahrzeugs im eigenen Netzwerk (z. B. Freundes-/Familienkreis)

**Charakteristika der Akteure**

+ Finanzieller Hintergrund (potenzieller Nutzer muss Geld zum Kauf haben)
+ Alter
+ Wolf (2015): Charakterisierung von E-Mobility-Nutzern (über Zuweisung auf Basis der Informationen aus Wolfs Aufsatz bzw. eventuell Gruppierung/Indexbildung mit Hilfe der Variable zur Umweltfreundlichkeit aus ESS 2018)
- ... (work in progress)

### Faktoren für Dynamik im Modell
1. Unterschiedlich hohe Prädispositionen von Individuen in der Initialisierungsphase des Netzwerks
2. Externe Variablen und deren Wirkkombination bzw. deren „Wichtigkeit“ (über die Faktoren gesteuert) --- getestet durch unterschiedliche Szenarien
3. Externe Variablen variieren mit verstreichender Zeit (Förderungen werden stärker / schwächer oder laufen aus, etc., …)
4. Auswirkungen der Netzwerkstruktur: wenn bereits viele E-Fahrzeug-Nutzer erzeugt wurden, stellt auch das einen Faktor dar, der den Schwellenwert treiben kann (der natürlich nicht allzu hoch sein darf, weil wir sonst den sozialen Druck z. B. mehr für Umwelt zu tun massiv überschätzen würden)

## Wolf, I., Schröder, T., Neumann, J., de Haan, G. (2015). Changing minds about electric cars: An empirically grounded agent-based modeling approach
+ Aufsatz [unter diesem Link](https://www.sciencedirect.com/science/article/abs/pii/S0040162514002960) verfügbar
+ Klassifizierung von Individuen und Zusammenhang mit Präferenz für ein E-Fahrzeug
+ Frage danach, was die einzelnen Gruppen von Individuen bedeuten: sollte hier gelistet werden!
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
