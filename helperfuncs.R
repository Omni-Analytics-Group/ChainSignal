## Load Libraries and helper functions
library(httr)
library(jsonlite)
library(lubridate)

## Get List of Chains Supported
get_chains <- function(key)
{
	url <- "https://api.covalenthq.com/v1/chains/"
	resp <- GET(url,authenticate(key,""))
	chains <- content(resp)$data$items
	chaindf <- data.frame(
							Slug = sapply(chains,function(x) x$name),
							Id = sapply(chains,function(x) x$chain_id),
							isTestnet = sapply(chains,function(x) x$is_testnet),
							Label = sapply(chains,function(x) x$label),
							Category = sapply(chains,function(x) x$category_label),
							isAppchain = sapply(chains,function(x) x$is_appchain)
				)
	return(chaindf)
}

## Define Function to Get Balance
get_balance <- function(wall,chain,key)
{
	Sys.sleep(.25)
	url <- paste0(
					"https://api.covalenthq.com/v1/",
					chain,
					"/address/",
					wall,
					"/balances_v2/?nft=true&no-nft-fetch=false&no-spam=false&no-nft-asset-metadata=false"
			)
	resp <- GET(url,authenticate(key,""))
	toks <- content(resp)$data$items
	tokdf <- data.frame(
							Token = sapply(toks,function(x) ifelse(is.null(x$contract_ticker_symbol),NA,x$contract_ticker_symbol)),
							TokenAddress = sapply(toks,function(x) x$contract_address),
							isNative = sapply(toks,function(x) x$native_token),
							Type = sapply(toks,function(x) x$type),
							Balance = sapply(toks,function(x) as.numeric(x$balance)/10^x$contract_decimals),
							Value = sapply(toks,function(x) ifelse(is.null(x$quote),0,round(x$quote)))
				)
	return(tokdf)
}
get_balancetime <- function(wall,chain,key)
{
	Sys.sleep(.25)
	url <- paste0(
					"https://api.covalenthq.com/v1/",
					chain,
					"/address/",
					wall,
					"/balances_v2/?nft=true&no-nft-fetch=false&no-spam=false&no-nft-asset-metadata=false"
			)
	resp <- GET(url,authenticate(key,""))
	as.numeric(as_datetime(content(resp)$data$updated_at))
}


## Define Function to Get Txs
get_txs <- function(wall,chain,key)
{
	Sys.sleep(.25)
	url <- paste0(
					"https://api.covalenthq.com/v1/",
					chain,
					"/address/",
					wall,
					"/transactions_v3/?no-logs=true&block-signed-at-asc=false"
			)
	resp <- GET(url,authenticate(key,""))
	txs <- content(resp)$data$items
}

## Define Function to Get ERC20 Txs
get_erc20Txs <- function(wall,chain,key,erc20,sb,eb)
{
	Sys.sleep(.25)
	url <- paste0(
					"https://api.covalenthq.com/v1/",
					chain,
					"/address/",
					wall,
					"/transfers_v2/?starting-block=",
					sb,
					"&ending-block=",
					eb,
					"&contract-address=",
					erc20
			)
	resp <- GET(url,authenticate(key,""))
	txs <- content(resp)$data$items
	return(txs)
}

## Tasks Lookup Parse
tasks_parse <- function(x)
{
	ptask <- data.frame(Chain = x$Chain, Address = x$Address)
	ptask$Txs <- "All Txs" %in% x$Alerts
	ptask$NFT <- "ERC20 Txs" %in% x$Alerts
	ptask$ERC20 <- "NFT Txs" %in% x$Alerts
	ptask <- unique(ptask)
	return(ptask)
}

## Parse ERC20 Transfer
erc20tfr_parse <- function(x)
{
	paste0(
			ifelse(x$transfer_type=="IN","Received ","Sent "),
			as.numeric(x$delta)/10^x$contract_decimals,
			" ",
			x$contract_ticker_symbol
			# " (",vshort_add(x$contract_address),")"
	)
}

## Parse NFT Transfer
nfttfr_parse <- function(x)
{
	paste0(
			ifelse(x$transfer_type=="IN","Received 1 ","Sent 1 "),
			x$contract_ticker_symbol
			# " (",vshort_add(x$contract_address),")",
	)
}

## Short Address
short_add <- function(wall) paste0(c(head(strsplit(wall,"")[[1]]),rep(".",3),tail(strsplit(wall,"")[[1]])),collapse="")
vshort_add <- function(wall) paste0(c(head(strsplit(wall,"")[[1]],4),rep(".",2),tail(strsplit(wall,"")[[1]],3)),collapse="")
