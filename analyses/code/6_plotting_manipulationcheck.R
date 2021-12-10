setwd("C:/Users/mathi/Desktop/Goals-and-experience/data/processed")
pacman::p_load(data.table)
library(devtools)
library(cognitivemodels)
library(cognitiveutils)
library(ggplot2)
#install.packages("patchwork")
library(patchwork)

#loading in prepared data table
sample_d <- fread(file = "sample_d.csv")
choice_d <- fread(file = "choice_d.csv")

###To Do: attentionchecks_incorrect.csv rauswerfen?

### HOW OFTEN DO PARTICIPANTS SAMPLE? ###

#generating data table containing the number of samples per block and participant
sample_counts <- sample_d[,length(sample), by = c("participant.code", "block_id", "goal_condition", "stimulus_type")]

#genearating data table with mean samples, sd by goal_condition and difficultylevel
plot_means <- sample_counts[, list(sd = sd(V1), mean_samples = mean(V1)), by = c("goal_condition", "stimulus_type")]

#making sure goal_condition is a factor (nececarry for plotting after)
plot_means$goal_condition <- as.factor(plot_means$goal_condition)

#risky choices
plot_risky_choices <- choice_d[, list(mean_choices = mean(risky_choice), sd = sd(risky_choice)), by = c("goal_condition", "stimulus_type")]

#generating 2 barplots
pdf("C:/Users/mathi/Desktop/Goals-and-experience/analyses/figures/sample_and_risky_choices.pdf")

plot1 <- ggplot(plot_means, aes(x = goal_condition, y = mean_samples, fill = factor(stimulus_type, levels = c("easy", "medium", "hard")))) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_errorbar(aes(ymin = mean_samples-sd, ymax = mean_samples+sd), width = 0.2, position = position_dodge(width = 0.9))+
  #styling barplot and naming axis
  labs(title = "Mean samples per goal difficulty and goal condition", x = "Goal", y = "Mean samples")+
  theme_classic()+
  scale_fill_discrete(name = "Goal difficulty")

print(plot1)

plot2 <- ggplot(plot_risky_choices, aes(x = goal_condition, y = mean_choices, fill = factor(stimulus_type, levels = c("easy", "medium", "hard")))) +
  geom_bar(stat = "identity", position = position_dodge()) +
  #geom_errorbar(aes(ymin = mean_choices-sd, ymax = mean_choices+sd), width = 0.2, position = position_dodge(width = 0.9))+
  labs(title = "Mean risky choices per goal difficulty and goal condition", x = "Goal", y = "Mean risky choices")+
  theme_classic()+
  scale_fill_discrete(name = "Goal difficulty")+
  ylim(c(0,1)) 

print(plot2)

plot1 / plot2 + plot_layout(guides = "collect")

dev.off()


### How often did participants reach the threshold? ###

#genrating column with logical (TRUE/FALSE) if threshold reached
choice_d[, success := terminal_state >= budget, by = c("goal_condition", "stimulus_type", "participant.code")]

#calculating mean of success column (output is percentage of successes) per goal_condition, goal_difficulty and participant
percentage <- choice_d[, mean(success), by = c("goal_condition", "stimulus_type")]
setnames(percentage, "V1", "successes")

pdf("C:/Users/mathi/Desktop/Goals-and-experience/analyses/figures/goal_sucesses.pdf")

plot3 <- ggplot(percentage, aes(x = goal_condition, y = successes, fill = factor(stimulus_type, levels = c("easy", "medium", "hard")))) +
  geom_bar(stat = "identity", position = position_dodge())+
  labs(title = "Mean threshold reached per goal difficulty and goal condition", x = "Goal", y = "Mean threshold reached")+
  scale_fill_discrete(name = "Goal difficulty")

print(plot3)

dev.off()
### HIGHER GOALS = HIGHER RISK? ###

# #higher risk is defined through higher variance of options: In this dataset the risky option is coded in 0
# choice_d <- melt(d, id.vars = (c("participant.code", "block_id")), measure.vars = patterns("choice"),
#                 value.name = c("choice_0isHV"), variable.name = "choice")
# 
# #generating data tables containing all choices made in the respective difficultylevel
# setkey(choice_d, choice_0isHV)
# 
# #easy
# choice_easy <- na.omit(choice_d[grep(pattern = "easy", x = block_id)])
# 
# #medium
# choice_medium <- na.omit(choice_d[grep(pattern = "medium", x = block_id)])
# 
# #hard
# choice_hard <- na.omit(choice_d[grep(pattern = "hard", x = block_id)])
# 
# #combining a data table with number of 0 and 1 choices respectively (row 1 = Low variance, row 2 = High variance)
# risky_vs_safe <- data.table(easy_1isLV_2isHV = mean(choice_easy$choice_0isHV == 0), 
#                             medium_1isLV_2isHV =mean(choice_medium$choice_0isHV == 0),
#                             hard_1isLV_2isHV = mean(choice_hard$choice_0isHV == 0))
# 
# 
