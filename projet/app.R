# Charger les fichiers UI, Server et Global
source("global.R")
source("ui.R")
source("server.R")

# Créer et lancer l'application Shiny
shinyApp(ui = ui, server = server)
