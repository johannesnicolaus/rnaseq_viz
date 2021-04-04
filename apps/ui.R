#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)



# fileinput
file_input_expression <- fileInput("file_input_gex", "Choose csv file of gene expression",
                        accept = c(
                          "text/csv",
                          "text/comma-separated-values,text/plain",
                          ".csv")
)

file_input_metadata <- fileInput("file_input_md", "Choose csv file of metadata",
                        accept = c(
                          "text/csv",
                          "text/comma-separated-values,text/plain",
                          ".csv")
)


# logfunc
logfunc <- radioButtons("logfunc_data", h4("Data transformation method"), 
                        choices = list("log2(n+1)" = "log2_1",
                                       "none" = "none"), 
                        selected = "none")



# jitter width
jitterwidth <- sliderInput("jitterwidth_data", "Jitter width",
                           min = 0, max = 1, value = c(0.1))

# dodge width
dodgewidth <- sliderInput("dodgewidth_data", "Jitter width",
                           min = 0, max = 1, value = c(0.1))

# text size
textsize <- sliderInput("textsize_data", "Text size",
                           min = 1, max = 25, value = c(15))


# metadata to show on hover
metadata_hover <- sliderInput("metadata_hover_data", "Metadata to show upon hover",
                        min = 1, max = 25, value = c(12))

# non-value column
id_column <- numericInput("id_columns", h4("Non-value columns"), value = 3, min = 1, max = NA, step = 1)

# gene
# gene_selection <- textInput("gene_select", h4("Gene to display"), 
#                             value = "IL6")  

# gene
gene_selection <- uiOutput("gene_select_1")  


# gene_selection <- uiOutput("gene_select")

choose_dataset <- uiOutput("dataset_select")

choose_xaxis <- uiOutput("xaxis_select")

choose_color <- uiOutput("color_select")

metadata_1 %>% colnames()
# Define UI 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Visualization of gene expression levels"),
  
  sidebarPanel(
    file_input_expression,
    file_input_metadata,
    choose_dataset,
    choose_xaxis,
    choose_color,
    id_column,
    gene_selection,
    logfunc,
    jitterwidth,
    # dodgewidth,
    metadata_hover,
    textsize
    
  ),
  
  mainPanel(plotlyOutput("plot", height = "600px"),
            textOutput("tbl_dims"),
            div(style="height:600px; overflow:scroll; align:text-center",
                tableOutput("contents")
            )
  )
))