# install.packages("pacman")
# rm(list = ls)
# loading data table (if not already loaded)
pacman::p_load(data.table)

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
# taking all stimulipairs (=by designid) and the predictions until trial 3 (t > 4) and assigning difficulty (with assigndifficulty fuction)
# p = max(ps, pr): the maximum of predicted choice probability for the safe(ps) and risky(pr) lottery of each pair
res[t <  4                         , difficultylevel := assigndifficulty(level = 1, prange = prob_cutoff_e, brange = b_cutoff_e, p = pmax(ps, pr), b = b), by = designid]
res[t <  4 & is.na(difficultylevel), difficultylevel := assigndifficulty(level = 2, prange = prob_cutoff_m, brange = b_cutoff_m, p = pmax(ps, pr), b = b), by = designid]
res[t <  4 & is.na(difficultylevel), difficultylevel := assigndifficulty(level = 3, prange = prob_cutoff_d, brange = b_cutoff_d, p = pmax(ps, pr), b = b), by = designid]
# since it assigns difficultylevel only untill t = 3, replacing Na`s with the difficultylevel in t = 1 (by designid)
res[,difficultylevel := difficultylevel[t == 1] , by = designid]

# controlling how many rows each difficultylevel has
# res[,.N, by = difficultylevel]

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
res[, rareevent := (px_r >= 0.8 | px_r <= 0.2) & (px >= 0.2 | py <= 0.8)]
# taking out all Na`s
res <- na.omit(res)
# drawdesign function: takes random draws from each difficultylevel; 5 without rareevent and 2 with rareevent
drawdesign <- function(res) {
  res[(difficultylevel == 1 & designid %in% sample(designid[difficultylevel == 1 & rareevent == T], 2)) |
      (difficultylevel == 1 & designid %in% sample(designid[difficultylevel == 1 & rareevent == F], 5)) |
      (difficultylevel == 2 & designid %in% sample(designid[difficultylevel == 2 & rareevent == T], 2)) |
      (difficultylevel == 2 & designid %in% sample(designid[difficultylevel == 2 & rareevent == F], 5)) |
      (difficultylevel == 3 & designid %in% sample(designid[difficultylevel == 3 & rareevent == T], 2)) |
      (difficultylevel == 3 & designid %in% sample(designid[difficultylevel == 3 & rareevent == F], 5)), ]
  
}

# check if there are rare events in every difficultylevel
res[,sum(rareevent == T), by = difficultylevel]
# check if there are non rere events in evry difficultylevel
res[,sum(rareevent == F), by = difficultylevel]

# seed for reproducability
set.seed(5476)
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

# resetting n
n <- 0
# loops picking a proposaldesign and genereating  proposalutility, then comparing proposalutility and utility, 
# if proposalutlity is bigger than utility proposaldesign is assigned as the new design and proposalutility as the new utility to beat
while(n < 500) {
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
View(temp[order(difficultylevel, rareevent)])
