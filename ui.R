## Loading Libraries
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(bslib)
library(DT)
library(shinyjs)
useSweetAlert()

fluidPage(theme = bs_theme(bootswatch = "sandstone"),

    ## Custom CSS
    tags$style("#uAdd {font-size:14px;height:50px;}"),
    tags$style(type='text/css', ".selectize-input { font-size: 16px;} .selectize-dropdown { font-size: 14px; }"),

sidebarLayout(

        ########################################################################
        ## Side Panel
        ########################################################################
        sidebarPanel(width=3,

            ## Logo
            tags$div(style = "text-align: center;", tags$img(src = "unified.png", height=60)),
            tags$div(style = "text-align: right;", tags$img(src = "covalent.png", height=50)),
            hr(),

            ## Label
            h3("ChainSignal",align="center"),

            ## Description
            fluidRow(column(12,h6("Your Web3 World, Telegram-Tapped!"),align = "center")),
            helpText("Track any web3 activity for a specific address across chosen chains and receive instant notifications on Telegram. Stay updated, stay informed."),
            hr(),

            ## Add Task UI
            uiOutput("clist"),
            textInput("uAdd", label = h6("Enter Wallet Address"), value = "0x89C51828427F70D77875C6747759fB17Ba10Ceb0", placeholder = "Wallet Address ...."),
            awesomeCheckboxGroup(inputId = "uType",label = h6("Alert Types"), choices = c("All Txs","ERC20 Txs","NFT Txs"),selected = "All Txs"),
            fluidRow(column(12,actionBttn("uGo", label = "Add to Tracking",icon = icon("file-circle-plus"), style = "material-flat",color = "success",block=TRUE)))
            # fluidRow(column(12,actionBttn("uGo", label = "Add to Tracking",width=200,color="success",style="simple"),align = "center"))
        ),
        ########################################################################
        ########################################################################


        ########################################################################
        ## Main Panel
        ########################################################################
        mainPanel(width=9,
            conditionalPanel(condition = "output.delBtnStatus",
                    fluidRow(column(12,
                        br(),
                        h4("Tracking List",align="center"),
                        dataTableOutput("tasks"),
                        br(),
                        actionBttn("uNoGo", label = "Remove Selected Tasks",icon = icon("trash"), style = "material-flat",color = "danger"),
                        align = "center"
                    ))
            ),
        ),

        ########################################################################
        ########################################################################
    )
)


