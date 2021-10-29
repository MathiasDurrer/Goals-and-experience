# install.packages("pacman")
# clear environment to make sure no bugs happen if run multiple times in the same session
rm(list = ls(all.names = TRUE))
# loading data table (if not already loaded)
pacman::p_load(data.table)
library(devtools)
library(cognitivemodels)
library(cognitiveutils)
library(data.table)

A <- fread(file = "stimuli_auswahl_ergänzt.csv")
#binding the new lotteries to the existing ones
attentionchecks <- A[22:24,]

M <- hm1988(formula = ~ x+px+y+py | x_r+px_r+y_r+py_r,
            trials = ".ALL", states = ".ALL" , budget = ~b , ntrials = 5,
            initstate = 0, data = attentionchecks, choicerule = NULL)

sim <- data.table(
  s = M$get_states(), #states = accumulated points in trials beforehand
  t = 6-M$get_timehorizons(), # 6- m$get_timehorizon = number of trials, as get_timehorizon = trials left
  predict(M) # predict = prediction of choice
)
setnames(sim, c("xp", "x_"), c("ps", "pr"))
sim$bid <- cumsum(sim$t == 1)
