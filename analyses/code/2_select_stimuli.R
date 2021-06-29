#install.packages("pacman")
#rm(list = ls)
pacman::p_load(data.table)

#version 1
res <- fread(file = "all_stimuli.csv")

res$designid <- paste(res$bid, res$pairid)

# utility <- function(ps, pr){
#   zeros <- mean(ps != 0 & pr != 0)
#   ones <- mean(ps != 1 & pr != 1)
#   0.5*zeros + 0.5*ones
# }
# #setup
# 
# U <- res[,list(meanp = mean(c(ps, pr)), 
#                      utility = utility(ps = ps, pr = pr) ), by = list(designid, bid, pairid, b)]




# zuerst mit allen, wenns nicht funktioniert: schliesse das erste und letzte trial aus um die funktion anzuwenden
#versuch 1
# limiting the range of p 
prob_cutoff_e <- c(0.99, 1)
prob_cutoff_m <- c(0.3, 0.99)
prob_cutoff_d <- c(0, 0.3)
# limiting the range of b
b_cutoff_e <- c(0, 10)
b_cutoff_m <- c(b_cutoff_e[2], 35)
b_cutoff_d <- c(b_cutoff_m[2], 45)


assigndifficulty <- function(level, prange, brange, p, b) { # difficultylevel = ids bis jetzt
  condition <- b > brange[1] & b <= brange[2] & p > prange[1] & p <= prange[2]
  #wenn b grösser oder kleiner ist als brange & wenn alle p grösser oder kleiner als prange dann return difficultylevel, ansonsten NA returnen
  if(mean(as.numeric(condition)) >= .7) {
    return(rep(level,length(p)))
  } else {
    return(rep(NA, length(p)))
  }
}


#zum testen:
res[,difficultylevel := NULL]
res[t <  4                         , difficultylevel := assigndifficulty(level = 1, prange = prob_cutoff_e, brange = b_cutoff_e, p = pmax(ps, pr), b = b), by = designid]
res[t <  4 & is.na(difficultylevel), difficultylevel := assigndifficulty(level = 2, prange = prob_cutoff_m, brange = b_cutoff_m, p = pmax(ps, pr), b = b), by = designid]
res[t <  4 & is.na(difficultylevel), difficultylevel := assigndifficulty(level = 3, prange = prob_cutoff_d, brange = b_cutoff_d, p = pmax(ps, pr), b = b), by = designid]
res[,difficultylevel := difficultylevel[t == 1] , by = designid]

res[,.N, by = difficultylevel]
#res[difficultylevel == 2] 
#res[difficultylevel == 3][order(ps)]
#unique(res$designid[res$difficultylevel == 3])
#res[designid == "21 138"] 
#res[designid == "22 138"] 
#res[designid == "23 138"] 


overallutility <- function(stimuli){
  # mit den stimuli eine subutility für nichtwiederholende x und y
  subutility1 <- stimuli[!duplicated(designid)][, sum(!duplicated(x) | !duplicated(y))/.N]
  # subutility für nichtwiederholende x_r und y_r
  subutility2 <- stimuli[!duplicated(designid)][, sum(!duplicated(x_r) | !duplicated(y_r))/.N]
  # 1/3 * subutility1 + 1/3 * subutility 2 + 1/3 * subutility 3
  return(1/2 * subutility1 + 1/2 * subutility2)
}


res[, rareevent := NULL]
res[, rareevent := (px_r >= 0.8 | px_r <= 0.2) & (px >= 0.2 | py <= 0.8)] # 
res <- na.omit(res)
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
res[,sum(rareevent == F), by = difficultylevel]

set.seed(5476)
design  <- drawdesign(res = res)
utility <- overallutility(stimuli = design)

#check if there are reare events in design
design[,sum(rareevent), by = difficultylevel]
length(unique(design$designid))
temp <- design[t == 1]


n <- 0
while(n < 500) {
  proposaldesign <- drawdesign(res = res)
  
  proposalutility <- overallutility(stimuli = proposaldesign)
  
  if (proposalutility > utility) {
    utility <- proposalutility
    design <- proposaldesign
  }
  n = n + 1
}

design[order(difficultylevel)]
temp <- design[t == 1]

View(temp[order(difficultylevel, rareevent)])
