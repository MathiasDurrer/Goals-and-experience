# install.packages("pacman")
# clear environment to make sure no bugs happen if run multiple times in the same session
rm(list = ls(all.names = TRUE))
# loading data table (if not already loaded)
pacman::p_load(data.table)

# select working directory
setwd("C:/Users/mathi/Desktop/Goals-and-experience/analyses/code")
# read in all stimuli
res <- fread(file = "all_stimuli.csv")
# constructing designid: id for every combination of budget and (lottery-)pair
res$designid <- paste(res$bid, res$pairid)

# constructing cutoffs for p(probability) and b(budget)
# limiting the range of p(probability) 
# easy
prob_cutoff_e <- c(0.99, 1)
# medium
prob_cutoff_m <- c(0.3, 0.99)
# hard
prob_cutoff_d <- c(0, 0.3)
# limiting the range of b(budget)
# easy
b_cutoff_e <- c(0, 10)
# medium
b_cutoff_m <- c(b_cutoff_e[2], 35)
# hard
b_cutoff_d <- c(b_cutoff_m[2], 45)

# assigndifficulty function
assigndifficulty <- function(level, prange, brange, p, b) {
  condition <- b > brange[1] & b <= brange[2] & p > prange[1] & p <= prange[2]
  #if b is within brange & if all p`s are within prange; return difficultylevel, else return NA
  if(mean(as.numeric(condition)) >= .7) { # Parameter: decides how hard the "condition"(prange and brange) is enforced
    return(rep(level,length(p)))
  } else {
    return(rep(NA, length(p)))
  }
}


# Constructing difficultylevel 
# resetting difficultylevel (for repeated runs)
res[,difficultylevel := NULL]
# taking all stimulipairs (=by designid) and the predictions until trial 3 (t > 4) and assigning difficulty (with assigndifficulty function)
# p = max(ps, pr): the maximum of predicted choice probability for the safe(ps) and risky(pr) lottery of each pair
res[t <  4                         , difficultylevel := assigndifficulty(level = 1, prange = prob_cutoff_e, brange = b_cutoff_e, p = pmax(ps, pr), b = b), by = designid]
res[t <  4 & is.na(difficultylevel), difficultylevel := assigndifficulty(level = 2, prange = prob_cutoff_m, brange = b_cutoff_m, p = pmax(ps, pr), b = b), by = designid]
res[t <  4 & is.na(difficultylevel), difficultylevel := assigndifficulty(level = 3, prange = prob_cutoff_d, brange = b_cutoff_d, p = pmax(ps, pr), b = b), by = designid]
# since it assigns difficultylevel only untill t = 3, replacing Na`s with the difficultylevel in t = 1 (by designid)
res[,difficultylevel := difficultylevel[t == 1] , by = designid]

# controlling how many rows each difficultylevel has
res[,.N, by = difficultylevel]

# overallutility function
# restricts utility for repeated values
overallutility <- function(stimuli){
  # subutility for non repeated x and y
  subutility1 <- stimuli[!duplicated(designid)][, sum(!duplicated(x) | !duplicated(y))/.N]
  # subutility2 for non repeated x_r and y_r
  subutility2 <- stimuli[!duplicated(designid)][, sum(!duplicated(x_r) | !duplicated(y_r))/.N]
  # 1/2 * subutility1 + 1/2 * subutility 2
  return(1/2 * subutility1 + 1/2 * subutility2)
}

# resetting rareevent (for repeated runs)
res[, rareevent := NULL]
# defining rareevent as 80% to 100% and 0% to 20%
# res[, rareevent := (px_r >= 0.8 | px_r <= 0.2) & (px >= 0.2 | py <= 0.8)]
#attempt 2
res[, rareevent := ifelse(pmin(px_r, py_r)  <= 0.20 & pmin(px, py) <= 0.20, TRUE, FALSE)]

# taking out all Na`s
res <- na.omit(res)
# drawdesign function: takes random draws from each difficultylevel; 5 without rareevent and 2 with rareevent
drawdesign <- function(res) {
  res[(difficultylevel == 1 & designid %in% sample(designid[difficultylevel == 1 & rareevent == T], 2)) |
      (difficultylevel == 1 & designid %in% sample(designid[difficultylevel == 1 & rareevent == F], 2)) |
      (difficultylevel == 2 & designid %in% sample(designid[difficultylevel == 2 & rareevent == T], 2)) |
      (difficultylevel == 2 & designid %in% sample(designid[difficultylevel == 2 & rareevent == F], 2)) |
      (difficultylevel == 3 & designid %in% sample(designid[difficultylevel == 3 & rareevent == T], 2)) |
      (difficultylevel == 3 & designid %in% sample(designid[difficultylevel == 3 & rareevent == F], 2)), ]
}

# check if there are rare events in every difficultylevel
res[,sum(rareevent == T), by = difficultylevel]
# check if there are non rere events in evry difficultylevel
res[,sum(rareevent == F), by = difficultylevel]

# seed for reproducability
# set.seed(5476)
# generating design with drawdesign function
design  <- drawdesign(res = res)
# geneating utility with overallutility function for the "design"
utility <- overallutility(stimuli = design)

# check if there are reare events in design
design[,sum(rareevent), by = difficultylevel]
# check how many designids are in the design (should be 21)
length(unique(design$designid))
# generating temp as an overview of design
temp <- design[t == 1]
temp <- temp[order(difficultylevel, rareevent)]
# resetting n
n <- 0
# loops picking a proposaldesign and genereating  proposalutility, then comparing proposalutility and utility, 
# if proposalutlity is bigger than utility proposaldesign is assigned as the new design and proposalutility as the new utility to beat
while(n < 500000) {
  proposaldesign <- drawdesign(res = res)
  
  proposalutility <- overallutility(stimuli = proposaldesign)
  
  if (proposalutility > utility) {
    utility <- proposalutility
    design <- proposaldesign
  }
  n = n + 1
}

# overriding new temp to inspect
temp <- design[t == 1]
# view temp ordered by difficultylevel and rareevent
temp <- temp[order(difficultylevel, rareevent)]
View(temp)
#writing the stimuli into a csv file
fwrite(design, file = "C:/Users/mathi/Desktop/Goals-and-experience/analyses/code/stimuli_auswahl.csv")
#reading the stimuli
stimuli <- fread(file = "stimuli_auswahl.csv")
stimuli <- stimuli[t == 1]
stimuli <- stimuli[order(difficultylevel, rareevent)]

#construct missing lotteries: take ones of the same difficultylevel (and rare event) and add 3 to all options (and budget)
a <- NULL
a <- stimuli[7,]
a[, "x_r" := x_r + 1]
a[, "y_r" := y_r + 1]
a[, "x" := x + 1]
a[, "y" := y + 1]
a[, "b" := b + (5 * 1)]
a
b = NULL
b <- stimuli[10,]
b[, "x_r" := x_r + 1]
b[, "y_r" := y_r + 1]
b[, "x" := x + 1]
b[, "y" := y + 1]
b[, "b" := b + (5 * 1)]
b

#adding the new constructed lotteries into stimuli again
stimuli <- rbind(stimuli, a)
stimuli <- rbind(stimuli, b)

#ordering stimuli again
stimuli <- stimuli[order(difficultylevel, rareevent)]

#writing the stimuli into a csv file
fwrite(stimuli, file = "C:/Users/mathi/Desktop/Goals-and-experience/analyses/code/stimuli_auswahl_ergänzt.csv")
#reading the stimuli
stimuli_ergänzt <- fread(file = "stimuli_auswahl_ergänzt.csv")
stimuli_ergänzt <- stimuli_ergänzt[t == 1]
stimuli_ergänzt <- stimuli_ergänzt[order(difficultylevel, rareevent)]

#constructing attention checks
e <- NULL
e<- stimuli_ergänzt[3,]
e[, "x_r" := 0]
e[, "px_r" := 0.7]
e[, "y_r" := 1]
e[, "py_r" := 0.3]
e[, "x" :=2]
e[, "px" := 0.7]
e[, "y" := 3]
e[, "py":= 0.3]
e[, "b" := 10]
e[, "difficultylevel" := 1]
e
f <- NULL
f<- stimuli_ergänzt[3,]
f[, "x_r" := 1]
f[, "px_r" := 0.7]
f[, "y_r" := 2]
f[, "py_r" := 0.3]
f[, "x" := 7]
f[, "px" := 0.7]
f[, "y" := 8]
f[, "py":= 0.3]
f[, "b" := 35]
f[, "difficultylevel" := 2]
f
g <- NULL
g<- stimuli_ergänzt[3,]
g[, "x_r" := 3]
g[, "px_r" := 0.7]
g[, "y_r" := 4]
g[, "py_r" := 0.3]
g[, "x" := 9]
g[, "px" := 0.7]
g[, "y" := 10]
g[, "py":= 0.3]
g[, "b" := 45]
g[, "difficultylevel" := 3]
g

stimuli_ergänzt <- rbind(stimuli_ergänzt, e)
stimuli_ergänzt <- rbind(stimuli_ergänzt, f)
stimuli_ergänzt <- rbind(stimuli_ergänzt, g)
stimuli_ergänzt <- stimuli_ergänzt[order(difficultylevel, rareevent)]
# rename colums into: x1HV,x2HV,p1HV,p2HV,x1LV,x2LV,p1LV,p2LV,budget,state and only include 
# (to get the configuration that sprites.R is coded for) 
## sprites.R generates sprites to display lotteries on the experiment webpage
design_sprite <- rbind(stimuli_ergänzt[,.(x_r, y_r, px_r, py_r, x, y, px, py, b, s)])
colnames(design_sprite) <- c("x1HV","x2HV","p1HV","p2HV","x1LV","x2LV","p1LV","p2LV","budget","state")

# write .csv file into static of rsft-gain-loss-experiment folder replacing positive-gain.csv 
#### TO DO: èberprèfen ob die .csv die richtigen stimuli entghalten
fwrite(design_sprite[c(1:4)], file = "../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli/stimuli_easy.csv")
fwrite(design_sprite[5], file = "../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli/attentioncheck_easy.csv")
fwrite(design_sprite[c(6:9)], file = "../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli/stimuli_medium.csv")
fwrite(design_sprite[c(10)], file = "../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli/attentioncheck_medium.csv")
fwrite(design_sprite[c(11:14)], file = "../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli/stimuli_hard.csv")
fwrite(design_sprite[c(15)], file = "../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli/attentioncheck_hard.csv")

