#' ---	
#' output: html_document	
#' ---	
#' 	
#' 	
knitr::opts_chunk$set(echo = FALSE, warning=FALSE, message=FALSE)	
library(quantmod)	
library(PerformanceAnalytics)	
#' 	
#' 	
#' #### Index	
#' 	
#' * Section I of this document will examine current capital market conditions. 	
#' * Section II will examine current macroeconomic conditions. 	
#' * Section III will discuss underlying economic theory to serve as a platform for forward looking discussion about capital markets (allocation, position sizing).	
#' * Section IV will contain forward looking thoughts and technical decomposition. 	
#' 	
#' #### Section I - Capital Markets	
#' 	
#' In order to be concise we will examine ETF's of broad asset classes based in the U.S:	
#' 	
#' * Cash Equivalents ('SHV')	
#' * U.S. Large-Cap Stocks ('SPY')	
#' * U.S. Treasury Bonds ('TLT')	
#' * U.S. Real Estate ('VNQ')	
#' * Diversified Commodities ('DBC')	
#' 	
#' 	
asset_tickers <- c("SHV", "SPY", "TLT", "VNQ", "DBC")	
getSymbols(asset_tickers, from = "2009-01-01")	
SHV_ret <- monthlyReturn(SHV)	
SPY_ret <- monthlyReturn(SPY)	
TLT_ret <- monthlyReturn(TLT)	
VNQ_ret <- monthlyReturn(VNQ)	
DBC_ret <- monthlyReturn(DBC)	
assets_ret <- cbind(SHV_ret, SPY_ret, TLT_ret, VNQ_ret, DBC_ret)	
assets_ret <- `colnames<-`(assets_ret, c("SHV Returns", "SPY Returns", "TLT Returns", "VNQ Returns", "DBC Returns"))	
charts.PerformanceSummary(R = assets_ret, main = "Asset Class Returns", wealth.index = TRUE)	
charts.RollingPerformance(assets_ret)	
table.AnnualizedReturns(assets_ret)	
chart.Drawdown(assets_ret, legend.loc = "bottomleft", main = "Asset Class Drawdowns")	
chart.Correlation(assets_ret)	
#' 	
#' 	
#' We can view Annualized Return vs. Annualized StdDev through time for each instrument, with lines as Sharpe Ratio values of 1,2,3:	
#' 	
#' 	
chart.SnailTrail(SHV_ret, main = "Cash Equivalent")	
chart.SnailTrail(SPY_ret, main = "U.S Large-Cap Stocks")	
chart.SnailTrail(TLT_ret, main = "U.S. Treasury Bonds")	
chart.SnailTrail(VNQ_ret, main = "U.S. Real Estate")	
chart.SnailTrail(DBC_ret, main = "Diversified Commodities")	
#' 	
#' 	
#' ---	
#' 	
#' #### Section II - Macroeconomic Data	
#' 	
#' We will examine broad macroeconomic data:	
#' 	
#' * Effective Federal Funds Rate	
#' * Real GDP % Change	
#' * Employment	
#' * Smoothed U.S. Recession Probabilities	
#'     + [https://pages.uoregon.edu/jpiger/research/published-papers/chauvet-and-piger_2008_jour.pdf]	
#' * 	
#' 	
#' 	
macro_symbols <- c("EFFR", "GDPC1", "UNRATE", "RECPROUSM156N")	
getSymbols(macro_symbols, src = "FRED", from = "2009-01-01")	
plot(EFFR, main = "Effective Federal Funds Rate")	
GDPC1 <- GDPC1[249:289,]	
plot(ROC(GDPC1), type = "h", main =  "Real GDP %-Change")	
UNRATE <- UNRATE[733:855,]	
plot(UNRATE)	
REC_PROB <- RECPROUSM156N	
REC_PROB <- REC_PROB[391:622,]	
REC_PROB <- `colnames<-`(REC_PROB, "Recession Probability (%)")	
plot(REC_PROB, main = "Smoothed U.S. Recession Probability")	
last(REC_PROB)	
#' 	
#' 	
#' ---	
#' 	
#' #### Section III - Theory	
#' 	
#' 	
#' 	
