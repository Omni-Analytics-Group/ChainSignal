## Loading Libraries
library(shiny)
library(shinydashboard)
library(httr)
library(jsonlite)
library(lubridate)
library(stringr)
library(dplyr)
library(tidyr)
library(DT)
library(shinyjs)

########################################################################
## Helper Functions
########################################################################
source("helperfuncs.R")
if(!file.exists("tasks.RDS")) saveRDS(data.frame(),"tasks.RDS")
chaindf <- get_chains(key="cqt_rQtBgtf4B9Y7wVJCGVGc9jqvcVXp")
chainlist <- as.list(chaindf$Slug)
names(chainlist) <- chaindf$Label
notifs <- list()
saveRDS(notifs,"notifs.RDS")
notifs <- reactiveFileReader(1000, NULL, "notifs.RDS", readRDS)
########################################################################
########################################################################


########################################################################
## Server Code
########################################################################
function(input, output, session) {

	########################################################################
	## Chain List
	########################################################################
	output$clist <- renderUI({ selectizeInput("uChain", label = h6("Select Chain"),choices = chainlist, selected = 1,multiple = FALSE) })
	########################################################################
	########################################################################


	########################################################################
	## Tracking List
	########################################################################
	tbatch <- reactiveValues(tasks = readRDS("tasks.RDS"))
	observeEvent(tbatch$tasks,{saveRDS(tbatch$tasks,"tasks.RDS")})

	## Add to Tracking
	observeEvent(input$uGo,{	
								## Add Fresh Task to Batch
								ctask <- data.frame(
													Chain = input$uChain,
													Address = input$uAdd
											)
								if(length(input$uType)==0)
								{
									sendSweetAlert(session = session,title = "Failed to Add",text = NULL,type = "error")
									return(NULL)
								}
								ctask$Alerts <- list(input$uType)
								tbatch$tasks <- rbind(tbatch$tasks,ctask)
								sendSweetAlert(session = session,title = "Task Added to Tracking",text = NULL,type = "success")
	})

	## Render Tasks table
	output$tasks <- renderDataTable({
										if(nrow(tbatch$tasks)==0) return(NULL)
										outtab <- tbatch$tasks
										outtab$Alerts <- sapply(outtab$Alerts,function(x) paste0(x,collapse=", "))
										datatable(
													outtab,
													options = list(
															scrollX = TRUE,
															paging = FALSE,
															bInfo = FALSE,
															ordering=FALSE,
															searching=FALSE
														),
												rownames= FALSE
										)
					})

	## If Remove Button 
	output$delBtnStatus <- reactive({nrow(tbatch$tasks)>0})
	outputOptions(output, "delBtnStatus", suspendWhenHidden = FALSE)

	## Removing Task from batch
	observeEvent(input$uNoGo,{
								if (!is.null(input$tasks_rows_selected))
								{
									tbatch$tasks <- tbatch$tasks[-as.numeric(input$tasks_rows_selected),]
									sendSweetAlert(session = session,title = "Tasks Removed from Tracking",text = NULL,type = "success")
								}
	})
	########################################################################
	########################################################################


	########################################################################
	## Notifications and Status
	########################################################################
	notbatch <- reactiveValues(posted = length(readRDS("notifs.RDS")))
	observe({
				notifdata <- notifs()
				if(length(notifdata)>notbatch$posted)
				{
					showNotification(HTML(notifdata[[notbatch$posted+1]]),type="message",duration=10)
					notbatch$posted <- notbatch$posted+1
				}
				if(length(notifdata)==0) notbatch$posted <- 0
	})
	########################################################################
	########################################################################
}
