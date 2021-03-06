# Trading Strategy: Mean-Reversion "Bollinger Bands"
# Technical Indicators: BBands
# Optimization/Walk Forward Analysis: Yes/No

# 1. Packages ####
library("quantstrat")
rm(list = ls())
dev.off(dev.list()["RStudioGD"])
# 2. Setup ####

# 2.1. Initial Settings
init.portf <- '2007-12-31'
start.date <- '2008-01-01'
end.date <- Sys.Date()
Sys.setenv(TZ = "UTC")
init.equity <- 100000
enable_stops <- FALSE
period_params <- list(n = c(15, 20, 25))
sd_params <- list(sd = c(1, 1.5, 2))
position_size <- 100
txn_fee <- -6

# 2.2. Data Downloading
getSymbols(
  Symbols = "SPY",
  src = "yahoo",
  from = start.date,
  to = end.date,
  index.class = "POSIXct",
  adjust = T
)

# 2.3. Initialize Currency
currency(primary_id = "USD")

# 2.4.Initialize Stock Instrument
stock(primary_id = "SPY",
      currency = "USD",
      multiplier = 1)

# 3. Details ####

# Mean-Reversion Strategy
# Buy Rules = Buy when Close < Lower Band
# Sell Rules = Sell when Close > Upper Band
barChart(SPY)
addBBands(n = 20, sd = 2)

# 4. Initialization ####

# 4.1. Strategy Name
opt.mean1.strat <- "OptMeanStrat1"

# 4.2. Clear Strategy Data
rm.strat(opt.mean1.strat)

# 4.3. Strategy Object
strategy(name = opt.mean1.strat, store = TRUE)

# 4.4. Completed Strategy Object
summary(getStrategy(opt.mean1.strat))

# 5. Definitions ####

# 5.1. Add Strategy Indicator

# 5.1.1. Add BBands
add.indicator(
  strategy = opt.mean1.strat,
  name = "BBands",
  arguments = list(HLC = quote(HLC(mktdata))),
  label = 'BBands'
)

# 5.2. Signals ####

# 5.2.1. Add Buying Signal
add.signal(
  strategy = opt.mean1.strat,
  name = "sigCrossover",
  arguments = list(columns = c("Close", "dn"), relationship = "lt"),
  label = "BuySignal"
)
# 5.2.2. Add Selling Signal
add.signal(
  strategy = opt.mean1.strat,
  name = "sigCrossover",
  arguments = list(columns = c("Close", "up"), relationship = "gt"),
  label = "SellSignal"
)

# 5.3. Rules ####

# 5.3.1. Add Enter Rule
add.rule(
  strategy = opt.mean1.strat,
  name = 'ruleSignal',
  arguments = list(
    sigcol = "BuySignal",
    sigval = TRUE,
    orderqty = position_size,
    ordertype = 'market',
    orderside = 'long'
  ),
  type = 'enter',
  label = "EnterRule",
  enabled = T
)
# Stop-Loss and Trailing-Stop Rules
add.rule(
  strategy = opt.mean1.strat,
  name = 'ruleSignal',
  arguments = list(
    sigcol = "BuySignal",
    sigval = TRUE,
    orderqty = 'all',
    ordertype = 'stoplimit',
    threshold = 0.05,
    orderside = 'long'
  ),
  type = 'chain',
  label = "StopLoss",
  parent = "EnterRule",
  enabled = enable_stops
)
add.rule(
  strategy = opt.mean1.strat,
  name = 'ruleSignal',
  arguments = list(
    sigcol = "BuySignal",
    sigval = TRUE,
    orderqty = 'all',
    ordertype = 'stoptrailing',
    threshold = 0.07,
    orderside = 'long'
  ),
  type = 'chain',
  label = "TrailingStop",
  parent = "EnterRule",
  enabled = enable_stops
)

# 5.3.2. Add Exit Rule
add.rule(
  strategy = opt.mean1.strat,
  name = 'ruleSignal',
  arguments = list(
    sigcol = "SellSignal",
    sigval = TRUE,
    orderqty = 'all',
    ordertype = 'market',
    orderside = 'long',
    TxnFees = txn_fee
  ),
  type = 'exit',
  label = "ExitRule",
  enabled = T
)

# 5.4. Parameters ####

# Number of Periods
add.distribution(
  strategy = opt.mean1.strat,
  paramset.label = 'OptMeanPar1',
  component.type = 'indicator',
  component.label = 'BBands',
  variable = period_params,
  label = 'n'
)
# Number of Standard Deviations
add.distribution(
  strategy = opt.mean1.strat,
  paramset.label = 'OptMeanPar1',
  component.type = 'indicator',
  component.label = 'BBands',
  variable = sd_params,
  label = 'sd'
)

# 5.5. Completed Strategy Object
summary(getStrategy(opt.mean1.strat))

# 6. Portfolio Initialization ####

# 6.1. Portfolio Names
opt.mean1.portf <- "OptMeanPort1"

# 6.2. Clear Portfolio Data
rm.strat(opt.mean1.portf)

# 6.3. Initialize Portfolio Object
initPortf(name = opt.mean1.portf,
          symbols = "SPY",
          initDate = init.portf)

# 6.2. Initialize Account Object
initAcct(
  name = opt.mean1.strat,
  portfolios = opt.mean1.portf,
  initDate = init.portf,
  initEq = init.equity
)

# 6.3. Initialize Orders Object
initOrders(portfolio = opt.mean1.portf, initDate = init.portf)

# 7. Optimization ####

# 7.1. Strategy Optimization Results
opt.mean1.results <-
  apply.paramset(
    strategy.st = opt.mean1.strat,
    paramset.label = 'OptMeanPar1',
    portfolio.st = opt.mean1.portf,
    account.st = opt.mean1.strat,
    nsamples = 0,
    verbose = TRUE
  )

# 7.2. Strategy Optimization Trading Statistics

# 7.2.1. Strategy Optimization General Trade Statistics
all.mean1.stats <- opt.mean1.results$tradeStats
View(t(all.mean1.stats))
View(all.mean1.stats)

# 7.2.2. Strategy Optimization Net Trading PL
plot(
  x = all.mean1.stats$Portfolio,
  y = all.mean1.stats$Net.Trading.PL,
  main = "Mean1 Optimization Net Trading PL",
  xlab = "Portfolio",
  ylab = "Net.Trading.PL"
)

# 7.2.3. Strategy Optimization Maximum Drawdown
plot(
  x = all.mean1.stats$Portfolio,
  y = all.mean1.stats$Max.Drawdown,
  main = "Mean1 Optimization Maximum Drawdown",
  xlab = "Portfolio",
  ylab = "Max.Drawdown"
)

# 7.2.4. Strategy Optimization Profit to Maximum Drawdown
plot(
  x = all.mean1.stats$Portfolio,
  y = all.mean1.stats$Profit.To.Max.Draw,
  main = "Mean1 Optimization Profit to Maximum Drawdown",
  xlab = "Portfolio",
  ylab = "Profit.To.Max.Draw"
)
