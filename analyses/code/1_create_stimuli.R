##Seting Working directory
setwd("C:/Users/mathi/Desktop/Code MA/analyses/code")
getwd()
##Installing packages
#the packages were necesarry to get the installation of cognitivemodels to work
# install.packages("Rcpp")
# install.packages("usethis")
# install.packages("matlib")
# install.packages("Rcpp")
# install.packages("glue")
# install.packages("cpp11")
# install.packages("curl")
# install.packages("ps")
# install.packages("fs")
# install.packages("cachem")
# install.packages("raster")
# install.packages("registry")
# install.packages("gmp")
# install.packages("VGAM")
# install.packages("unmarked")
# install.packages("quadprog")
# install.packages("ROI")
# install.packages("Rsolnp")
# install.packages("gtools")
# install.packages("Formula")
# install.packages("arrangements")
# install.packages("AICcmodavg")
# devtools::install_github("janajarecki/cognitivemodels")
##Activating necessary Packages
library(devtools)
library(cognitivemodels)
library(cognitiveutils)
library(data.table)

#### define smallest acceptable variance difference between the risky and the safe option
mindiff_var <- 5 #minimal variance difference


# Rsft Variables
t = 5 # Trails
# f <- function(state, budget) as.numeric(state >= budget) #Reward function



#### Gamble set

## Table with all possible combinations of x and y Werte and px (probability of x)
gamble_set <- expand.grid(x = 1:8, px = c(.1 ,.2, .25, .3, .4, .5, .6, .7, .75, .8, .9), y = 1:9)

df_gamble_set <- as.data.frame(gamble_set)


## calculate py (probability of y)
df_gamble_set$py <- (1 - df_gamble_set$px)


## caltulate EV and Var  --> VarG <- c((x - ev)^2 %*% p)

# calculating expected value
df_gamble_set$ev <- df_gamble_set$x * df_gamble_set$px + df_gamble_set$y * df_gamble_set$py

# calculating variance
df_gamble_set$var <- (df_gamble_set$x - df_gamble_set$ev)^2 * df_gamble_set$px + 
  (df_gamble_set$y - df_gamble_set$ev)^2 * df_gamble_set$py

df_gamble_set$var <- round(df_gamble_set$var, 4)


## removing duplicates
tab <- matrix(ncol = 2, nrow = nrow(df_gamble_set))
tab <- rbind(df_gamble_set$ev, df_gamble_set$var)
tab <- t(tab)
dup <- duplicated(tab)

df_gamble_set$dup <- dup
drops <- which(df_gamble_set$dup == TRUE)
df_gamble_set <- df_gamble_set[-drops,]

drops <- which(df_gamble_set$x == df_gamble_set$y)
df_gamble_set <- df_gamble_set[-c(drops),]
nrow(df_gamble_set)

df_gamble_set$id <- 1: nrow(df_gamble_set)
df_gamble_set <- df_gamble_set[,!(names(df_gamble_set) == "dup")]
df_gamble_set <- df_gamble_set[,c("id", "x", "px", "y", "py", "ev", "var")]



#### Pairs of gambles (risky Option vs. Safe Option) = stimuli
# create stimuli (gamble combinations), where the two gambles have equal EVs and different variances (min difference defined above)

# all possible combinations
ev <- NULL
var <- NULL
pairs <- matrix(ncol=6, nrow = nrow(t(combn(max(df_gamble_set$id),2))))
pairs[,1:2] <- t(combn(max(df_gamble_set$id), 2))
colnames(pairs) <- c("id1","id2","ev1","ev2","var1","var2")

m <- 3
n <- 5
for(j in 1:2){
  for(i in 1:length(pairs[,j])){
    a <- which(df_gamble_set$id == pairs[i,j])
    ev <- df_gamble_set$ev[a]
    var <- df_gamble_set$var[a]
    pairs[i,m] <- ev
    pairs[i,n] <- var
  }
  m <- m + 1
  n <- n + 1
}

# Delete combinations with different EVs and differences in variances < mindiff_var
df_pairs <- as.data.frame(pairs)

df_pairs <- df_pairs[which(df_pairs$ev1 == df_pairs$ev2),]
df_pairs <- df_pairs[which(abs(df_pairs$var1 - df_pairs$var2) > mindiff_var),]

df_pairs$id <- 1: nrow(df_pairs)
df_pairs <- df_pairs[,c("id", "id1", "id2", "ev1", "ev2", "var1", "var2")]


#### Table including Stimuli (pairs/gamble combinations), bugdet and proportion of bad rows
# Budget --> Amount of points you have to reach within t trials.
# Proportion of bad rows --> proportion of state, trial combinations where the optimal policy says 0 or 1 for both gambles.

## Range budget
#b min = minimal outcome of the two options * t (trials)
#b max = maximal outcome of the two options * t (trials)
#t = 5 --> defined at the beginning
out_total <- c(NULL)
out <- c(NULL)
bmin <- c(NULL)
bmax <- c(NULL)
for(i in 1:nrow(df_pairs)){
  for(j in 2:3){
    a <- which(df_gamble_set$id == df_pairs[i,j])
    x1 <- df_gamble_set[df_gamble_set$id == a,"x"]
    y1 <- df_gamble_set[df_gamble_set$id == a,"y"]
    out <- c(x1,y1)
    out_total <- c(out_total, out)
  }
  min_out <- min(out_total)*t + 1 #minimal goal that is not reachable for sure (1 larger than t*min)
  max_out <- max(out_total)*t
  bmin <- c(bmin, min_out)
  bmax <- c(bmax, max_out)
  out_total <- NULL
}

df_pairs$bmin <- bmin
df_pairs$bmax <- bmax

### Combination of Gamble pairs with same expected value and different vaiance
### Taking all gamble pairs in df_pairs and putting them together out of df_gamble_set
### Afterwards prediction of probability to pick either option (hm1988 function)through all state and trial combinations
# xx_r ending = risky option
# bid = budget id 
# s = states (gained points in the simulation in trial = t)
# t = trial in the simulation
# ps = probability of (reaching the budget when) choosing the safe option 
# pr = probability of (reaching the budget when) choosing risky option (if probability = 1 for both it does not matter to reach the budget(= goal))
df_pairs <- as.data.table(df_pairs)
df_gamble_set <- as.data.table(df_gamble_set)
res <- NULL
for (i in 1:nrow(df_pairs)) {
  gamble1 <- df_gamble_set[id == df_pairs$id1[i]]
  gamble2 <- df_gamble_set[id == df_pairs$id2[i]]
  budgets <- df_pairs$bmin[i]:df_pairs$bmax[i] # taking all possible budgets (budget = goals) per gamble (from minimal budget to maximal budget)
  pair_id <- as.data.table(df_pairs$id[i]) # taking pair_id to make every gamble identifiable through pair_id + bid (= budget_id)
  if(gamble1$var > gamble2$var){ # renaming variables depending on which gamble is risky (xx_r ending = risky gamble)
    setnames(gamble1, c("id", "x", "px", "y", "py", "ev", "var"),c("id_r","x_r", "px_r", "y_r", "py_r", "ev_r", "var_r"))
  } else{
    setnames(gamble2, c("id", "x", "px", "y", "py", "ev", "var"),c("id_r","x_r", "px_r", "y_r", "py_r", "ev_r", "var_r")) 
  }
  gambles <- cbind(gamble1,gamble2, b = budgets, bid = 1:length(budgets), pairid = pair_id)
 # setnames(gambles, c("V1"), c("pairid"))
  
  # simulating choices for all trials and all states (states of points reached in trials before), and all budgets
  M <- hm1988(formula = ~ x+px+y+py | x_r+px_r+y_r+py_r,
              trials = ".ALL", states = ".ALL" , budget = ~b , ntrials = 5,
              initstate = 0, data = gambles, choicerule = NULL)

  sim <- data.table(
            s = M$get_states(), #states = accumulated points in trials beforehand
            t = 6-M$get_timehorizons(), # 6- m$get_timehorizon = number of trials, as get_timehorizon = trials left
            predict(M) # predict = prediction of choice
             )
  setnames(sim, c("xp", "x_"), c("ps", "pr"))
  sim$bid <- cumsum(sim$t == 1) #cumulative sum of every time t = 1 -> generates bid (budgetid), as every new budget starts when t=1 (=first trial)  
  res <- rbind(res, merge(sim, gambles, by = "bid"))
  }

### writing csv file (to store, and reload without having to run the code above, to save time)
fwrite(res, file = "all_stimuli.csv")

res <- fread(file = "all_stimuli.csv")

# ### 23.3.2021 (zur abklärung meiner Veränderungen)
# df_pairs <- as.data.table(df_pairs)
# df_gamble_set <- as.data.table(df_gamble_set)
# out <- NULL
# for (i in 1:nrow(df_pairs)) {
#   gamble1 <- df_gamble_set[id == df_pairs$id1[i]]
#   gamble2 <- df_gamble_set[id == df_pairs$id2[i]]
#   budgets <- df_pairs$bmin[i]:df_pairs$bmax[i]
#   if(gamble1$var > gamble2$var){
#     setnames(gamble1, c("id", "x", "px", "y", "py", "ev", "var"),c("id_r","x_r", "px_r", "y_r", "py_r", "ev_r", "var_r"))
#   } else{
#     setnames(gamble2, c("x", "px", "y", "py"),c("x_r", "px_r", "y_r", "py_r")) 
#   }
#   gambles <- cbind(gamble1,gamble2,b = budgets, id = 1:length(budgets))
#   
#   M <- hm1988(formula = ~ x+px+y+py | x_r+px_r+y_r+py_r,
#               trials = ".ALL", states = ".ALL" , budget = ~b , ntrials = 5,
#               initstate = 0, data = gambles, choicerule = NULL)
#   
#   sim <- data.table(s = M$get_states(),
#                     t = 6-M$get_timehorizons(),
#                     predict(M)
#   )
#   setnames(sim, c("xp", "x_"), c("ps", "pr"))
#   sim$bid <- cumsum(sim$t == 1)
#   out <- rbind(out, merge(sim, gambles, by = "bid"))
# }


