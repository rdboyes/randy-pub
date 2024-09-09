# This file was generated, do not modify it. # hide
using TidierPlots
using Random
using DataFrames
using Makie

Random.seed!(123)
n = 200
df = DataFrame(x = randn(n) / 2, y = randn(n))

plot1 = ggplot(df) +
    geom_histogram(aes(x = :x),
      color = (:orangered, 0.5),
      strokewidth = 0.5) +
    lims(x = c(-4, 4)) + theme_minimal() # theme_minimal is from Makie

ggsave(plot1, joinpath(@OUTPUT, "themes_plot1.png")) # hide