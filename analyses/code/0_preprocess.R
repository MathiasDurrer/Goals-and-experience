## ==========================================================================
# Preprocesses the raw data of the choices
# ==========================================================================

# ==========================================================================
# Before you start: set working directora to THIS source file's location
if(.Platform$GUI == "RStudio") setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# ==========================================================================

# Load packages and install missing packages in one go
pacman::p_load(data.table)
library(cognitivemodels)

# load data ----------------------------------------------------------------

d <- rbind(fread("../../data/raw/choices1.csv"),
           fread("../../data/raw/choices2.csv"))


# Clean data ----------------------------------------------------------------
# 1. Rename column names
setnames(d, gsub("player.|participant.", "", names(d)))
setnames(d, c("code", "state6"), c("id", "terminal_state"))
# 2. Remove participants but store their IDs in a new data object
#    Helper function, saves IDs in list rm_list & removes them from data
rm_list <- list() # initialize
save_remove <- function(data, ids, reason) {
  ids <- unique(ids)
  rm_list[[reason]] <<- data.table(ids)
  return(data[!id %in% ids])
}
# * IDs who never started (time_started is NA)
d <- save_remove(d, d[is.na(time_started)]$id, "not starting")
# * IDs who never finished (_index_in_pages < 259)
d <- save_remove(d, d[`_index_in_pages` < 259]$id, "incomplete experiment")
# * Who did not really sample (all sample1 variables are NA)
d <- save_remove(d, d[, all(is.na(sample1)), by = id][V1==TRUE]$id, "zero sampling")
# * Who misunderstood the task (by hand we know the ID)
d <- save_remove(d, "gy3mh7mq", "misunderstanding the task")


# Reformat/melt data --------------------------------------------------------
idcols <- c("id", "phase", "stimulus1", "stimulus0", "budget", "terminal_state", "success", "successes") #add goal_condition in actual experiment data
sample_d <- melt(d, id = idcols,
  measure = patterns("sample[1-9]", "draw[1-9]", "sample_rt_ms[1-9]"),
  value.name =     c("risky_choice", "draw",     "rt_ms"),
  variable.name = "trial",  variable.factor = FALSE,
  na.rm = TRUE)
choice_d <- melt(d, id = idcols,
  measure = patterns("choice[1-9]", "state[1-9]", "^rt_ms[1-9]"),
  value.name =     c("risky_choice", "state",     "rt_ms"),
  variable.name = "trial", variable.factor = FALSE)
d <- rbindlist(
  list(sample = sample_d, goal = choice_d),   # named list holding 2 data sets
  id = "task",                                # adds "task" col. with list names
  fill = TRUE)                                # add non-shared columns
d[, trial := as.numeric(trial)]

# Add columns
d[, goal_condition := ifelse(
  id %in% c("b2yros5m", "clnudoem"), "hidden", "shown")]
d[, risky_choice := 1 - risky_choice]

# Add stimuli ---------------------------------------------------------------
stimuli <- rbindlist(lapply(list.files("../../experiment/code/rsft-gain-loss-experiment-master/rsft_goals_and_experience_experiment/static/stimuli", full = T), fread), id = "stimulus_type")
stimuli[, stimulus_type := factor(stimulus_type, labels = c("familiarization", "easy", "hard", "medium"))]
stimuli[, stimulus_id := paste(x1HV, p1HV*100, x2HV, x1LV, p1LV*100, x2LV, budget, sep = "_")]
stimuli[, attention_check := ifelse(.I %in% c(7,15,23), TRUE, FALSE)]
stimuli[, rare_event := ifelse(pmin(p1HV,p2HV) <= 0.20, TRUE, FALSE)]

# Mege choice and stimuli
d[, stimulus_id := paste(stimulus0, stimulus1, budget, sep ="_")]
d <- merge(d, stimuli[, !"state"], all = T, by = c("stimulus_id", "budget"))


# Cosmetics ------------------------------------------------------------------
# Re-order columns
setcolorder(d, c("id", "phase", "goal_condition", "task", "budget", "stimulus0", "stimulus1", "trial", "risky_choice", "rt_ms", "draw", "state"))


# Run attention check ---------------------------------------------------------
a <- d[attention_check == TRUE & phase != "familiarization" & task == "goal"]
M <- hm1988( ~ x1HV + p1HV + x2HV + p2HV | x1LV + p1LV + x2LV + p2LV, 
             trials = ~trial, states = ~state, budget = ~budget, init = 0,
             ntrials = 5, data = a)
a <- cbind(a, predict(M, type = "value"))
a[, dominance := ifelse(x1H %in% c(0,1) & x1L %in% c(0,1), "clear", "vague")]
# The ids who failed 50% of the 'clear' attention check choices for one type
id_failed_attention <- a[dominance == "clear",
    .(p_right = mean(risky_choice == x1H)),
    by = .(stimulus_type, id)
  ][,
    .(min_p_right = min(p_right)),
    by = .(id)
  ][min_p_right < 0.50,
    id
  ]
# Remove those IDs and store them
d <- save_remove(d, id_failed_attention, "failed attention checks")
# At the end, we want to tabulate the removed IDs
rbindlist(rm_list, id = "reason")[, .N, by = reason]


# Exclude attention check and familiarization trials -----------------------
d <- d[attention_check == FALSE & phase != "familiarization"]

# Cosmetics ---------------------------------------------------------------- 
setcolorder(d, c("id", "phase", "goal_condition", "task", "budget", "stimulus0", "stimulus1", "trial", "risky_choice", "rt_ms", "draw", "state"))

# Store
fwrite(d, "../../data/processed/data.csv")