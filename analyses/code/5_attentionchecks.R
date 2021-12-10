setwd("C:/Users/mathi/Desktop/Goals-and-experience/data/processed")
pacman::p_load(data.table)
library(devtools)
library(cognitivemodels)
library(cognitiveutils)
library(ggplot2)
#install.packages("patchwork")
library(patchwork)

#loading in prepared data table
attentioncheck <- fread(file = "attentioncheck.csv")

### HOW MANY SANITY CHECKS DID PARTICIPANTS ANSWER CORRECTLY ### 

#taking only rows where "participant._index_in_pages = 259" as this is the last page (= only participants that finished the study)
attentioncheck <- attentioncheck[!(participant._index_in_pages != 259)]

#generating new stimulus type column (easy, medium, hard) as attentionchecks don`t have that yet
attentioncheck[grep(pattern = "easy", x = block_id), stimulus_type_attention := "easy"]
attentioncheck[grep(pattern = "medium", x = block_id), stimulus_type_attention := "medium"]
attentioncheck[grep(pattern = "hard", x = block_id), stimulus_type_attention := "hard"]

#renaming budget variable and deleting the second one (duplication due to merge with stimuli data)
setnames(attentioncheck, "budget.x", "budget")
attentioncheck$budget.y <- NULL

attentioncheck_l <- melt(attentioncheck, id.vars = (c("participant.code", "block_id", "goal_condition", "stimulus_type_attention", "x1HV", "x2HV", "p1HV", "p2HV", "x1LV", "x2LV", "p1LV", "p2LV", "budget")), 
                         measure.vars = patterns("^choice[1-9]", "^state[1-9]"), 
                         value.name = c("choice", "state"), variable.name = "trial", na.rm = TRUE)

#trials in numeric umwandeln
attentioncheck_l$trial <- attentioncheck_l[, as.numeric(levels(trial))[trial]]

M <- hm1988(formula = ~x1HV+p1HV+x2HV+p2HV | x1LV+p1LV+x2LV+p2LV ,
            trials = ~trial, states = ~state, budget = ~budget , ntrials = 5,
            initstate = 0, data = attentioncheck_l, choicerule = NULL)

#expanding attentioncheck_l with the predictions of hm1988
attentioncheck_l <- cbind(attentioncheck_l, predict(M))

#subsetting all attentioncheck states and trials where there is a clear prediction
###unsure why this does not work properly (with the second line it seems to work, for now)
###also it seems as though no attentioncheck with stimulus_type easy has a clear prediction --> better attentioncheck easy stimuli?
attentioncheck_clear_prediction <- attentioncheck_l[c(1, 0.00000) %in% x1H & x1L,]
attentioncheck_clear_prediction <- attentioncheck_clear_prediction[x1H == 0.00000,]

#generating column with correct needed (50% of all clear predictions)
attentioncheck_clear_prediction[, correct_needed := length(choice)/2, by = c("goal_condition", "stimulus_type_attention", "participant.code")]

#generating column with correct choices
attentioncheck_clear_prediction[choice == x1L, correct := length(choice), by = c("goal_condition", "stimulus_type_attention", "participant.code")]

#generating column percentage If percetage == TRUE at least 50% of clear predictions were aswered correctly
attentioncheck_clear_prediction[, percentage := correct/correct_needed > 0.5]

#generating vector with participants that got more than 50% of clear predictions correct
correct_participants <- attentioncheck_clear_prediction[percentage == TRUE, unique(participant.code)]

#generating vector of all participants in attentioncheck
participants <- attentioncheck[,unique(participant.code)]

#genreting data table with all participants that did not get 50% of clear predictions right
incorrect_participants <- as.data.table(unique(participants[! participants %in% correct_participants]))

#writing a file with all participants that did not get 50% of clear predictions right
fwrite(incorrect_participants, file = "C:/Users/mathi/Desktop/Goals-and-experience/data/processed/attentioncheck_incorrect.csv")
