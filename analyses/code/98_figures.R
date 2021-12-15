source("99_setup_fig.R")
source("0_preprocess.R", encoding = "utf-8")

d[, stimulus_type := factor(stimulus_type, levels = c("easy", "medium", "hard"))]
#
# Samples --------------------------------------------------------------------
#
aggd1 <- d[, 
    .(m = mean(risky_choice),
      n = .N),
    by = .(id, task, goal_condition, stimulus_type, stimulus0,stimulus1,budget, rare_event)][,
    .(m_choices = mean(m),
      m_samples = mean(n)),
    by = .(id, task, goal_condition, stimulus_type, rare_event)]


aggd <- aggd1[,
    .(m_choices = mean(m_choices),
      sd_m_choices = sd(m_choices),
      m_samples = mean(m_samples),
      sd_m_samples = sd(m_samples)),
    by = .(task, goal_condition)]
fig <- ggplot(aggd[task == "sample"], aes(x = goal_condition)) +
    geom_errorbar(aes(ymin = m_samples, ymax = m_samples + sd_m_samples), width = 0.1, position = position_dodge(width = .4)) +
    geom_col(aes(y = m_samples), color = "black", position = "dodge", width = .4, show.legend = FALSE) +
    labs(title = "Number of Samples", fill = "Difficulty", y = "N Samples", x = "Condition: goal was ...") +
    scale_y_continuous(expand = c(0,0))
ggsave("../figures/fig1.png", fig, w = 4, h = 4)

aggd <- aggd1[,
    .(m_choices = mean(m_choices),
      sd_m_choices = sd(m_choices),
      m_samples = mean(m_samples),
      sd_m_samples = sd(m_samples)),
    by = .(task, goal_condition, stimulus_type)]
sample_p <- ggplot(aggd[task == "sample"], aes(x = goal_condition, fill = stimulus_type)) +
    geom_errorbar(aes(ymin = m_samples, ymax = m_samples + sd_m_samples), width = 0.1, position = position_dodge(width = .4)) +
    geom_col(aes(y = m_samples), color = "black", position = "dodge", width = .4, show.legend = FALSE) +
    labs(title = "Number of Samples", fill = "Difficulty", y = "N Samples", x = "Condition: goal was ...") +
    scale_y_continuous(expand = c(0,0))

choice_p <- ggplot(aggd[task == "sample"], aes(x = goal_condition, fill = stimulus_type)) +
    geom_errorbar(aes(ymin = m_choices - sd_m_choices, ymax = m_choices + sd_m_choices), width = 0.1, position = position_dodge(width = .9)) +
    geom_point(aes(y = m_choices), position = position_dodge(width = .9), shape = 21, size = 4) +
    labs(title = "Proportion of Risky Choices", fill = "Difficulty", y = "% Risky Choices", x = "Condition: goal was ...") +
    scale_y_continuous(expand = c(0,0), limits = c(0,1))

fig1 <- sample_p + choice_p + plot_layout(guides = "collect")
ggsave("../figures/fig2.png", fig1, w = 10, h = 4)



######
aggd <- aggd1[,
    .(m_choices = mean(m_choices),
      sd_m_choices = sd(m_choices),
      m_samples = mean(m_samples),
      sd_m_samples = sd(m_samples)),
    by = .(task, stimulus_type, rare_event)]
aggd[, stimulus_type := factor(stimulus_type, levels = c("easy", "medium", "hard"))]
aggd[, rare_event := factor(rare_event, labels = c("no RE", "with RE"))]

sample_p <- ggplot(aggd[task == "sample"], aes(x = rare_event, fill = stimulus_type)) +
    geom_errorbar(aes(ymin = m_samples, ymax = m_samples + sd_m_samples), width = 0.1, position = position_dodge(width = .4)) +
    geom_col(aes(y = m_samples), color = "black", position = "dodge", width = .4, show.legend = FALSE) +
    labs(title = "Number of Samples", fill = "Difficulty", y = "N Samples", x = "Stimulus had rare event") +
    scale_y_continuous(expand = c(0,0))

choice_p <- ggplot(aggd[task == "sample"], aes(x = rare_event, fill = stimulus_type)) +
    geom_errorbar(aes(ymin = m_choices - sd_m_choices, ymax = m_choices + sd_m_choices), width = 0.1, position = position_dodge(width = .9)) +
    geom_point(aes(y = m_choices), position = position_dodge(width = .9), shape = 21, size = 4) +
    labs(title = "Proportion of Risky Choices", fill = "Difficulty", y = "% Risky Choices", x = "Stimulus had rare event") +
    scale_y_continuous(expand = c(0,0), limits = c(0,1))


fig2 <- sample_p + choice_p + plot_layout(guides = "collect")
ggsave("../figures/fig2.png", fig2, w = 10, h = 4)


# Plot Stimuli ----------------------------------------------------------------
library(cognitivemodels)
stimuli$trial <- 1
M <- hm1988(~ x1HV + p1HV + x2HV + p2HV | x1LV + p1LV + x2LV + p2LV, trial = "trial", ntrials = 5, init = 0, state = "state", budget = "budget", choicerule = "argmax", data = stimuli)
stimuli[, value_risky := predict(M, type = "value")[, "x1H"]]
stimuli[, value_safe := predict(M, type = "value")[, "x1L"]]

sagg <- stimuli[attention_check == F,
as.list(c(range(pmax(value_risky, value_safe)), range(budget))), by = stimulus_type][stimulus_type != "familiarization"]
sagg[, budget_range := paste(V3, V4, sep = " - ")]
sagg[, stimulus_type := factor(stimulus_type, levels = c("easy", "medium", "hard"))]
sagg[, budget_range := paste(V3, V4, sep = " - ")]
sagg[, budget_range := factor(budget_range, levels = sagg[order(stimulus_type), budget_range])]
library(scales)
fig0 <- ggplot(sagg, aes(x = budget_range, color  = stimulus_type)) +
  geom_segment(aes(y = V1-0.005, yend = V2+0.005, xend = budget_range), size = 3) +
    labs(x = "Goal Range", y = "Chance to reach goal", color = "Difficulty") +
    scale_y_continuous(expand = c(0,0), labels = percent_format())  +
    theme(aspect.ratio = 1.5, legend.position = c(.9,.8), legend.background = element_rect(color = "black"))
fig0
ggsave("../figures/fig0.png", fig0, w = 4, h = 4)