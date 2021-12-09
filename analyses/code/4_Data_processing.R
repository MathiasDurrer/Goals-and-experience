
setwd("C:/Users/mathi/Desktop/Goals-and-experience/data/raw")
pacman::p_load(data.table)
library(devtools)
library(cognitivemodels)
library(cognitiveutils)
library(ggplot2)
install.packages("patchwork")
library(patchwork)
d <-fread(file = "choices.csv")

#reformatting data frame that different blocks are in different rows instead of all in the same block (headers are not yet reorganised)
setnames(d, gsub("player.", "",names(d)))
setnames(d, "state6", "terminal_state")
setnames(d, "trial", "round")



#paste id (phase+stimulus0+stimulus1+budget) as block_id
d[,"block_id" := paste(phase, stimulus0, stimulus1, budget)]
#TO DO: goal_condition variable im experiment abspeichern
d[, goal_condition := ifelse(participant.code %in% c("gy3mh7mq", "czuo8pd5", "clnudoem"), "hidden", "shown")]
d[, stimulus_id := paste(stimulus0, stimulus1, budget, sep = "_")]

stimuli_filenames <- list.files(path ="../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli", full.names = TRUE)
stimuli <- lapply(stimuli_filenames, fread)
stimuli <- rbindlist(stimuli, idcol = "stimulus_type")

stimuli$stimulus_type <- factor(stimuli$stimulus_type, labels = c("familiarization", "easy", "hard", "medium"))
stimuli[, stimulus_id := paste(x1HV, p1HV*100, x2HV, x1LV, p1LV*100, x2LV, budget, sep = "_")]

#adding attentioncheck as type to attentioncheck stimuli
stimuli[7, stimulus_type := "attentioncheck"]
stimuli[15, stimulus_type := "attentioncheck"]
stimuli[23, stimulus_type := "attentioncheck"]

#merging d and stimuli (to get stimuli type into the main dataset = d)
d <- merge(d, stimuli, by = "stimulus_id")
#deleting all data from partitipant "gy3mh7mq" as they misunderstood the task ###(only in pretesting)###
d <- d[participant.code != "gy3mh7mq"]
#generating data table for all attentionchecks (to simulate the model answers later)
attentioncheck <- d[stimulus_type == "attentioncheck"]
#deleting all attentioncheck data
d <- d[stimulus_type != "attentioncheck"]
#deleting familiarization data
d <- d[stimulus_type != "familiarization"]


# 
sample_d <- melt(d, id.vars = (c("participant.code", "block_id", "goal_condition", "stimulus_type")), 
                 measure.vars = patterns("^sample[1-9]", "^draw[1-9]", "^sample_rt_ms[1-9]"), 
                 value.name = c("sample", "draw", "rt_ms"), variable.name = "trial", na.rm = TRUE)

#deleting all NA`s`
sample_d <- sample_d[!(is.na(rt_ms) & is.na(draw) & is.na(choice))]

sample_d[, risky_choice := 1 - choice]

### HOW OFTEN DO PARTICIPANTS SAMPLE? ###
### TO DO: attentionchecks rausschmeissen vorher -done
### TO DO: phases (easy, medium, hard) in den datensatz reinnehmen -done

#generating data table containing the number of samples per block and participant
sample_counts <- sample_d[,length(choice), by = c("participant.code", "block_id", "goal_condition", "stimulus_type")]

#generating data table containing mean of number of samples per participant
mean_sample <- sample_counts[, mean(V1) ,by = c("participant.code", "goal_condition", "stimulus_type")]

#generating data table containing median of number of samples per participant
median_sample <- sample_counts[, median(V1), by = c("participant.code", "goal_condition", "stimulus_type")]

#merging mean and median data tables 
mean_median_sample <- merge(mean_sample, median_sample, by = c("participant.code", "goal_condition", "stimulus_type"))

#renaming columns after merge
setnames(mean_median_sample, c("V1.x", "V1.y"), c("mean_samples", "median_samples"))

#alternative (macht das gleiche wie der code unten bis line 86)
plot_means <- sample_counts[, list(sd = sd(V1), mean_samples = mean(V1)), by = c("goal_condition", "stimulus_type")]

#generating data table with sd per goal condition and stimulus type
sample_sd <- sample_counts[, sd(V1), by = c("goal_condition", "stimulus_type")]

#generating a data table with the mean of mean_samples per goal_condition and stimulus type
sample_mean <- sample_counts[, mean(V1), by = c("goal_condition", "stimulus_type")]

#merging both means and sd data tables
plot_means <- merge(sample_mean, sample_sd, by = c("goal_condition", "stimulus_type"))

#renaming column V1.x and V1.y to mean_samples and sd
setnames(plot_means, c("V1.x", "V1.y"), c("mean_samples", "sd"))

#making sure goal_condition is a factor (nececarry for plotting after)
plot_means$goal_condition <- as.factor(plot_means$goal_condition)

#generating basic barplot
plot1 <- ggplot(plot_means, aes(x = goal_condition, y = mean_samples, fill = factor(stimulus_type, levels = c("easy", "medium", "hard")))) +
          geom_bar(stat = "identity", position = position_dodge()) +
          geom_errorbar(aes(ymin = mean_samples-sd, ymax = mean_samples+sd), width = 0.2, position = position_dodge(width = 0.9))+
  #styling barplot and naming axis
          labs(title = "Mean samples per goal difficulty and goal condition", x = "Goal", y = "Mean samples")+
          theme_classic()+
          scale_fill_discrete(name = "Goal difficulty")
print(plot1)

#risky choices
plot_risky_choices <- sample_d[, list(mean_choices = mean(risky_choice), sd = sd(risky_choice)), by = c("goal_condition", "stimulus_type")]

plot2 <- ggplot(plot_risky_choices, aes(x = goal_condition, y = mean_choices, fill = factor(stimulus_type, levels = c("easy", "medium", "hard")))) +
  geom_bar(stat = "identity", position = position_dodge()) +
  #geom_errorbar(aes(ymin = mean_choices-sd, ymax = mean_choices+sd), width = 0.2, position = position_dodge(width = 0.9))+
  labs(title = "Mean risky choices per goal difficulty and goal condition", x = "Goal", y = "Mean samples")+
  theme_classic()+
  scale_fill_discrete(name = "Goal difficulty")+
  ylim(c(0,1)) 

print(plot2)

plot1 / plot2 + plot_layout(guides = "collect")


### HOW MANY SANITY CHECKS DID PARTICIPANTS ANSWER CORRECTLY ### 
### TO DO: die echten daten ins modell nehmen (nur attentioncheck daten) 
#(anstatt trials = .ALL und states = .ALL hier die variablen aus den daten)

#taking only rows where "participant._index_in_pages = 259" as this is the last page (= only participants that finished the study)
attentioncheck <- attentioncheck[!(participant._index_in_pages != 259)]
#renaming column Budget due to merge (and having budget 2 times in the data table)
setnames(attentioncheck, "budget.x", "budget")


melt(attentioncheck, id.vars = (c("participant.code", "block_id", "goal_condition", "stimulus_type")), measure.vars = patterns("^choice[1-9]"), 
     value.name = c("choice"), variable.name = "trial", na.rm = TRUE)

M <- hm1988(formula = ~ x1LV+p1LV+x2LV+p2LV | x1HV+p1HV+x2HV+p2HV,
            trials = ".ALL", states = attentioncheck[c(state1, state2, state3, state4, state5)], budget = ~budget , ntrials = 5,
            initstate = 0, data = attentioncheck, choicerule = NULL)


sim <- data.table(
  s = M$get_states(), #states = accumulated points in trials beforehand
  t = 6-M$get_timehorizons(), # 6- m$get_timehorizon = number of trials, as get_timehorizon = trials left
  predict(M) # predict = prediction of choice
)

sim$bid <- cumsum(sim$t == 1)



### HIGHER GOALS = HIGHER RISK? ###

#higher risk is defined through higher variance of options: In this dataset the risky option is coded in 0
choice_d <- melt(d, id.vars = (c("participant.code", "block_id")), measure.vars = patterns("choice"),
                value.name = c("choice_0isHV"), variable.name = "choice")

#generating data tables containing all choices made in the respective difficultylevel
setkey(choice_d, choice_0isHV)

#easy
choice_easy <- na.omit(choice_d[grep(pattern = "easy", x = block_id)])

#medium
choice_medium <- na.omit(choice_d[grep(pattern = "medium", x = block_id)])

#hard
choice_hard <- na.omit(choice_d[grep(pattern = "hard", x = block_id)])

#combining a data table with number of 0 and 1 choices respectively (row 1 = Low variance, row 2 = High variance)
risky_vs_safe <- data.table(easy_1isLV_2isHV = mean(choice_easy$choice_0isHV == 0), 
                            medium_1isLV_2isHV =mean(choice_medium$choice_0isHV == 0),
                            hard_1isLV_2isHV = mean(choice_hard$choice_0isHV == 0))




