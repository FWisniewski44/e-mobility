breed
[
  individual individuals
]

individual-own
[
  ;; characteristics of nodes
  salary-group          ;; income of an individual
  pupo                  ;; purchasing power
  pcs                   ;; perceived charging stations
  typ                   ;; type of individual
  adopt?                ;; adopted or not
  individual-thold      ;; individual threshold of each individual

  ;; tam-factors (calculated variables)
  utility-u             ;; utility, perceived usefulness
  belief-e              ;; belief, desire, perceived ease of use
  aoev                  ;; acceptance of electric vehicles // attidude toward using
  adopted_neighbors     ;; how many neighbors have adopted the e-vehicle
  behavior-bi           ;; behavioral intention to use
]

globals
[
  initial-e-car-count
  tsize
  average-node-degree
  tick-count
]

;; ============================================================================================================================================================
;; ============================================================================================================================================================
;; end variable declaration
;; ============================================================================================================================================================
;; ============================================================================================================================================================


;; ============================================================================================================================================================
;; ============================================================================================================================================================
;; TEIL II: Methods and mechanisms
;; ============================================================================================================================================================
;; ============================================================================================================================================================

;; ============================================================================================================================================================
;; setup individuals
;; ============================================================================================================================================================

to setup-individuals

;; definition of variables
  set-default-shape individual "circle"
  set tsize 0.3
  set initial-e-car-count 0.026

;; network design
  create-individual number-of-nodes
  [setxy (random-xcor * 0.95) (random-ycor * 0.95)]

;; initialisation of not-adopted
  ask individual [not-adopted]

;; percentage values taken from Wolf (2015)
  ask n-of (count individual * 0.15) individual [set typ "Comfort-oriented Individualists"]
  ask n-of (count individual * 0.16) individual with [typ = 0] [set typ "Cost-oriented Pragmatics"]
  ask n-of (count individual * 0.34) individual with [typ = 0] [set typ "Innovation-oriented Progressives"]
  ask n-of (count individual * 0.35) individual with [typ = 0] [set typ "Eco-oriented Opinion Leaders"]

;; salary-groups: nach Wolf (2015) --- work in progress, funktioniert aktuell nur mit "up-to-n-of", nicht mit "n-of"
  ask n-of (count individual with [typ = "Comfort-oriented Individualists"] * 0.76) individual with [typ = "Comfort-oriented Individualists"] [set salary-group "<2500‚ p. m."]
  ask individual with [typ = "Comfort-oriented Individualists" and salary-group = 0] [set salary-group ">2500‚ p. m."]

  ask n-of (count individual with [typ = "Cost-oriented Pragmatics"] * 0.77) individual with [typ = "Cost-oriented Pragmatics"] [set salary-group "<2500‚ p. m."]
  ask individual with [typ = "Cost-oriented Pragmatics" and salary-group = 0] [set salary-group ">2500‚ p. m."]

  ask n-of (count individual with [typ = "Innovation-oriented Progressives"] * 0.74) individual with [typ = "Innovation-oriented Progressives"] [set salary-group "<2500‚ p. m."]
  ask individual with [typ = "Innovation-oriented Progressives" and salary-group = 0] [set salary-group ">2500‚ p. m."]

  ask n-of (count individual with [typ = "Eco-oriented Opinion Leaders"] * 0.72) individual with [typ = "Eco-oriented Opinion Leaders"] [set salary-group "<2500‚ p. m."]
  ask individual with [typ = "Eco-oriented Opinion Leaders" and salary-group = 0] [set salary-group ">2500‚ p. m."]

;; assignment of salary amount in % to each individual
  ask individual with [salary-group = "<2500‚ p. m."] [set pupo (random 101) / 100]
  ask individual with [salary-group = ">2500‚ p. m."] [set pupo (100 - random 51) / 100]

;; assignment of perceived charging stations in % to each individual
  ask individual [set pcs (random 101) / 100]

;; acceptance of electric vehicle - Attitude Toward Using (A)
  ask individual with [typ = "Comfort-oriented Individualists"]   [set aoev (3 / 13 * weighting-aoev)   set color 15   set individual-thold (100 - random 21) / 100]
  ask individual with [typ = "Cost-oriented Pragmatics"]          [set aoev (3 / 13 * weighting-aoev)   set color 25   set individual-thold (80 - random 21) / 100]
  ask individual with [typ = "Innovation-oriented Progressives"]  [set aoev (9 / 13 * weighting-aoev)   set color 85   set individual-thold (60 - random 21) / 100]
  ask individual with [typ = "Eco-oriented Opinion Leaders"]      [set aoev (13 / 13 * weighting-aoev)  set color 55   set individual-thold (40 - random 21) / 100]

;; initial e-car count distributed and weighted by categories (2,6%)
  ask n-of (count individual * initial-e-car-count) individual with [typ = "Innovation-oriented Progressives" or typ =  "Eco-oriented Opinion Leaders"] [adopted]
end

;; ============================================================================================================================================================
;; end setup individuals
;; ============================================================================================================================================================

;; ============================================================================================================================================================
;; individual description
;; ============================================================================================================================================================

to adopted  ;; turtle procedure for adoption
  set adopt? true
  set color green
  set shape "car"
  set size tsize * 3
end

to not-adopted  ;; turtle procedure for not-adoption
  set adopt? false
  set shape "circle"
  set size tsize
end

;; ============================================================================================================================================================
;; end of individual description
;; ============================================================================================================================================================

;; ============================================================================================================================================================
;; setup network
;; ============================================================================================================================================================

to setup-spatially-clustered-network ;; taken from initial VIRUS-ON-A-NETWORK-MODELL by Stonedahl, F. and Wilensky, U. (2008). NetLogo Virus on a Network model.
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
  repeat 10
  [
    layout-spring turtles links 0.3 (world-width / (sqrt number-of-nodes)) 1
  ]
end

to setup
  clear-all
  if (weighting-e + weighting-u + weighting-aoev + weighting-an) != 1 [error "Attention: Weight must be total 1!"]
  set average-node-degree 9
  set tick-count 30
  setup-individuals
  setup-spatially-clustered-network
  ask individual with [adopt? = false] [count_neighbors]
  ask individual [set belief-e (infrastructure * pcs * weighting-e)]
  reset-ticks
end
;; ============================================================================================================================================================
;; end setup network
;; ============================================================================================================================================================

;; ============================================================================================================================================================
;; GO
;; ============================================================================================================================================================

to go
  if ticks = tick-count or all? individual [adopt? = true] [stop]
  spread-ev
  ask individual with [adopt? = false] [count_neighbors]
  ask n-of (2 - random 3) individual with [adopt? = false] [adopted]
  tick
end

;; ============================================================================================================================================================
;; end GO
;; ============================================================================================================================================================

;; ============================================================================================================================================================
;; mechanisms
;; ============================================================================================================================================================

to spread-ev
  ask individual [set utility-u (subsidies * pupo * weighting-u)]
  ask individual [calculation]
  ask individual with [adopt? = false]
      [
        ifelse individual-thold <= behavior-bi
          [adopted]
          [not-adopted]
      ]
end

to count_neighbors
  set adopted_neighbors count (link-neighbors with [adopt? = true])
end

to calculation
  ifelse adopted_neighbors = 0
   [set behavior-bi (aoev + utility-u + belief-e)]
   [ifelse adopted_neighbors <= 2
    [set behavior-bi (aoev + utility-u + belief-e + (weighting-an * 0.2))]
    [ifelse adopted_neighbors <= 4
     [set behavior-bi (aoev + utility-u + belief-e + (weighting-an * 0.4))]
     [ifelse adopted_neighbors <= 6
      [set behavior-bi (aoev + utility-u + belief-e + (weighting-an * 0.6))]
      [ifelse adopted_neighbors <= 8
       [set behavior-bi (aoev + utility-u + belief-e + (weighting-an * 0.8))]
       [set behavior-bi (aoev + utility-u + belief-e + (weighting-an))]
      ]
     ]
    ]
   ]
end
@#$#@#$#@
GRAPHICS-WINDOW
478
10
1280
813
-1
-1
25.613
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
0
0
1
ticks
30.0

SLIDER
2
10
473
43
number-of-nodes
number-of-nodes
10
1000
1000.0
1
1
NIL
HORIZONTAL

BUTTON
2
112
237
145
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
238
44
473
77
subsidies
subsidies
0
1
0.5
0.1
1
factor
HORIZONTAL

SLIDER
2
44
237
77
infrastructure
infrastructure
0
1
0.5
0.1
1
factor
HORIZONTAL

BUTTON
120
146
237
179
GO
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
0
433
475
813
Adopted individuals in %
NIL
NIL
0.0
30.0
0.0
1.0
true
true
"" ""
PENS
"Adoptors" 1.0 0 -16777216 true "" "plot count turtles with [adopt? = true] / count turtles"
"Individualists" 1.0 0 -2674135 true "" "plot count turtles with [adopt? = true and typ = \"Comfort-oriented Individualists\"] / count turtles"
"Pragmatics" 1.0 0 -955883 true "" "plot count turtles with [adopt? = true and typ = \"Cost-oriented Pragmatics\"] / count turtles"
"Progressives" 1.0 0 -11221820 true "" "plot count turtles with [adopt? = true and typ = \"Innovation-oriented Progressives\"] / count turtles"
"Opinion Leaders" 1.0 0 -10899396 true "" "plot count turtles with [adopt? = true and typ = \"Eco-oriented Opinion Leaders\"] / count turtles"

BUTTON
2
146
119
179
GO ONCE
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
356
385
473
430
Adopted Individualists
count turtles with [adopt? = true and typ = \"Comfort-oriented Individualists\"]
0
1
11

MONITOR
120
385
237
430
Adopted Pragmatics
count turtles with [adopt? = true and typ = \"Cost-oriented Pragmatics\"]
0
1
11

MONITOR
238
385
355
430
Adopted Progressives
count turtles with [adopt? = true and typ = \"Innovation-oriented Progressives\"]
0
1
11

MONITOR
2
385
119
430
Adopted Opinion Leaders
count turtles with [adopt? = true and typ = \"Eco-oriented Opinion Leaders\"]
0
1
11

SLIDER
2
78
119
111
weighting-u
weighting-u
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
120
78
237
111
weighting-e
weighting-e
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
238
78
355
111
weighting-aoev
weighting-aoev
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
356
78
473
111
weighting-an
weighting-an
0
1
0.25
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
# Agentenbasierte Modellierung: Verbreitung einer Innovation in einem Netzwerk mit äußeren Einflüssen unter Nutzung des TAM

## FRAGESTELLUNG
> **Welchen Einfluss haben verschiedene Policies des Staates auf die Adaptionsentscheidung eines Individuums (Kauf eines E-Autos) in einem sozialen Netzwerk auf Basis des TAM (Technology Acceptance Model)?**

## Anmerkungen / Aktuelles (während Arbeitsprozess aktualisieren)
**Berechnungen im TAM**

<img src="TAM_Berechnungen.jpeg" alt="TAM mit unseren Berechnungen" width="1000"/>


+ Innovation = E-Fahrzeuge
	+ Festlegung d. Schwellenwertes: wie hoch? Auf Grundlage von Forschung bestimmbar?
	+ Zusammenstellung d. Formel für die Errechnung, welchen Wert ein Turtle erreicht
	+ Variationsparameter für die externen Variablen über Zeit?
	+ Größe des Netzwerkeffektes: wie bestimmbar?
+ Grundwert für Attitude Toward Using: von uns festgelegt auf Wolf et al. (2015) und deren 
+ Usefulness (U) und Ease of Use (E) müssen von den Individuen eingeschätzt werden können
	+ Hier evtl. Summen-Aggregation besser, z. B.: Grundwert Usefulness E-Auto auf 1 setzen, dann +5 für hohe Subventionen, +2 für etwas Subvention, +0 für keine Subvention (stark vereinfacht)

**Gewichtung von gleichem Typ bei Nachbarschafts-Faktor**

+ Auszählung der Nachbarn: wie viele haben schon adopted?
	+ möglich nach: Farbe, Shape, Status von "adopt?"-Variable
	+ Aktuell: Schwierigkeiten mit *link-neighbors*-Funktion und *count*

## Ideen (während Arbeitsprozess aktualisieren)
### Freundschafts- und Familienbeziehungen als Grundlage für das Netzwerk

**Familie:**

+ wir haben Infos aus dem ESS, dass der Average hier bei 2,6 liegt, also können wir von aufgerundet 3 ausgehen (einziges Problem: Average verzerrt evtl. weil wir viele Singles mit einzelnen Haushalten in D. haben --- das nur, dass wir es wissen)

**Freundeskreis:**

+ Ich habe [das hier](https://www.spektrum.de/frage/wie-viele-freunde-kann-ein-mensch-haben/1883803) und [das hier](https://www.quarks.de/gesellschaft/darum-haben-nicht-alle-menschen-in-deinem-leben-platz/) gefunden. Hier steht etwas von eine Bekannten-Netzwerk von ca. 150 pro Person, aber Freunde sind pro Person bei ca. 10-15 --- zu **engen Vertrauten** (die für uns eigentlich relevanter wären) zählen die meisten Menschen 3-5 bzw. lt. Gillespie 4-6.
+ Die Zahlen werden [bei Gillespie et al. (2015)](https://journals.sagepub.com/doi/full/10.1177/0265407514546977) z. B. wissenschaftlich nochmal bestätigt
+ Dabei gehen eigentlich alle diese Netzwerk-Größen-Überlegungen auf die [Dunbar-Zahl von 150](https://de.wikipedia.org/wiki/Dunbar-Zahl) zurück. Diese kommt aus der Anthropologie/Evolutionsforschung und behandelt die Netzwerkgröße von Primaten, siehe [hier](https://www.sciencedirect.com/science/article/pii/004724849290081J)

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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [adopt? = true]</metric>
    <metric>count turtles with [adopt? = true and typ = "Comfort-oriented Individualists"]</metric>
    <metric>count turtles with [adopt? = true and typ = "Cost-oriented Pragmatics"]</metric>
    <metric>count turtles with [adopt? = true and typ = "Innovation-oriented Progressives"]</metric>
    <metric>count turtles with [adopt? = true and typ = "Eco-oriented Opinion Leaders"]</metric>
    <enumeratedValueSet variable="number-of-nodes">
      <value value="1000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="infrastructure" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="subsidies" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="random-seed" first="100" step="1" last="200"/>
    <enumeratedValueSet variable="weighting-u">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weighting-aoev">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weighting-e">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weighting-an">
      <value value="0.25"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
