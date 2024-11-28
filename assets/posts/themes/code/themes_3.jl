# This file was generated, do not modify it. # hide
using TidierPlots #hide
using Random #hide
using DataFrames #hide
using Makie #hide

Random.seed!(123) #hide
n = 200 #hide
df = DataFrame(x = randn(n) / 2, y = randn(n)) #hide

randy_pub_theme = Theme(
    fonts=(;regular="JuliaMono-Light"),
    backgroundcolor = :transparent,
    Axis = (
            backgroundcolor = :transparent,
            leftspinevisible = false,
            rightspinevisible = false,
            topspinevisible = false,
            xgridcolor = :transparent,
            ygridcolor = :transparent,
        )
)

plot3 = ggplot(df) +
    geom_histogram(aes(x = :x),
      color = (:transparent, 0.5), strokewidth = 1) +
    lims(x = c(-4, 4)) + randy_pub_theme

ggsave(plot3, joinpath(@OUTPUT, "themes_plot3.png")) # hide