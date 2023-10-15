# ChainSignal
Your Web3 World, Telegram-Tapped!

## [App Walkthrough on YouTube](https://www.youtube.com/watch?v=Lioy-HFxiwQ) <<< Click Here

<hr>

### Walkthrough

#### 1. Open R and install the requirements using

```
install.packages("shiny")
install.packages("shinydashboard")
install.packages("shinycssloaders")
install.packages("shinyWidgets")
install.packages("shinyjs")
install.packages("telegram")
install.packages("httr")
install.packages("tidyr")
install.packages("lubridate")
install.packages("DT")
```

#### 2. Clone this repo and set the R path to the repo.

```
setwd("~/Desktop/ChainSignal)
```

#### 3. Setup Telegram Bot Credentials following and put them in `processBatch.R` file

```
tbot_token <- "**********:***************************-*******"
tbot_channel <- "**********"
```

<img src="www/telegram.png" align="center"/>
<div align="center">R Telegram Configuration</div>
<br>

#### 4. [Setup Covalent Unified API Key and put in `processBatch.R` file](https://www.covalenthq.com/docs/unified-api/) <<< Click Here

```
covkey <- "***_****************************"
```

#### 5. Run the Background Job

```
Rscript processBatch.R
```

<img src="www/processBatch.png" align="center"/>
<div align="center">Background Job</div>
<br>


#### 6. Open R and run the Shiny Dashboard

```
library(shiny)
runApp()
```

<img src="www/Dashboard.png" align="center"/>
<div align="center">Dashboard</div>
<br>

#### 7. Select Chain and Enter Address and Put what type of notifications to receive and add task to tracking

```
library(shiny)
runApp()
```

<img src="www/SelectChain.png" align="center"/>
<div align="center">Select Chain</div>
<br>

<img src="www/EnterAddress.png" align="center"/>
<div align="center">Enter Address</div>
<br>

<img src="www/TaskAdded.png" align="center"/>
<div align="center">Task Added</div>
<br>

#### 8. Results

![](https://github.com/Omni-Analytics-Group/ChainSignal/blob/main/www/ResultDash.gif)
<div align="center">Dashboard</div>
<br>


![](https://github.com/Omni-Analytics-Group/ChainSignal/blob/main/www/ResultERC20.gif)
<div align="center">ERC20 Tx Alert</div>
<br>


![](https://github.com/Omni-Analytics-Group/ChainSignal/blob/main/www/ResultNFT.gif)
<div align="center">NFT Tx Alert</div>
<br>
