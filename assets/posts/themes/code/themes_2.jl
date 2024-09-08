# This file was generated, do not modify it. # hide
using Makie

randy_pub_theme = Theme(
  fonts=(;regular="JetBrains Mono")
)

plot2 = ggplot(df) +
    geom_histogram(aes(x = :x),
      color = (:orangered, 0.5),
      strokewidth = 0.5) +
    lims(x = c(-4, 4)) + randy_pub_theme

ggsave(plot2, joinpath(@OUTPUT, "themes_plot2.png")) # hide