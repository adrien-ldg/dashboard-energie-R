
dashboardPage(
  dashboardHeader(title = "Projet: Evolution de la répartion des énergies chez les pays de l'UE et différentes conséquences.",
                  titleWidth = "900px"
                  ),
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      
      menuItem("Dataset", tabName = "data", icon = icon("database")),
      menuItem("Graphiques", tabName = "graph", icon=icon("chart-line")),
      
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'dist'", selectInput(inputId = "var1" , 
                       label ="Selectioner une variable:" , choices = var_quant_dist, selected = "Electricite d'origine fossile(TWh)")),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'max_min' ", selectInput(inputId = "var2" , label ="Selectioner une variable:" ,
                       choices = var_bar, selected = "Electricite de l'energie fossile(TWh)")),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'max_min' ", sliderInput(inputId = "var3" , label ="Selectioner une année:" , min=2000, max=2019, step=1, value = 2000, animate = TRUE)),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'max_min' ", sliderInput(inputId = "var4" , label ="Selectioner une valeur:" , min=1, max=14, step=1, value=5)),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'bar'", sliderInput(inputId = "var5" , label ="Selectioner une année:" , min=2000, max=2019, step=1, value=2000, animate = TRUE)),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'bar'", selectInput(inputId = "var6" , label ="Selectioner une variable:", 
                      choices = var_bar, selected = "Electricite d'origine fossile(TWh)")),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'hist'", selectInput(inputId = "var7" , label ="Selectioner un pays:" , choices = country)),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'scatter'", selectInput(inputId = "var8" , label ="Selectioner une variable:", 
                     choices = var_hist, selected = "Electricite d'origine fossile(TWh)")),
      
      
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'cheese'", sliderInput(inputId = "var9" , label ="Selectionner une année:" , min=2000, max=2019, step=1, value = 2000, animate = TRUE)),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'cheese'", selectInput(inputId = "var10" , label ="Selectioner un pays:" , choices = country)),
      
      
      
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'scat'", selectInput(inputId = "var11" , label ="Choisissez X:" , 
                      choices = df_scat_y, selected = "Emissions CO2(kt)")),
      conditionalPanel("input.sidebar == 'graph' && input.t2 == 'scat'", selectInput(inputId = "var12" , label ="Choisissez Y:", 
                      choices = df_scat_x, selected = "Electricite d'origine nucleaire(TWh)")),
      
      menuItem("Map", tabName = "map", icon=icon("map")),
      conditionalPanel("input.sidebar == 'map' && input.t3 == 'map'", selectInput(inputId = "var13" , label ="Choisissez une variable:", 
                      choices = var_chl, selected = "Electricite de l'energie fossile(TWh)")),
      conditionalPanel("input.sidebar == 'map' && input.t3 == 'map'", sliderInput(inputId = "var14" , label ="Selectioner une année:" , min=2000, max=2019, step=1, value=2000, animate = TRUE)),
      
      menuItem("Conclusion", tabName = "ccl", icon=icon("file-text"))
    )
  ),
  dashboardBody(
    tabItems(
      
      
      tabItem(tabName = "data",
              
          tabsetPanel(id="t1",
             tabPanel(title=tags$strong("Présentation"), id = "pres", icon = icon("info"),
                      fluidRow(
                        column(width = 8, tags$img(src="https://fr.cdn.v5.futura-sciences.com/buildsv6/images/wide1920/2/e/1/2e13386c85_100685_01-intro-642.jpg", width =800 , height = 400),
                               tags$br() , align = "center"),
                        column(width = 4, tags$br() ,
                               tags$p("À l'aide de ce jeu de données, notre objectif est d'analyser et de visualiser comment la production d'énergie est répartie au sein des pays de l'Union Européenne sur une période allant de l'année 2000 à 2019. Nous souhaitons comprendre comment cette répartition de la production d'énergie a évolué au fil du temps et quel impact elle a eu sur les économies des pays membres de l'Union Européenne, ainsi que sur la densité de leur population. En examinant les tendances de production d'énergie au sein de l'UE, nous cherchons à identifier des corrélations potentielles entre la production d'énergie, la croissance économique et la densité de la population, et à mieux comprendre les défis liés à l'utilisation de l'énergie au sein de cette région géographique clé.")
                        ))
            ), #attention au chemin d'accès de l'image
             tabPanel(title=tags$strong("Data"), id = "dataT", icon = icon("table"), dataTableOutput("dataT")),
             tabPanel(title=tags$strong("Structure"), id="structure", icon = icon("uncharted"), verbatimTextOutput("structure")),
             tabPanel(title=tags$strong("Résumé des données"), id="summary", icon = icon("chart-bar"), verbatimTextOutput("summary"))
          )
        
      ),
      
      tabItem(tabName = "graph",
              
              tabsetPanel(id="t2",
                tabPanel(tags$strong("Courbe de distribution"), value="dist", plotlyOutput("dist")),
                tabPanel(tags$strong("Barchart"), value="bar", plotlyOutput("bar")),
                tabPanel(tags$strong("Scatter plot"), value="scatter", plotlyOutput("scatter")),
                tabPanel(tags$strong("Courbe de tendance"), value="scat",
                         radioButtons(inputId ="fit" , label = "Sélectionner la méthode de lissage:" , choices = c("loess", "lm"), selected = "lm" , inline = TRUE),
                         plotlyOutput("scat")),
                
                tabPanel(tags$strong("Evolution de la production d'électricité"), value="cheese", plotlyOutput("cheese")),
                
                tabPanel(tags$strong("Max-min"), value="max_min",
                         fluidRow(tags$div(align="center", box(tableOutput("top5"), title = textOutput("titre1") , collapsible = TRUE, status = "primary",  collapsed = TRUE, solidHeader = TRUE)),
                                  tags$div(align="center", box(tableOutput("low5"), title = textOutput("titre2") , collapsible = TRUE, status = "primary",  collapsed = TRUE, solidHeader = TRUE))
                                  
                         ),
                ),
                
                tabPanel(tags$strong("Matrice de corrélation"), value="corr", 
                         plotOutput("corr"))
              ), 
              
      ),
      
      tabItem(tabName = "map",
              tabsetPanel(id="t3",
                tabPanel(tags$strong("Carte chloroplete"), value="map", plotlyOutput("map"), width=12)
              )
      ),
      
      tabItem(tabName = "ccl",
              h2("Conclusion:"), # Titre
              div(
                style = "background-color: #f0f0f0; padding: 10px; border-radius: 5px;", 
                p(style = "word-wrap: break-word;",
                  txt),
              )
      )
      
    )
  )
)