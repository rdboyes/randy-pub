# This file was generated, do not modify it. # hide
using TidierPlots #hide
using Random #hide
using DataFrames #hide
using Makie #hide

Random.seed!(123) #hide
n = 200 #hide
df = DataFrame(x = randn(n) / 2, y = randn(n)) #hide

randy_pub_theme = Theme(
  fonts=(;regular="JetBrains Mono")
)

plot2 = ggplot(df) +
    geom_histogram(aes(x = :x),
      color = (:orangered, 0.5),
      strokewidth = 0.5) +
    lims(x = c(-4, 4)) + randy_pub_theme

ggsave(plot2, joinpath(@OUTPUT, "themes_plot2.png")) # hide