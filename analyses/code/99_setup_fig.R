# Setup the figures
pacman::p_load(showtext)
font_add_google("PT Sans Narrow", "PT Sans Narrow")
showtext_auto()
pacman::p_load(ggplot2, patchwork)

old_theme <- theme_classic()
theme_set(theme_classic(
  base_family = "PT Sans Narrow",
  base_size = 36,
  base_line_size = 0.4))
half_line <- 6
theme_update(
  axis.ticks.length = unit(1, units = "mm"),
  legend.margin = margin(half_line, half_line, half_line, half_line),
  plot.margin = margin(half_line, half_line, half_line, half_line),
  legend.key.size = unit(1, "lines"),
  legend.background = element_rect(size = 0.4))

v_ <- c(rgb(143, 175, 195, max = 255),
      rgb(166, 166, 166, max = 255),
      rgb(192, 0, 0, max = 255))

# Change default color scheme
scale_colour_discrete <- function(...) {
  scale_colour_manual(..., values = v_)
}
scale_fill_discrete <- function(...) {
  scale_fill_manual(...,values = v_)
}