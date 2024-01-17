function(input, output){
  
  # titre max  
  output$titre1 <- renderText(
    paste(ifelse(input$var4 == "1", "", input$var4), " pays avec le plus de: ", input$var2)
  )
  
  # titre min
  output$titre2 <- renderText(
    paste(ifelse(input$var4 == "1", "", input$var4), " pays avec le moins de: ", input$var2)
  ) 
  
  #Structure
  output$structure <- renderPrint(
    df %>%
      str()
  )
  
  #Summary
  output$summary <- renderPrint(
    df %>%
      summary()
  )
  
  #data
  output$dataT <- renderDataTable(
    df, options = list(scrollX = TRUE)
  )
  
  # 5 plus fortes valeurs
  output$top5 <- renderTable({
    
    df %>% 
      filter(Annee == input$var3) %>%
      select(Pays_fr, input$var2) %>% 
      arrange(desc(get(input$var2))) %>% 
      head(as.integer(input$var4))
    
  })
  
  # 5 plus faibles valeurs
  output$low5 <- renderTable({
    
    df %>% 
      filter(Annee == input$var3) %>%
      select(Pays_fr, input$var2) %>% 
      arrange(get(input$var2)) %>% 
      head(as.integer(input$var4))
    
    
  })
  
  
  #barplot
  output$bar <- renderPlotly({
    p <- df %>%
      filter(Annee == input$var5) %>%
      ggplot(aes(x=Pays_fr, y=get(input$var6), text = paste("Pays: ", Pays_fr ,"\n",input$var6, ": ", get(input$var6))))+
      geom_bar(stat = "identity",  fill = "#0487B5")+
      theme_minimal()+
      labs(title = paste(input$var6, " pour chaque pays de l'Union Européenne en ", input$var5 ,":"), 
           x = "Pays", y = input$var6)+
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p , tooltip="text")
  })
  
  
  #Scatter plot
  output$scatter <- renderPlotly({
  p <- df %>%
    filter(Pays_fr == input$var7) %>%
    ggplot(aes(x = Annee, y = get(input$var8) )) +
    geom_line( color= "#0487B5") +  
    theme_minimal() +
    labs(title = paste(input$var8, " pour les pays de l'Union Européenne depuis les années 2000:"),
         x = "Année", y = input$var8) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  ggplotly(p, tooltip = "text")
})

  
  

  
  
  
  #distribution
  output$dist <- renderPlotly({
    p1 = df %>% 
      plot_ly() %>% 
      add_histogram(x=~get(input$var1)) %>% 
      layout(xaxis = list(title = input$var1))
    
    
    p2 = df %>%
      plot_ly() %>%
      add_boxplot(x=~get(input$var1)) %>% 
      layout(yaxis = list(showticklabels = F))
    
    # stacking the plots on top of each other
    subplot(p2, p1, nrows = 2, shareX = TRUE) %>%
      hide_legend() %>% 
      layout(title = paste("Histogramme et Boxplot représentant la distribution de la variable: ", input$var1),
        yaxis = list(title="Frequency"))
  })
  
  #matrice de corrélation
  output$corr <- renderPlot({
    
      p <- ggcorrplot(mat, hc.order = TRUE, type = "upper",
                 lab = TRUE, outline.col = "white",
                 ggtheme = ggplot2::theme_light(),
                 colors = c("#6D9EC1", "white", "#E46726"),
                 lab_size = 3)
      
      p + ggtitle("Matrice représentant les dépendances entre les différentes variables de notre dataset:")
    })
  
  #scatter plot
  output$scat <- renderPlotly({
    p <- df %>%
      ggplot(aes(x=get(input$var11), y=get(input$var12))) +
      geom_point() +
      geom_smooth(method=get(input$fit)) +
      theme_minimal() +
      labs(title = paste("Graphique représentant l'", input$var11, " en fonction de l'", input$var12, ":"),
           x = input$var11, y = input$var12)
    
    ggplotly(p, tooltip = "text")
  })
  
  
  #camembert
  output$cheese <- renderPlotly({
    filtered_df <- df %>%
      filter(Annee == input$var9, Pays_fr == input$var10)
    
    filtered_df <- filtered_df %>% 
      select(Pays_fr, `Part energie renouvelable(%)`, `Part energie fossile(%)`, `Part autres energies(%)`) %>%
      pivot_longer(-Pays_fr, names_to = "Energie", values_to = "Pourcentage")
    
    p <- plot_ly(data = filtered_df, labels = ~Energie, values = ~Pourcentage,
                 type = 'pie', 
                 textinfo = 'percent')
    p <- p %>% add_trace(marker = list(colors = c("blue", "green", "red")))  # Vous pouvez changer les couleurs
    
    
    p %>% layout(title = paste("Répartition des énergies pour ", input$var10, " en ", input$var9), legend = list(x = 1, y = 0.5,font = list(size = 16)))
  })
    
  
  #carte chloroplete
  output$map <- renderPlotly({
    p <- merged %>% 
      filter(Annee == input$var14) %>%
      rbind(merged_Eu_rest) %>% # ajouter les valeurs des autres pays européens pour les afficher sur la map
      ggplot(aes(x=long, y=lat, fill=get(input$var13), group = group, text = paste("Pays: ", Pays_fr, "\n", input$var13, ": ", get(input$var13)))) +
      geom_polygon(color="black", linewidth=0.4) +
      scale_fill_gradient(low="white", high="#001B3A", name = input$var13) +
      theme_void() +
      labs(title= paste("Carte chloroplethe de l'Union Européenne en ", input$var14, " en fonction de: ", input$var13)) + 
      theme(panel.grid = element_blank(), legend.position = c(0.2, 0.1)) +
      coord_cartesian(xlim = c(-30, 40), ylim = c(35, 75))
    
    ggplotly(p, tooltip = "text")
  })
  
  
}