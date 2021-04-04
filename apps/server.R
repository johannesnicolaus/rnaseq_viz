#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

options(shiny.maxRequestSize=30*1024^2) 

# source("../functions/functions.R")

sort_df_filter <- function(df, metadata, iden = 3){
  # pivot longer based on identifier
  df_combined <- df %>% 
    pivot_longer(cols = (iden+1):length(.), names_to = "id") %>%
    left_join(metadata %>% rename(id = "id"))
  
  return(df_combined)
  
}


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  require(tidyverse)
  require(plotly) 
  
  
  output$contents <- renderTable({

    inFile <- input$file_input_md
    
    if (is.null(input$file_input_md))
      return(NULL)  
    
    read_csv(inFile$datapath)
  }, align = "c", width = "100%")
  
  # print table dimensions
  output$tbl_dims <- renderText({ 
    inFile <- input$file_input_md
    
    if (is.null(inFile))
      return(NULL)
    
    csvfile <- read_csv(inFile$datapath)
    
    paste("Number of samples:" , dim(csvfile)[1])
  })
  


# get datasets ------------------------------------------------------------

output$dataset_select <- renderUI({
  # If missing input, return to avoid error later in function
  if(is.null(input$file_input_md))
    return()

  # Get the data set with the appropriate name
  dat <- read_csv(input$file_input_md$datapath)
  dat_dataset <- dat$dataset %>% unique()

  # Create the checkboxes and select them all by default
  checkboxGroupInput("dataset", "Choose dataset",
                     choices  = dat_dataset,
                     selected = dat_dataset)
})


# get genes ---------------------------------------------------------------

  output$gene_select_1 <- renderUI({
    # If missing input, return to avoid error later in function
    if(is.null(input$file_input_gex))
      return()
    
    # Get the data set with the appropriate name
    dat <- read_csv(input$file_input_gex$datapath)
    dat_gene <- dat$external_gene_name %>% unique()
    
    # Create the checkboxes and select them all by default
    selectInput("gene_select", h4("Gene to display"),
                       choices  = dat_gene,
                       selected = "IL6")
  })

# x axis and color based on colnames of metadata -------------------------------------------------

output$xaxis_select <- renderUI({
  # If missing input, return to avoid error later in function
  if(is.null(input$file_input_md))
    return()
  
  # Get the data set with the appropriate name
  dat <- read_csv(input$file_input_md$datapath)
  dat_xaxis <- colnames(dat)
  
  # Create the checkboxes and select them all by default
  selectInput("xaxis", "Choose x-axis",
                     choices  = dat_xaxis,
              selected = dat_xaxis[2])
})
  
  
  output$color_select <- renderUI({
    # If missing input, return to avoid error later in function
    if(is.null(input$file_input_md))
      return()
    
    # Get the data set with the appropriate name
    dat <- read_csv(input$file_input_md$datapath)
    dat_xaxis <- colnames(dat)
    
    # Create the checkboxes and select them all by default
    selectInput("color", "Choose which data to color group",
                choices  = dat_xaxis,
                selected = dat_xaxis[2])
  })  

# plot --------------------------------------------------------------------

  output$plot <- renderPlotly({
    # read csv files
    if (is.null(input$file_input_gex))
      return(NULL)

    if (is.null(input$file_input_md))
      return(NULL)      

    gex_df <- input$file_input_gex
    md_df <- input$file_input_md
    
    md_df <- read_csv(md_df$datapath)
    gex_df <- read_csv(gex_df$datapath)
    
    # combine to one column
    md_df_1 <- md_df
    md_df_1[] <- Map(paste, names(md_df), md_df, sep = ": ") 
    
    md_df_1 <- md_df_1 %>% unite("combined_md", 1:input$metadata_hover_data, remove = F, sep = "<br>")

    md_df$combined_md <- md_df_1$combined_md
    
    # combine dataframe
    combined_df <- sort_df_filter(gex_df, md_df, iden = input$id_columns)    

    # perform filtering
    combined_df <- combined_df %>% filter(external_gene_name == input$gene_select)
    
    combined_df <- combined_df %>% filter(dataset %in% input$dataset)    
    
    # perform transformation
    if (input$logfunc_data == "log2_1") {
      combined_df <- combined_df %>% mutate(value = log2(value+1))
    }
    
    # plot
    fig <- ggplot(combined_df, aes_string(x = input$xaxis, 
                                   y = "value", 
                                   color = input$color,
                                   combined_md = "combined_md"
                                   )) + 
            geom_violin(aes_string(x = input$xaxis, 
                                   y = "value", 
                                   color = input$color), inherit.aes = F) + 
            geom_jitter(width = input$jitterwidth_data, height = 0) +
            cowplot::theme_cowplot(input$textsize_data)
    
    print(ggplotly(fig, tooltip = c("combined_md")))
    
    
    
  }
  

  )  
  
  

})

