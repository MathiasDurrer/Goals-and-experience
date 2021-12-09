# install.packages("pacman")
# clear environment to make sure no bugs happen if run multiple times in the same session
rm(list = ls(all.names = TRUE))
# loading data table (if not already loaded)
pacman::p_load(data.table)
library(devtools)
library(cognitivemodels)
library(cognitiveutils)
library(data.table)
#setting working directory
setwd("C:/Users/mathi/Desktop/Goals-and-experience/experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli")

#loading in stimuli 
stimuli_easy <- fread(file = "stimuli_easy.csv")
stimuli_medium <- fread(file = "stimuli_medium.csv")
stimuli_hard <- fread(file = "stimuli_hard.csv")

attentionchecks <- data.table(rbind(stimuli_easy[6,], stimuli_medium[6,], stimuli_hard[6,]))

M <- hm1988(formula = ~ x1LV+p1LV+x2LV+p2LV | x1HV+p1HV+x2HV+p2HV,
            trials = ".ALL", states = ".ALL" , budget = ~budget , ntrials = 5,
            initstate = 0, data = attentionchecks, choicerule = NULL)


### TO DO: die echten daten ins modell nehmen (nur attentioncheck daten) 
#(anstatt trials = .ALL und states = .ALL hier die variablen aus den daten)

sim <- data.table(
  s = M$get_states(), #states = accumulated points in trials beforehand
  t = 6-M$get_timehorizons(), # 6- m$get_timehorizon = number of trials, as get_timehorizon = trials left
  predict(M) # predict = prediction of choice
)
#setnames(sim, c("xp", "x_"), c("ps", "pr"))
sim$bid <- cumsum(sim$t == 1)

### UNSURE IF IT IS CLEAR FOR THE EASY ATTENTIONCHECK ###
### AS THERE IS STILL SOME CHANCE TO GET TO THE GOAL EVEN WHEN CHOOSING THE RISKY OPTION IN SOME SPECIFIC CASES ###
