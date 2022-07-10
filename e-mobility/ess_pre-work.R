library(tidyverse)
library(readr)
library(expss)
library(summarytools)
library(AMR)

# Datensatz
ess18 <- read_csv(file = "ESS9e03_1 3.csv")

# alter
summarytools::dfSummary(ess18$agea)
fre(ess18$agea)

## nur individuen über 18 behalten
ess18 <- ess18[!(ess18$agea == 15 | ess18$agea == 16 | ess18$agea == 17 | ess18$agea == 999), ]

## altersgruppierung mittels der funktion anwenden
ess18$ageNew <- AMR::age_groups(ess18$agea, split_at = c(31, 43, 55, 67, 79))
fre(ess18$ageNew)

# Einstellung Naturschutz bzw. ökologische Werte

## impenv
# Now I will briefly describe some people.
# Please listen to each description and tell me how much each person is or is not like you.
# Use this card for your answer. She/he strongly believes that people should care for nature.
# Looking after the environment is important to her/him.

summarytools::dfSummary(ess18$impenv)
fre(ess18$impenv)

## fraglich, ob sinnvoll integrierbar, da extrem ungleiche verteilung
hist(ess18$impenv)

## denkbar: werte normalisieren (min max, sqrt, log)
hist(log(ess18$impenv))
hist(sqrt(ess18$impenv))

normalize <- function(x, na.rm = TRUE) {
  return((x- min(x)) /(max(x)-min(x)))
}

hist(normalize(ess18$impenv)) ## eigentlich nutzlos, weil verteilung die gleiche bleibt









