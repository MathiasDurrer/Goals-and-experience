#### Create Stimuli
setwd("C:/Users/mathi/Desktop/Code MA/analysis/code")
getwd()
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load packages
library(devtools)
#install_github("janajarecki/cogscimodels", ref = "master")
#update.packages(checkBuilt = TRUE)
library(cognitivemodels)
library(cognitiveutils)




#### define smallest acceptable variance difference between the risky and the safe option
mindiff_var <- 5 #minimal variance difference


# Rsft Variables
t = 5 # Trails
f <- function(state, budget) as.numeric(state >= budget) #Reward function



#### Gamble set

## Table with all possible combinations of x and y Werte and px --> Separate for gain and loss domain
gamble_set <- expand.grid(x = -1:-8, px = c(.1 ,.2, .25, .3, .4, .5, .6, .7, .75, .8, .9), y = -1:-9)

df_gamble_set <- as.data.frame(gamble_set)
str(df_gamble_set)
length(gamble_set$x)


## calculate py
df_gamble_set$py <- (1 - df_gamble_set$px)


## caltulate EV and Var  --> VarG <- c((x - ev)^2 %*% p)

# ev
df_gamble_set$ev <- df_gamble_set$x * df_gamble_set$px + df_gamble_set$y * df_gamble_set$py

#var
df_gamble_set$var <- (df_gamble_set$x - df_gamble_set$ev)^2 * df_gamble_set$px + 
  (df_gamble_set$y - df_gamble_set$ev)^2 * df_gamble_set$py

df_gamble_set$var <- round(df_gamble_set$var, 4)


## remove duplicates
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
  min_out <- min(out_total)*t
  max_out <- max(out_total)*t
  bmin <- c(bmin, min_out)
  bmax <- c(bmax, max_out)
  out_total <- NULL
}

df_pairs$bmin <- bmin
df_pairs$bmax <- bmax


## Create table with rows = number of stimuli * Sum of all possible budgets

# define number of rows
cont <- c(NULL)
for( i in 1:nrow(df_pairs)){
  x <- length(df_pairs[df_pairs$id == i, "bmin"]:df_pairs[df_pairs$id == i, "bmax"])
  cont <- c(cont, x)
}


# Table
# b = budget; dop1/dop2 = difficulty; pbad = proportion of bad rows (optimal policy = 0 or 1 for both gambles/options)
budget_diff <- matrix(ncol= 5, nrow= sum(cont))
colnames(budget_diff) <- c("id", "b", "dop1", "dop2", "pbad")
z <- 1

for ( i in 1:nrow(df_pairs)) {
  a <- df_pairs[df_pairs$id == i, "bmin"]
  b <- df_pairs[df_pairs$id == i, "bmax"]
  op1 <- df_pairs[df_pairs$id == i,"id1"]
  op2 <- df_pairs[df_pairs$id == i,"id2"]
  
  x1 <- df_gamble_set[df_gamble_set$id == op1,"x"]
  y1 <- df_gamble_set[df_gamble_set$id == op1,"y"]
  px1 <- df_gamble_set[df_gamble_set$id == op1,"px"]
  py1 <- df_gamble_set[df_gamble_set$id == op1,"py"]
  
  x2 <- df_gamble_set[df_gamble_set$id == op2,"x"]
  y2 <- df_gamble_set[df_gamble_set$id == op2,"y"]
  px2 <- df_gamble_set[df_gamble_set$id == op2,"px"]
  py2 <- df_gamble_set[df_gamble_set$id == op2,"py"]
  
  
  for (j in c(a:b)) {
    env <- rsenvironment(budget = j,
                      n.trials = 5,
                      initial.state = 0,
                      a1 = matrix(c(px1, py1, x1, y1), nc = 2),
                      a2 = matrix(c(px2, py2, x2, y2), nc = 2),
                      terminal.fitness = f)

    M <- hm1988(choicerule = NULL, budget = j, ntrials = 5, formula = y ~ px1 + py1 + x1 + y1 | px2 + py2 + x2 + y2, trials = 5, states = 5)
    M
    res <- predict(M)
    predict(M, type = "values")
    dop1 <- predict(M, type = "values")[1,1]
    dop2 <- predict(M, type = "values")[1,2]
    #res <- M$predict(action = 1)
    #dop1 <- M$predict(action = 1)[1,1]
    #dop2 <- M$predict(action = 1)[1,2]
    
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
    
    pbad <- bad/nrow(res)
    budget_diff[z,] <-  rbind(i, j, dop1, dop2, pbad)
    z <- z + 1
    
  }
}

budget_diff

  
### Table include stimuli (consist of a pair of gambles), difficulty, %badrows, EV, Var1, Var2
# id --> Id of the stimuli (pair of gambles), b = Budget, dop1 = difficulty gamble 1, dop2 = difficulty gamble 2
# Ev = expected value (equal for both gambles/options), var1 = variance gamble 1, 
#var2 = variance gamble 2, pbad = proportion of rows with optimal policy = 1 or 0 for both gambles.
df_budget_diff <- as.data.frame(budget_diff)
drops <- c("bmin", "bmax")
df_pairs1 <- df_pairs[ , !names(df_pairs) %in% drops]

match(df_budget_diff$id, df_pairs1$id)
overview <- merge(df_budget_diff, df_pairs1, by = 'id')

# clean and rename
drops <- c("ev2")
overview <- overview[ , !names(overview) %in% drops]
overview <- overview[ ,c("id", "id1", "id2", "ev1", "var1", "var2", "b", "dop1", "dop2", "pbad")]
overview



#### Table including stimuli ID, the two gambles (options), their outcomes and probabilities, EV, var1, var2, b, dop1, dop2, pbad
df_gamble_set1 <- df_gamble_set
df_gamble_set1$id1 <- df_gamble_set1$id
drops <- c("ev", "var", "id")
df_gamble_set1 <- df_gamble_set1[ , !names(df_gamble_set1) %in% drops]

match(overview$id1, df_gamble_set1$id1)
overview_total <- merge(overview, df_gamble_set1, by = 'id1')
nrow(overview_total)

df_gamble_set2 <- df_gamble_set
df_gamble_set2$id2 <- df_gamble_set2$id
drops <- c("ev", "var", "id")
df_gamble_set2 <- df_gamble_set2[ , !names(df_gamble_set2) %in% drops]

match(overview_total$id2, df_gamble_set2$id2)
overview_total <- merge(overview_total, df_gamble_set2, by = 'id2')
nrow(overview_total)

# rename
names(overview_total)[names(overview_total) == "x.x"] <- "x1"
names(overview_total)[names(overview_total) == "px.x"] <- "px1"
names(overview_total)[names(overview_total) == "y.x"] <- "y1"
names(overview_total)[names(overview_total) == "py.x"] <- "py1"
names(overview_total)[names(overview_total) == "x.y"] <- "x2"
names(overview_total)[names(overview_total) == "px.y"] <- "px2"
names(overview_total)[names(overview_total) == "y.y"] <- "y2"
names(overview_total)[names(overview_total) == "py.y"] <- "py2"
overview_total$nr <- 1: nrow(overview_total)

# order of the colums
overview_total <- overview_total[ ,c("nr","id", "id1", "id2", "ev1", "x1", "px1","y1", "py1", 
                                     "x2", "px2", "y2", "py2" ,"var1", "var2", "b", "dop1", "dop2", "pbad")]

# Save --> Adjust name of the file for gain and loss
#write.table(overview_total, "../materials/stimuli/archive/200130_Stimuli_overview_loss.csv", sep=";", dec=".", row.names=F)
