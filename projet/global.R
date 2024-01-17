packages <- c("shiny", "shinydashboard", "tidyverse", "DT", "ggplot2", "plotly", "ggcorrplot", "maps")
install.packages(setdiff(packages, rownames(installed.packages())))

library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)
library(ggplot2)
library(plotly)
library(ggcorrplot)
library(maps)

# Chemin vers le fichier Python (attention au chemin d'accès)
chemin_vers_python_script <- "nettoyage_dataset.py"

# Appeler Python avec le fichier en tant qu'argument
system(paste("python", chemin_vers_python_script))

df <- read.csv("repartition_energie_UE_cleaned.csv", check.names = FALSE)


#liste des pays
country <- df%>%
  distinct(Pays_fr)

#liste des années
years <- df%>%
  distinct(Annee)


#second menu graphics

#variable distribution
var_quant_dist <- df %>% 
  select(-"Pays",-"Pays_fr", -"Annee", -"Population", -"Superficie(Km2)", -"Densite(P/Km2)")%>%
  names()

#matrice de corrélation
var_mat <- df %>% 
  select(-"Pays",-"Pays_fr", -"Annee", -"Population", -"Superficie(Km2)", -"Densite(P/Km2)", 
         -"Electricite d'origine fossile(TWh)", -"Electricite d'origine nucleaire(TWh)",
         -"Electricite d'origine renouvelable(TWh)")%>%
  names()

df_quant <- df %>%
  select(all_of(var_mat))

mat <- round(cor(df_quant), 1)


#variable barplot, max-min
var_bar <- df %>% 
  select(-"Pays",-"Pays_fr", -"Annee") %>%
  names()

#variable scatter
var_hist <- df %>% 
  select(-"Pays",-"Pays_fr", -"Annee", -"Superficie(Km2)", -"Population", -"Densite(P/Km2)") %>%
  names()


#variables courbe de tendance
df_scat_x <- df %>%
  select("Emissions CO2(kt)","Intensite energetique(MJ/$2017 PIB PPA)","Croissance PIB(%)", "PIB/habitant($)") %>%
  names()

df_scat_y <- df %>%
  select("Electricite d'origine fossile / hab(KWh/pers)", "Electricite d'origine nucleaire / hab(KWh/pers)",
         "Electricite d'origine renouvelable / hab(KWh/pers)","Electricite d'origine fossile(TWh)", "Electricite d'origine nucleaire(TWh)",
         "Electricite d'origine renouvelable(TWh)",) %>%
  names()


#variables camembert
df_cheese <- df %>%
  select(
    "Part energie renouvelable(%)",
    "Part energie fossile(%)",
    "Part autres energies(%)",) %>%
  names()

  
#carte chloroplet
var_chl <- df %>% 
  select(-"Pays",-"Pays_fr", -"Annee",-"Croissance PIB(%)") %>%
  names()


#carte chloroplethe
map <- map_data("world")

# On a un nom différent dans les tableaux country et map pour la république tchèque
# On modifie map pour qu'ils aient la même valeur
map$region <- ifelse(map$region == "Czech Republic", "Czechia", map$region)

#pour tracer les autres pays européens
european_countries <- c(
  "Albania", "Andorra", "Belarus", "Bosnia and Herzegovina", 
  "Iceland", "Kosovo", "Liechtenstein", "Moldova", "Monaco", "Montenegro", "North Macedonia", 
  "Norway", "San Marino", "Serbia", 
  "Switzerland", "Ukraine", "UK", "Vatican"
)


# conserve que les valeurs des âys européen dans map
map_UE <- semi_join(map, df, by=c("region" ="Pays"))
#récupère les longitude/latitude des autres pays européens
map_EU_rest <- map%>%
  filter(region %in% european_countries)

merged = right_join(df, map_UE, by = c("Pays" = "region"), relationship = "many-to-many")
#met sous la même forme que le dataset les autres pays européens et remplace par 0 les valeurs manquantes
merged_Eu_rest = right_join(df, map_EU_rest, by = c("Pays" = "region"))
merged_Eu_rest[is.na(merged_Eu_rest)] <- -1


#texte conclusion
txt <- "La qualité et la quantité des données disponibles dans notre jeu de données nous permettent de poser une problématique pertinente : Y a-t-il une tendance énergétique dans les pays d'Europe au cours des 20 dernières années ? Celle-ci a-t-elle une quelconque corrélation avec le nombre d'habitants de ces pays, ainsi que leur PIB ou encore leurs émissions de CO2 ?
 
Nous avons réalisé plusieurs graphiques dans notre tableau de bord (dashboard) qui nous permettent d'établir des conclusions pour répondre à cette problématique.

Notre bar chart nous permet de visualiser, pour une année précise entre 2000 et 2020, la quantité des données que l'on définit en ordonnée pour tous les pays d'Europe. Par exemple, on remarque que, au cours des 20 dernières années, les seuls vrais producteurs d'énergie fossile sont l'Allemagne, l'Espagne, l'Italie et la Pologne. En ce qui concerne le nucléaire, seul la France en produit énormément, avec l'Allemagne loin derrière, et donc la production a nettement baissé au cours des dernières années. Pour ce qui est des énergies renouvelables, de nombreux pays se démarquent, mais on remarque une forte hausse dans toute l'Europe de la production de cette nouvelle forme d'énergie.

Sur un autre onglet, notre scatter plot nous permet d'observer plus clairement la formation de tendances au fil du temps. En effet, on remarque que les émissions de CO2 en Europe sont en quasi-constante baisse depuis 2005. On observe également que c'est à partir de cette époque que le PIB par habitant a commencé à croître de manière significative (malgré une croissance du PIB relativement stable) et que l'intensité énergétique a commencé à baisser.

Par ailleurs, sur notre onglet intitulé 'Courbe de tendance', on peut réaliser des observations en examinant spécifiquement la corrélation entre deux variables. Ce graphique nous permet, entre autres, de voir l'importance du PIB par habitant dans l'optique d'une potentielle transition énergétique, car bien que plus responsable pour la planète, les nouvelles technologies et sources d'énergie sont bien plus coûteuses que les sources plus traditionnelles.

Notre jeu de données met donc en avant le fait que la situation économique globale des habitants d'Europe s'est amélioré au cours des deux dernières décennies et que les énergies renouvelables commencent à se populariser de plus en plus, là ou le nucléaire et les énergies fossiles continuent lentement mais sûrement à être mises de côté."