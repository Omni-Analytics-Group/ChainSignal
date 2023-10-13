## Load Libraries and helper functions
library(httr)
library(jsonlite)
library(telegram)
library(dplyr)
library(lubridate)
# setwd("~/Desktop/ChainSignal")
source("helperfuncs.R")

## Telegram Configuration
tbot_token <- "**********:***************************-*******"
tbot_channel <- "**********"
covkey <- "***_****************************"
bot <- TGBot$new(token = tbot_token)
bot$set_default_chat_id(tbot_channel)
notifs <- list()
if(!file.exists("tasks.RDS")) saveRDS(data.frame(),"tasks.RDS")
saveRDS(notifs,"notifs.RDS")

## Starting Dataset
tasks_start <- readRDS("tasks.RDS")
lookup <- data.frame()
if(nrow(tasks_start)>0)
{
	lookup <- unique(do.call(rbind,apply(tasks_start,1,tasks_parse,simplify=FALSE)))
	lookup$Block <- NA
	lookupbal <- list()
	for(idx in 1:nrow(lookup))
	{
		lookupbal[[idx]] <-  get_balance(lookup$Address[idx],lookup$Chain[idx],covkey)
		lookup$Block[idx] <- get_txs(lookup$Address[idx],lookup$Chain[idx],covkey)[[1]]$block_height
	}
}

## Continuous Loop to Add/Remove and Process Tasks
while(TRUE)
{
	########################################################################
	## Maintain Lookup Jobs
	########################################################################
	## Load Batch Data
	tasks_curr <- readRDS("tasks.RDS")
	if(!identical(tasks_start,tasks_curr))
	{
		lookup <- data.frame(Chain = character(), Address = character(), Block = character(), Txs = logical(), NFT = logical(), ERC20 = logical())
		if(nrow(tasks_curr)>0)
		{
			lookup <- unique(do.call(rbind,apply(tasks_curr,1,tasks_parse,simplify=FALSE)))
			lookup$Block <- NA
			for(idx in 1:nrow(lookup))
			{
				lookupbal[[idx]] <-  get_balance(lookup$Address[idx],lookup$Chain[idx],covkey)
				lookup$Block[idx] <- get_txs(lookup$Address[idx],lookup$Chain[idx],covkey)[[1]]$block_height
			}
		}
	}
	########################################################################
	########################################################################

	########################################################################
	## Process Lookup Jobs
	########################################################################
	if(nrow(lookup)>0)
	{
		for(idx in 1:1)#nrow(lookup))
		{
			## Fetch the current information
			currtxs <- get_txs(lookup$Address[idx],lookup$Chain[idx],covkey)
			cbal <- get_balance(lookup$Address[idx],lookup$Chain[idx],covkey)

			## Check and process if any new information
			currupdate <- match(lookup$Block[idx],sapply(currtxs,"[[",2))
			if(currupdate>1)
			{	
				## Each Tx one by one
				for(txidx in (currupdate-1):1)
				{
					## All Txs Alerts
					if(lookup$Txs[idx])
					{
						bot$sendMessage(paste0("🚨 Transaction Alert 🚨","\n\n","Chain : ",lookup$Chain[idx],"\n","Address : ",short_add(lookup$Address[idx]),"\n","Tx Hash : ",short_add(currtxs[[txidx]]$tx_hash),"\n\n🚨 Transaction Alert 🚨"))
						notifs <- c(notifs,paste0("🚨 Transaction Alert 🚨","<br>","Chain : ",lookup$Chain[idx],"<br>","Address : ",short_add(lookup$Address[idx]),"<br>","Tx Hash : ",short_add(currtxs[[txidx]]$tx_hash)))
						saveRDS(notifs,"notifs.RDS")
					}

					## Time to finish Database Management
					while(get_balancetime(lookup$Address[idx],lookup$Chain[idx],covkey) < as.numeric(as_datetime(currtxs[[txidx]]$block_signed_at)))
					{
						Sys.sleep(1)
						# message("Waiting for data to be indexed")
					}
					cbal <- get_balance(lookup$Address[idx],lookup$Chain[idx],covkey)

					## ERC20 Txs Alerts
					if(lookup$ERC20[idx])
					{
						otoks <- lookupbal[[idx]][lookupbal[[idx]]$Type!="nft" & !lookupbal[[idx]]$isNative,c(1,2,5)]
						ntoks <- cbal[cbal$Type!="nft" & !cbal$isNative,c(1,2,5)]
						ctoks <- suppressMessages(unique(rbind(anti_join(otoks, ntoks)[,1:2],anti_join(ntoks, otoks)[,1:2])))
						if(nrow(ctoks)>0)
						{
							toktxs <- list()
							for(eidx in 1:nrow(ctoks))
							erc20txs <- get_erc20Txs(lookup$Address[idx],lookup$Chain[idx],covkey,ctoks$TokenAddress[eidx],currtxs[[txidx]]$block_height,currtxs[[txidx]]$block_height)
							if(length(erc20txs)>0)
							{
								bot$sendMessage(paste0("💰 Token Transfer Alert 💰","\n\n","Chain : ",lookup$Chain[idx],"\n","Address : ",short_add(lookup$Address[idx]),"\n",paste0(sapply(erc20txs,function(x) paste0(sapply(x$transfers,erc20tfr_parse),collapse="\n")),collapse="\n"),"\n\n💰 Token Transfer Alert 💰"))
								notifs <- c(notifs,paste0("💰 Token Transfer Alert 💰","<br>","Chain : ",lookup$Chain[idx],"<br>","Address : ",short_add(lookup$Address[idx]),"<br>",paste0(sapply(erc20txs,function(x) paste0(sapply(x$transfers,erc20tfr_parse),collapse="<br>")),collapse="<br>")))
								saveRDS(notifs,"notifs.RDS")
							}
						}
					}

					## NFT Txs
					if(lookup$NFT[idx])
					{
						otoks <- lookupbal[[idx]][lookupbal[[idx]]$Type=="nft",c(1,2,5)]
						ntoks <- cbal[cbal$Type=="nft",c(1,2,5)]
						ctoks <- suppressMessages(unique(rbind(anti_join(otoks, ntoks)[,1:2],anti_join(ntoks, otoks)[,1:2])))
						if(nrow(ctoks)>0)
						{
							toktxs <- list()
							for(eidx in 1:nrow(ctoks))
							nfttxs <- get_erc20Txs(lookup$Address[idx],lookup$Chain[idx],covkey,ctoks$TokenAddress[eidx],currtxs[[txidx]]$block_height,currtxs[[txidx]]$block_height)
							if(length(nfttxs)>0)
							{
								bot$sendMessage(paste0("🖼 NFT Transfer Alert 🖼️","\n\n","Chain : ",lookup$Chain[idx],"\n","Address : ",short_add(lookup$Address[idx]),"\n",paste0(sapply(nfttxs,function(x) paste0(sapply(x$transfers,nfttfr_parse),collapse="\n")),collapse="\n"),"\n\n🖼 NFT Transfer Alert 🖼️"))
								notifs <- c(notifs,paste0("🖼 NFT Transfer Alert 🖼️","<br>","Chain : ",lookup$Chain[idx],"<br>","Address : ",short_add(lookup$Address[idx]),"<br>",paste0(sapply(nfttxs,function(x) paste0(sapply(x$transfers,nfttfr_parse),collapse="<br>")),collapse="<br>")))
								saveRDS(notifs,"notifs.RDS")
							}
						}
					}
				}

				## Update the lookup database
				lookup$Block[idx] <- currtxs[[1]]$block_height
			}

			## Update the balance database
			lookupbal[[idx]] <- cbal

			## Take Rest
			Sys.sleep(1)
		}
	}
	########################################################################
	########################################################################
}