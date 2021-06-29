### gain loss stimuli matching by optimal policy
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
### Alle write.table() sind auskommentiert


## Function for drops
is.integer0 <- function(x)
{
  is.integer(x) && length(x) == 0L
}


for( k in 1:5){
  if(k == 1){
    gain <- read.table("../materials/stimuli/archive/Stimuli_gain_d10-d20_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
    loss <- read.table("../materials/stimuli/archive/Stimuli_loss_d10-d20_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
  } else if(k == 2){
    gain <- read.table("../materials/stimuli/archive/Stimuli_gain_d20-d40_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
    loss <- read.table("../materials/stimuli/archive/Stimuli_loss_d20-d40_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
  } else if(k == 3){
    gain <- read.table("../materials/stimuli/archive/Stimuli_gain_d40-d60_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
    loss <- read.table("../materials/stimuli/archive/Stimuli_loss_d40-d60_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
  } else if(k == 4){
    gain <- read.table("../materials/stimuli/archive/Stimuli_gain_d60-d80_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
    loss <- read.table("../materials/stimuli/archive/Stimuli_loss_d60-d80_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
  } else if(k == 5){
    gain <- read.table("../materials/stimuli/archive/Stimuli_gain_d80-d90_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
    loss <- read.table("../materials/stimuli/archive/Stimuli_loss_d80-d90_pb50.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
  }
  


  og <- read.table("../materials/stimuli/archive/200130_Stimuli_overview_gain.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
  ol<- read.table("../materials/stimuli/archive/200130_Stimuli_overview_loss.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))


### Remove rows with proportion of bad rows (1 or 0 for a1 and a2) > 0.4
  if (mean(gain$dop1) < .6) {
    drops <- which(gain$pbad > 0.40)
    gain <- gain[-drops,]
  } else {
    gain <- gain
  }
  
  if (mean(loss$dop1) < .6) {
    drops <- which(loss$pbad > 0.40)
    loss <- loss[-drops,]
  } else {
    loss <- loss
  }



### match loss and gain stimuli by exact difficulty, pbad, pequal, pequal.total, variances
  loss$high_var <- pmax(loss$var1, loss$var2)
  gain$high_var <- pmax(gain$var1, gain$var2)
  loss$low_var <- pmin(loss$var1, loss$var2)
  gain$low_var <- pmin(gain$var1, gain$var2)
  
  merged <- merge(gain, loss, by = c( "dop1", "dop2", "pbad", "pequal", "pequal.total","high_var", "low_var"), suffixes = c("_g","_l"))
  head(merged)


  newdata1 <- merged[ ,c("nr_g", "nr_l","ev1_g", "ev1_l" ,"x1_g", "px1_g", "y1_g", "var1_g", "x2_g", "px2_g",
                        "y2_g", "var2_g", "x1_l", "px1_l","y1_l","var1_l", "x2_l", "px2_l", "y2_l", "var2_l",
                        "b_g", "b_l", "dop1", "dop2", "pbad", "pequal", "pequal.total",
                        "low_var", "high_var")]
  

  # separate dataframe for each difficulty category
  if (mean(gain$dop1) > .1 && mean(gain$dop1) < .2) {
    merged1020 <- newdata1
  } else if( mean(gain$dop1) > .2 && mean(gain$dop1) < .4) {
    merged2040 <- newdata1
  } else if( mean(gain$dop1) > .4 && mean(gain$dop1) < .6) {
    merged4060 <- newdata1
  } else if( mean(gain$dop1) > .6 && mean(gain$dop1) < .8) {
    merged6080 <- newdata1
  } else {
    merged8090 <- newdata1
  }
}

# Combine dataframes
library(dplyr)
merged_tot <- bind_rows(merged1020, merged2040)
merged_tot <- bind_rows(merged_tot, merged4060)
merged_tot <- bind_rows(merged_tot, merged6080)
merged_tot <- bind_rows(merged_tot, merged8090)
nrow(merged_tot)


### Remove stimuli with difficulty > 0.85 and difficulty < 0.4 because we want medium and hard stimuli
# but the difficulty of the stimuli selected by mathmatical matching should be compariable to difficulty of the stimuli selected by perceptual matching.
# Thus the lower boundary for difficulty is set to 0.4.
drops <- which(merged_tot$dop1 < 0.38)
if(is.integer0(drops) == FALSE) {
  merged_tot <- merged_tot[-drops,]
} else {
  merged_tot <- merged_tot
}

drops <- which(merged_tot$dop2 < 0.38)
if(is.integer0(drops) == FALSE) {
  merged_tot <- merged_tot[-drops,]
} else {
  merged_tot <- merged_tot
}


drops <- which(merged_tot$dop1 > 0.85)
if(is.integer0(drops) == FALSE) {
  merged_tot <- merged_tot[-drops,]
} else {
  merged_tot <- merged_tot
}

drops <- which(merged_tot$dop2 > 0.85)
if(is.integer0(drops) == FALSE) {
  merged_tot <- merged_tot[-drops,]
} else {
  merged_tot <- merged_tot
}
max(merged_tot$dop1)

drops <- which(merged_tot$dop1 & merged_tot$dop2 > 0.80)
if(is.integer0(drops) == FALSE) {
  merged_tot <- merged_tot[-drops,]
} else {
  merged_tot <- merged_tot
}


# Define the minimal difficulty difference between easy and hard gambles
drops <- c(NULL)
drops1 <- which(merged_tot$dop2 < 0.70)
drops0 <- which(merged_tot$dop2 >= 0.54)
for(i in drops1){
  for(k in drops0){
    if(i == k){
      drops <- c(drops,k)
    } else {
      drops <- drops
    }
  }
}

if( is.null(drops)) {
  merged_tot <- merged_tot
} else {
  merged_tot <- merged_tot[-drops,]
}

 drops <- c(NULL)
 drops1 <- NULL
 drops0 <- NULL
 drops1 <- which(merged_tot$dop1 < 0.70)
 drops0 <- which(merged_tot$dop1 >= 0.54)
 for(i in drops1){
   for(k in drops0){
     if(i == k){
       drops <- c(drops,k)
     } else {
       drops <- drops
     }
   }
 }
 
 if( is.null(drops)) {
   merged_tot <- merged_tot
 } else {
   merged_tot <- merged_tot[-drops,]
 }

#### More restrictions to select the stimuli
# Remove stimuli with pequal (a1 = a2) > 75% percentile
drops <- which(merged_tot$pequal.total > quantile(merged_tot$pequal.total, probs = .75))
if(is.integer0(drops) == FALSE) {
  merged_tot <- merged_tot[-drops,]
} else {
  merged_tot <- merged_tot
}

# Remove if dop1 = dop2
# drops <- which(merged_tot$dop1 == merged_tot$dop2)
# if(is.integer0(drops) == FALSE) {
#   merged_tot <- merged_tot[-drops,]
# } else {
#   merged_tot <- merged_tot
# }

# More Restriction, because there are enough stimuli left -> Remove stimuli with
# equal rows > 51%
drops <- which(merged_tot$pequal.total > 0.51)
if(is.integer0(drops) == FALSE) {
  merged_tot <- merged_tot[-drops,]
} else {
  merged_tot <- merged_tot
}


#### Difficulty Category
merged_tot$difficulty <- cut(merged_tot$dop1, c(0.1, 0.2, 0.4, 0.6, 0.8, 0.9), include.lowest = T)

#### ID
idg <- NULL
for ( i in c(merged_tot$nr_g)) {
  id <- og[og$nr == i, "id"]
  idg <- c(idg, id)
}
 idl <- NULL
for ( i in c(merged_tot$nr_l)) {
  id <- ol[ol$nr == i, "id"]
  idl <- c(idl, id)
}

merged_tot$id_g <- idg
merged_tot$id_l <- idl

# Order and Save
merged_tot <- merged_tot[ ,c("difficulty","nr_g", "nr_l","id_g","id_l","ev1_g","ev1_l", "x1_g", "px1_g",  "y1_g", "x2_g", "px2_g",
                        "y2_g", "x1_l", "px1_l","y1_l", "x2_l", "px2_l", "y2_l",
                        "b_g", "b_l", "dop1", "dop2", "pbad","pequal", "pequal.total")]


merged_tot <- merged_tot[order(merged_tot$difficulty, merged_tot$dop1, merged_tot$dop2, merged_tot$pbad,
                               merged_tot$pequal),]


#write.table(merged_tot, "../materials/stimuli/archive/merged_short_math.csv", sep=";", dec=".", row.names=F)
merged_tot <- read.table("../materials/stimuli/archive/merged_short_math.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))
nrow(merged_tot)

#### Select Stimuli 
# 3 hard, 3 easy
# hard: 0.4 - 0.55 easy > 70
merged_tot$K <- 1:nrow(merged_tot)


# we select 3 hard stimuli out of 5 hard stimuli --> 1,3,5
# we select 3 easy stimuli out of 14 easy stimuli --> I exclude stimuli, where the risky option and the save option have the same lowest outcome.
final <- merged_tot[c(1,3,5,6,9,12),]


#write.table(final, "final_overview_math.csv", sep=";", dec=".", row.names=F)
#final <- read.table("final_overview_math.csv", header=T, sep=";", as.is=T, na.strings=c("-77","-99","-66"))

### Final dataframe
final$py1_g <- 1 - final$px1_g
final$py2_g <- 1 - final$px2_g
final$py1_l <- 1 - final$px1_l
final$py2_l <- 1 - final$px2_l

final_gain <- final[ ,c("ev1_g","x1_g", "px1_g", "y1_g", "py1_g", "x2_g", "px2_g",
                        "y2_g","py2_g","b_g", "dop1", "dop2")]

final_loss <- final[ ,c("ev1_l","x1_l", "px1_l",  "y1_l", "py1_l", "x2_l", "px2_l",
                        "y2_l","py2_l", "b_l", "dop1", "dop2")]


# order by variance
final_gain$var1 <- (final_gain$x1_g - final_gain$ev1)^2 * final_gain$px1_g + 
  (final_gain$y1_g - final_gain$ev1)^2 * final_gain$py1_g

final_gain$var2 <- (final_gain$x2_g - final_gain$ev1)^2 * final_gain$px2_g + 
  (final_gain$y2_g - final_gain$ev1)^2 * final_gain$py2_g

final_loss$var1 <- (final_loss$x1_l - 1*final_loss$ev1)^2 * final_loss$px1_l + 
  (final_loss$y1_l - final_loss$ev1)^2 * final_loss$py1_l

final_loss$var2 <- (final_loss$x2_l - final_loss$ev1)^2 * final_loss$px2_l + 
  (final_loss$y2_l - final_loss$ev1)^2 * final_loss$py2_l


# Table: stimuli long
tab_final <- matrix(ncol = 15, nrow = 2*nrow(final_gain))

for(i in 1:nrow(final_gain)){
  if(final_gain[i, "var1"] > final_gain[i, "var2"]){
    tab_final [i,1] <- final_gain[i, "ev1_g"]
    tab_final [i,2] <- final_gain[i, "dop1"]
    tab_final [i,3] <- final_gain[i, "dop2"]
    tab_final [i,4] <- final_gain[i, "x1_g"]
    tab_final [i,5] <- final_gain[i, "px1_g"]
    tab_final [i,6] <- final_gain[i, "y1_g"]
    tab_final [i,7] <- final_gain[i, "py1_g"]
    tab_final [i,8] <- final_gain[i, "var1"]
    tab_final [i,9] <- final_gain[i, "x2_g"]
    tab_final [i,10] <- final_gain[i, "px2_g"]
    tab_final [i,11] <- final_gain[i, "y2_g"]
    tab_final [i,12] <- final_gain[i, "py2_g"]
    tab_final [i,13] <- final_gain[i, "var2"]
    
  } else {
    tab_final [i,1] <- final_gain[i, "ev1_g"]
    tab_final [i,2] <- final_gain[i, "dop2"]
    tab_final [i,3] <- final_gain[i, "dop1"]
    tab_final [i,4] <- final_gain[i, "x2_g"]
    tab_final [i,5] <- final_gain[i, "px2_g"]
    tab_final [i,6] <- final_gain[i, "y2_g"]
    tab_final [i,7] <- final_gain[i, "py2_g"]
    tab_final [i,8] <- final_gain[i, "var2"]
    tab_final [i,9] <- final_gain[i, "x1_g"]
    tab_final [i,10] <- final_gain[i, "px1_g"]
    tab_final [i,11] <- final_gain[i, "y1_g"]
    tab_final [i,12] <- final_gain[i, "py1_g"]
    tab_final [i,13] <- final_gain[i, "var1"]
    
  }
}

for(i in 1:nrow(final_loss)){
  if(final_loss[i, "var1"] > final_loss[i, "var2"]){
    tab_final [(nrow(final_loss) + i),1] <- final_loss[i, "ev1_l"]
    tab_final [(nrow(final_loss) + i),2] <- final_loss[i, "dop1"]
    tab_final [(nrow(final_loss) + i),3] <- final_loss[i, "dop2"]
    tab_final [(nrow(final_loss) + i),4] <- final_loss[i, "x1_l"]
    tab_final [(nrow(final_loss) + i),5] <- final_loss[i, "px1_l"]
    tab_final [(nrow(final_loss) + i),6] <- final_loss[i, "y1_l"]
    tab_final [(nrow(final_loss) + i),7] <- final_loss[i, "py1_l"]
    tab_final [(nrow(final_loss) + i),8] <- final_loss[i, "var1"]
    tab_final [(nrow(final_loss) + i),9] <- final_loss[i, "x2_l"]
    tab_final [(nrow(final_loss) + i),10] <- final_loss[i, "px2_l"]
    tab_final [(nrow(final_loss) + i),11] <- final_loss[i, "y2_l"]
    tab_final [(nrow(final_loss) + i),12] <- final_loss[i, "py2_l"]
    tab_final [(nrow(final_loss) + i),13] <- final_loss[i, "var2"]
  } else {
    tab_final [(nrow(final_loss) + i),1] <- final_loss[i, "ev1_l"]
    tab_final [(nrow(final_loss) + i),2] <- final_loss[i, "dop2"]
    tab_final [(nrow(final_loss) + i),3] <- final_loss[i, "dop1"]
    tab_final [(nrow(final_loss) + i),4] <- final_loss[i, "x2_l"]
    tab_final [(nrow(final_loss) + i),5] <- final_loss[i, "px2_l"]
    tab_final [(nrow(final_loss) + i),6] <- final_loss[i, "y2_l"]
    tab_final [(nrow(final_loss) + i),7] <- final_loss[i, "py2_l"]
    tab_final [(nrow(final_loss) + i),8] <- final_loss[i, "var2"]
    tab_final [(nrow(final_loss) + i),9] <- final_loss[i, "x1_l"]
    tab_final [(nrow(final_loss) + i),10] <- final_loss[i, "px1_l"]
    tab_final [(nrow(final_loss) + i),11] <- final_loss[i, "y1_l"]
    tab_final [(nrow(final_loss) + i),12] <- final_loss[i, "py1_l"]
    tab_final [(nrow(final_loss) + i),13] <- final_loss[i, "var1"]
  }
}

# budget
for(i in 1:nrow(final_loss)){
  tab_final[i,14] <- final_gain[i, "b_g"]
  tab_final[(nrow(final_loss) + i),14] <- final_loss[i, "b_l"]
}

tab_final <- as.data.frame(tab_final)
tab_final$V15 <- ifelse(tab_final$V4 > 0, "gain", "loss")

colnames(tab_final) <- c("ev","dh","dl","xh", "pxh", "yh", "pyh","varh", "xl", "pxl", "yl", "pyl", "varl", "budget", "domain")
tab_final$nr <- 1:nrow(tab_final)
tab_final$start <- 0


# Compare the model predictions in the gain and loss domain
source("../../analyses/code/rsft/Models.R")

for(i in 1:(nrow(tab_final)/2)){
  print(round(rsft_model(tab_final,i,5)[,3],15) == round(rsft_model(tab_final,nrow(tab_final)/2+i,5)[,3],15))
  print(round(rsft_model(tab_final,i,5)[,4],15) == round(rsft_model(tab_final,nrow(tab_final)/2+i,5)[,4],15))
}

tab_final$nr <- NULL
stimuli <- tab_final

# Save Stimuli to create Sprites

tab_final1 <- tab_final[ ,c("xh","yh", "pxh", "pyh", "xl", "yl", "pxl", "pyl", "budget", "start")]

colnames(tab_final1) <- c("x1HV", "x2HV", "p1HV", "p2HV", "x1LV", "x2LV", "p1LV", "p2LV", "budget","start")
write.table(tab_final1, "../materials/stimuli/archive/stimuli_sprites.csv", sep=",", dec=".", row.names=F)

#### Create Stimuli for State Domain
# State Domain
stimuli_negative <- stimuli
stimuli_negative$start <- stimuli_negative$budget * -1
stimuli_negative$budget <- 0

# row-bind them together
stimuli <- rbind(stimuli, stimuli_negative)
stimuli$nr <- 1:nrow(stimuli)

# I moved the rounding to here, and rounded a bit less strict
stimuli$dh <- round(stimuli$dh, 10)
stimuli$dl <- round(stimuli$dl, 10)

# Status Domain x Outcome Domain
# stimuli$domain <- ifelse(stimuli$budget > 0, "positive gain", stimuli$domain)
# stimuli$domain <- ifelse(stimuli$budget < 0, "negative loss", stimuli$domain)
# stimuli$domain <- ifelse(stimuli$start < 0, "negative gain", stimuli$domain)
# stimuli$domain <- ifelse(stimuli$start > 0, "positive loss", stimuli$domain)

stimuli$domain <- ifelse(stimuli$budget > 0, "positive gain", stimuli$domain)
stimuli$domain <- ifelse(stimuli$budget < 0, "negative loss", stimuli$domain)
stimuli$domain <- ifelse(stimuli$start < 0, "negative gain", stimuli$domain)
stimuli$domain <- ifelse(stimuli$start > 0, "positive loss", stimuli$domain)

#stimuli$diffcat <- ifelse(stimuli$dh > 0.6, "einfach", "schwierig")


write.table(stimuli, "../materials/stimuli/archive/Final_Stimuli_math.csv", sep=";", dec=".", row.names=F)


