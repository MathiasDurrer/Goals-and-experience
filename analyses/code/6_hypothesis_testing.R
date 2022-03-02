
# Load packages and install missing packages in one go
pacman::p_load(data.table)
library(cognitivemodels)

#Load data
d <- fread("../../data/processed/data.csv")


###check for statistical assumptions


### Hypothesis 1: 

# generate df with n sample trials
dh1 <- d[task %in% c("sample"), mean(trial), by = c("id", "goal_condition")]
#renaming column to meantrial
setnames(dh1, "V1", "meantrial")

#normal poisson regression model 
normal_poisson_model <- glm(meantrial ~ goal_condition, family = poisson(), data = dh1)
summary(normal_poisson_model)
###bayesian poisson regression model
