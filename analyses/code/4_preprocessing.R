setwd("C:/Users/mathi/Desktop/Goals-and-experience/data/raw")
pacman::p_load(data.table)
library(devtools)
library(cognitivemodels)
library(cognitiveutils)
library(ggplot2)
#install.packages("patchwork")
library(patchwork)

#reading d and d2
d <-fread(file = "choices1.csv")
d2 <-fread(file = "choices2.csv")
t1 <- fread(file= "PageTimes-2022-01-11.csv")

#combining d and d2
d <- rbind(d,d2)

#renaming culumns
setnames(d, gsub("player.", "",names(d)))
setnames(d, "state6", "terminal_state")
setnames(d, "trial", "round")

#paste id (phase+stimulus0+stimulus1+budget) as block_id
d[,"block_id" := paste(phase, stimulus0, stimulus1, budget)]

#goal_condition variable im experiment abspeichern 
### only for pretest (from now on the variable will be saved correctly) ###
d[, goal_condition := ifelse(participant.code %in% c("gy3mh7mq", "czuo8pd5", "clnudoem", "b2yros5m"), "hidden", "shown")]

#generating stimulus_id in d and d2 data table
d[, stimulus_id := paste(stimulus0, stimulus1, budget, sep = "_")]

#reading stimuli data tables
stimuli_filenames <- list.files(path ="../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli", full.names = TRUE)
stimuli <- lapply(stimuli_filenames, fread)
stimuli <- rbindlist(stimuli, idcol = "stimulus_type")

stimuli$stimulus_type <- factor(stimuli$stimulus_type, labels = c("attentioncheck_easy", "attentioncheck_hard", "attentioncheck_medium", "familiarization", "stimuli_easy", "stimuli_hard", "stimuli_medium"))
stimuli[, stimulus_id := paste(x1HV, p1HV*100, x2HV, x1LV, p1LV*100, x2LV, budget, sep = "_")]

#adding attentioncheck as type to attentioncheck stimuli
stimuli[7, stimulus_type := "attentioncheck"]
stimuli[15, stimulus_type := "attentioncheck"]
stimuli[23, stimulus_type := "attentioncheck"]

#merging d and stimuli (to get stimuli type into the main dataset = d)
d <- merge(d, stimuli, by = "stimulus_id")

#deleting all data from partitipant "gy3mh7mq" and "czuo8pd5" as they misunderstood the task ###(only in pretesting)###
d <- d[participant.code != "gy3mh7mq"]
d <- d[participant.code != "czuo8pd5"]

#generating data table for all attentionchecks (to simulate the model answers later)
attentioncheck <- d[stimulus_type == "attentioncheck"]

#deleting all attentioncheck data
d <- d[stimulus_type != "attentioncheck"]

#deleting familiarization data
d <- d[stimulus_type != "familiarization"]

#renaming duplicated budget column and deleting one
setnames(d, "budget.x", "budget")
d$budget.y <- NULL

##melting data tables into the format needed to do further analysis
#melting sample data
sample_d <- melt(d, id.vars = (c("participant.code", "block_id", "goal_condition", "stimulus_type")), 
                 measure.vars = patterns("^sample[1-9]", "^draw[1-9]", "^sample_rt_ms[1-9]"), 
                 value.name = c("sample", "draw", "rt_ms"), variable.name = "trial", na.rm = TRUE)

#deleting all NA`s`
sample_d <- sample_d[!(is.na(rt_ms) & is.na(draw) & is.na(sample))]

#melting choice data
choice_d <- melt(d, id.vars = (c("participant.code", "block_id", "goal_condition", "stimulus_type", "terminal_state", "budget")), 
             measure.vars = patterns("^choice[1-9]", "^state[1-9]", "^rt_ms[1-9]"), 
             value.name = c("choice", "state", "rt_ms"), variable.name = "trial", na.rm = TRUE)

#inverting risky_choice: now 1 is the risky (high variance) choice and 0 the safe (low variance) choice 
#(here because attentionchecks are taken out into their own data table, making sure they have the same logic)
choice_d[, risky_choice := 1 - choice]
choice_d$choice <- NULL



#writing files for all generated data tables for further analysis (to data/processed folder)
fwrite(attentioncheck, file = "C:/Users/mathi/Desktop/Goals-and-experience/data/processed/attentioncheck.csv")
fwrite(sample_d, file = "C:/Users/mathi/Desktop/Goals-and-experience/data/processed/sample_d.csv")
fwrite(choice_d, file = "C:/Users/mathi/Desktop/Goals-and-experience/data/processed/choice_d.csv")
