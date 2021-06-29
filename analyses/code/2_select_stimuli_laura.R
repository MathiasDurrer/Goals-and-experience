#### select stimuli
# Use the overview created with 1_create_stimuli.R
# Remember: Used Outcomes and probabilites to create the overview file
# gamble_set <- expand.grid(x = 1:8, px = c(.1, .2, .25, .3, .4, .50, .6, .7, .75, .8 , .8, .9), y = 1:9)
# minimal difference between the variances --> > 5


### Packages for hm1988 (hm1988() --> Function to caluculate the optimal policy for the stimuli)
library(devtools)
library(cogscimodels)
library("cogsciutils")
f <- function(state, budget) as.numeric(state >= budget)


## first load Stimuli_overview_gain.csv and adjust the name of the files in the write.table() and then run the code
## second load Stimuli_overview_loss.csv and adjust the name of the files in the write.table() and then run the code

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

overview_total <- read.table("../materials/stimuli/archive/200130_Stimuli_overview_gain.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
#overview_total <- read.table("../materials/stimuli/archive/200130_Stimuli_overview_loss.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))

#### Create different files for different difficulty categories

## Difficulty categories boundaries
diff_untere_grenze <- c(0.1,0.2,0.4,0.6,0.8)
diff_obere_grenze <- c(0.2,0.4,0.6,0.8,0.9)


## clean  --> pbad < 0.4 (delete all pairs with proportion of bad rows > 0.4)
# For Perceptual matching we took 0.5 because the strict restriction (0.4) we had no stimuli left that met our other requirements (defined in the stimuli_matching.R)
# For mathematical matching we took 0.4 (see 3_match_stimuli_math)
is.integer0 <- function(x)
{
  is.integer(x) && length(x) == 0L
}

## Create files
nrow(overview_total)
drops <- which(overview_total$pbad > 0.5)
overview_total <- overview_total[-drops,]


for(i in 1:length(diff_obere_grenze)){
  drops <- which(overview_total$dop1 > diff_obere_grenze[i])
  if(is.integer0(drops) == FALSE) {
    overview_total1 <- overview_total[-drops,]
  } else {
    overview_total1 <- overview_total
  }

  drops <- which(overview_total1$dop2 > diff_obere_grenze[i])
  if(is.integer0(drops) == FALSE) {
    overview_total1 <- overview_total1[-drops,]
  } else {
    overview_total1 <- overview_total1
  }
  
  drops <- which(overview_total1$dop2 < diff_untere_grenze[i])
  if(is.integer0(drops) == FALSE) {
    overview_total1 <- overview_total1[-drops,]
  } else {
    overview_total1 <- overview_total1
  }

  drops <- which(overview_total1$dop1 < diff_untere_grenze[i])
  if(is.integer0(drops) == FALSE) {
    overview_total1 <- overview_total1[-drops,]
  } else {
    overview_total1 <- overview_total1
  }

# Calculate the proportion of states-trials-combinations where the optimal policy do not favor an option (a1 = a2)
  equalrows <- matrix(ncol = 3, nrow = nrow(overview_total1))
  z <- 1
  for ( j in c(overview_total1$nr)) {
    b <- overview_total1[overview_total1$nr == j, "b"]
    x1 <- overview_total1[overview_total1$nr == j, "x1"]
    y1 <- overview_total1[overview_total1$nr == j, "y1"]
    px1 <- overview_total1[overview_total1$nr == j, "px1"]
    py1 <- overview_total1[overview_total1$nr == j, "py1"]
    x2 <- overview_total1[overview_total1$nr == j, "x2"]
    y2 <- overview_total1[overview_total1$nr == j, "y2"]
    px2 <- overview_total1[overview_total1$nr == j, "px2"]
    py2 <- overview_total1[overview_total1$nr == j, "py2"]
  
    overview_total1[overview_total1$nr == j,]
    env <- rsenvironment(budget = b,
                        n.trials = 5,
                        initial.state = 0,
                        a1 = matrix(c(px1, py1, x1, y1), nc = 2),
                        a2 = matrix(c(px2, py2, x2, y2), nc = 2),
                        terminal.fitness = f)
  
    M <- hm1988(env, choicerule = NULL)
    res <- M$predict(action = 1)
  
    equal_tot <- 0
    for( l in 1:nrow(res)){
      if(res[l,1] == res[l,2]) {
        equal_tot <- equal_tot + 1
      } else {
        equal_tot <- equal_tot
      }
    }
  
    bad <- 0
    for( l in 1:nrow(res)){
      if(res[l,1] == 0 && res[l,2] == 0) {
        bad <- bad + 1
      } else if ( res[l,1] == 1 && res[l,2] == 1) {
        bad <- bad + 1
      } else {
        bad <- bad
      }
    }
  
    pequal_tot <- equal_tot/nrow(res)
    equal<- equal_tot - bad
    pequal <- equal/nrow(res)
  
    equalrows[z,] <-  rbind(j, pequal_tot, pequal)
    z <- z + 1
  }

  colnames(equalrows) <- c("nr", "pequal total", "pequal")
  df_equalrows <- as.data.frame(equalrows)
  # bad (a1 = a2 = 0 or a1 = a2 = 1) + pequal (a1 = a2 = between 0 and 1) + pequal total

  match(overview_total1$nr, df_equalrows$nr)
  overview_total1 <- merge(overview_total1, df_equalrows, by = 'nr')

  # Define the proportion rows where the optimal policy does not have to favor an option (the proportion of rows where rsft makes no prediction which option should be chosen)
  # (without 0 and 1) --> Delete all gamblecombinations where the proportion of rows is higher than your specification.
  drops <- which(overview_total1$pequal > .19)
  if(is.integer0(drops) == FALSE) {
    overview_total1 <- overview_total1[-drops,]
  } else {
    overview_total1 <- overview_total1
  }

  # Adjust the file name 
  if(diff_untere_grenze[i] == 0.1 && diff_obere_grenze[i] == 0.2 && mean(overview_total$ev) > 0){
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_gain_d10-d20_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.2 && diff_obere_grenze[i] == 0.4 && mean(overview_total$ev) > 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_gain_d20-d40_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.4 && diff_obere_grenze[i] == 0.6 && mean(overview_total$ev) > 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_gain_d40-d60_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.6 && diff_obere_grenze[i] == 0.8 && mean(overview_total$ev) > 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_gain_d60-d80_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.8 && diff_obere_grenze[i] == 0.9 && mean(overview_total$ev) > 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_gain_d80-d90_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.1 && diff_obere_grenze[i] == 0.2 && mean(overview_total$ev) < 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_loss_d10-d20_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.2 && diff_obere_grenze[i] == 0.4 && mean(overview_total$ev) < 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_loss_d20-d40_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.4 && diff_obere_grenze[i] == 0.6 && mean(overview_total$ev) < 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_loss_d40-d60_pb50.csv", sep=";", dec=".", row.names=F)
  } else if(diff_untere_grenze[i] == 0.6 && diff_obere_grenze[i] == 0.8 && mean(overview_total$ev) < 0) {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_loss_d60-d80_pb50.csv", sep=";", dec=".", row.names=F)
  } else {
    write.table(overview_total1, "../materials/stimuli/archive/Stimuli_loss_d80-d90_pb50.csv", sep=";", dec=".", row.names=F)
  }
}
  
  
  
