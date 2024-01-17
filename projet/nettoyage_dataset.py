import importlib

# Nom du module à vérifier
module_name = ["pandas", "numpy"]

for i in module_name:
# Vérifier si le module est déjà installé
  try:
      importlib.import_module(i)
      print(f"{i} est déjà installé.")
  except ImportError:
      print(f"{i} n'est pas installé. Installation en cours...")
      
      # Vous pouvez utiliser pip pour installer le module pandas
      import subprocess
      subprocess.check_call(["python", "-m", "pip", "install", i])
  
      # Vérifier à nouveau si le module est installé
      try:
          importlib.import_module(i)
          print(f"{i} a été installé avec succès.")
      except ImportError:
          print(f"Impossible d'installer {i}. Veuillez l'installer manuellement.")



import pandas as pd
import numpy as np

df = pd.read_csv(r"global-data-on-sustainable-energy.csv")


df['Density\\n(P/Km2)'] = pd.to_numeric(df['Density\\n(P/Km2)'], errors='coerce', downcast='integer')

df2 = df.query("Year < 2020") #on supprime don les données de l'année 2020



#les deux dernières colonnes ne nous intéressent pas 
df3 = df2.loc[:, ['Entity', 'Year', 'Access to electricity (% of population)',
    'Access to clean fuels for cooking',
    'Renewable energy share in the total final energy consumption (%)',
    'Electricity from fossil fuels (TWh)', 'Electricity from nuclear (TWh)',
    'Electricity from renewables (TWh)',
    'Low-carbon electricity (% electricity)',
    'Primary energy consumption per capita (kWh/person)',
    'Energy intensity level of primary energy (MJ/$2017 PPP GDP)',
    'Value_co2_emissions_kt_by_country',
    'gdp_growth', 'gdp_per_capita', 'Density\\n(P/Km2)', 'Land Area(Km2)']]

data_qual = df.select_dtypes(include = ["int64", "float64"]).columns #colonne quantitative
data_quant = df.select_dtypes(include = ["object"]).columns   #colonne quanlitative

#On va se concentrer sur les pays de l'union européenne
a = ["Germany", "Austria", "Belgium", "Bulgaria", "Cyprus", "Croatia", "Denmark", "Spain", "Estonia",
    "Finland", "France", "Greece", "Hungary", "Ireland", "Italy", "Lithuania", "Latvia", "Luxembourg",
    "Malta", "Netherlands", "Poland", "Portugal", "Czechia", "Romania", "Slovakia", "Slovenia",
    "Sweden"]

df_UE = df3[df3["Entity"].isin(a)]
# On va remplacer les valeurs manquantes par un 0 
df_UE = df_UE.fillna(0)

# On va donc remplacer par les bonnes valeurs pour rendre notre analyse plus fiable
#lien donnéees: https://www.populationpyramid.net/fr/malte/2022/

pop_Malte = {2000 : 399211, 2001 : 402151, 2002 : 404698, 2003 : 406919, 2004 : 408798, 2005 : 410207,
            2006 : 411197, 2007 : 412081, 2008 : 413401, 2009 : 415500, 2010 : 418755, 2011 : 423571,
            2012 : 429907, 2013 : 437525, 2014 : 446441, 2015 : 456578, 2016 : 467705, 2017 : 479497, 
            2018 : 491586, 2019 : 503634}

for year, population in pop_Malte.items():
    condition = (df_UE["Entity"] == "Malta") & (df_UE["Year"] == year)
    df_UE.loc[condition, "Population"] = population
    df_UE.loc[condition, "Density\\n(P/Km2)"] = population/ df_UE.loc[condition, "Land Area(Km2)"]



#Dans notre dataset, on a la quantité d'éléctricité produit grâce aux énergies renoublables, nuclèaires et fossiles
#Mais, il semble plus intéressant de connaitre la quantité d'éléctricité produit par personne. On va donc créée trois colonnes
df_UE["Population"] = df_UE["Density\\n(P/Km2)"]*df_UE["Land Area(Km2)"]
df_UE["Electricity_from_Fossil_Fuels_per_capita(GWh/P)"] = df_UE["Electricity from fossil fuels (TWh)"]* 10**6 / df_UE["Population"]
df_UE["Electricity_from_Nuclear(GWh/P)"] = df_UE["Electricity from nuclear (TWh)"]* 10**6 / df_UE["Population"]
df_UE["Electricity_from_Renewables_per_capita(GWh/P)"] = df_UE["Electricity from renewables (TWh)"]* 10**6 / df_UE["Population"]
df_UE['Part energie fossile(%)'] = np.where(df_UE["Low-carbon electricity (% electricity)"] != 0,
                                            100 - df_UE["Low-carbon electricity (% electricity)"],
                                            100 - df_UE['Renewable energy share in the total final energy consumption (%)'])

df_UE['Part autres energies(%)'] = np.where(df_UE["Low-carbon electricity (% electricity)"] != 0,
                                                100 - df_UE["Part energie fossile(%)"] - df_UE["Renewable energy share in the total final energy consumption (%)"],
                                                0)
# On remarque que les colonnes Access to electricity (% of population) et Access to clean fuels (% of population) 
#valent toujours 100%. Il n'est donc pas intéressant de les garder
df_UE = df_UE.drop(['Access to electricity (% of population)','Low-carbon electricity (% electricity)', 'Access to clean fuels for cooking','Primary energy consumption per capita (kWh/person)'], axis=1)



df_UE.columns = [
    "Pays",
    "Annee",
    "Part energie renouvelable(%)",
    "Electricite d'origine fossile(TWh)",
    "Electricite d'origine nucleaire(TWh)",
    "Electricite d'origine renouvelable(TWh)",
    "Intensite energetique(MJ/$2017 PIB PPA)",
    "Emissions CO2(kt)",
    "Croissance PIB(%)",
    "PIB/habitant($)",
    "Densite(P/Km2)",
    "Superficie(Km2)",
    "Population",
    "Electricite d'origine fossile / hab(KWh/pers)",
    "Electricite d'origine nucleaire / hab(KWh/pers)",
    "Electricite d'origine renouvelable / hab(KWh/pers)",
    "Part energie fossile(%)",
    "Part autres energies(%)"]

correspondance_pays = {
    "Germany": "Allemagne",
    "Austria": "Autriche",
    "Belgium": "Belgique",
    "Bulgaria": "Bulgarie",
    "Cyprus": "Chypre",
    "Croatia": "Croatie",
    "Denmark": "Danemark",
    "Spain": "Espagne",
    "Estonia": "Estonie",
    "Finland": "Finlande",
    "France": "France",
    "Greece": "Grèce",
    "Hungary": "Hongrie",
    "Ireland": "Irlande",
    "Italy": "Italie",
    "Lithuania": "Lituanie",
    "Latvia": "Lettonie",
    "Luxembourg": "Luxembourg",
    "Malta": "Malte",
    "Netherlands": "Pays-Bas",
    "Poland": "Pologne",
    "Portugal": "Portugal",
    "Czechia": "République tchèque",
    "Romania": "Roumanie",
    "Slovakia": "Slovaquie",
    "Slovenia": "Slovénie",
    "Sweden": "Suède"
}

df_UE["Pays_fr"] = df_UE["Pays"].map(correspondance_pays)


#on modifie l'ordre des colonnes pour que le dataset soit plus lisible
new_column_order = [
    "Pays",
    "Pays_fr",
    "Annee",
    "Population",
    "Densite(P/Km2)",
    "Superficie(Km2)",
    "Electricite d'origine fossile(TWh)",
    "Electricite d'origine nucleaire(TWh)",
    "Electricite d'origine renouvelable(TWh)",
    "Electricite d'origine fossile / hab(KWh/pers)",
    "Electricite d'origine nucleaire / hab(KWh/pers)",
    "Electricite d'origine renouvelable / hab(KWh/pers)",
    "Part energie renouvelable(%)",
    "Part energie fossile(%)",
    "Part autres energies(%)",
    "Intensite energetique(MJ/$2017 PIB PPA)",
    "Emissions CO2(kt)",
    "Croissance PIB(%)",
    "PIB/habitant($)"
]
df_UE= df_UE[new_column_order]


df_UE.to_csv("repartition_energie_UE_cleaned.csv", index=False)
