# This file was generated, do not modify it. # hide
using TidierPlots #hide
using Random #hide
using DataFrames #hide
using Makie #hide

juliamono = "https://cdn.jsdelivr.net/gh/cormullion/juliamono/webfonts/JuliaMono-Light.woff2" # hide

Random.seed!(123) #hide
n = 200 #hide
df = DataFrame(x = randn(n) / 2, y = randn(n)) #hide

randy_pub_theme = Theme(
    fonts=(;regular=juliamono),
    backgroundcolor = :transparent,
    Axis = (
            backgroundcolor = :transparent,
            leftspinevisible = false,
            rightspinevisible = false,
            topspinevisible = false,
            xgridcolor = :transparent,
            ygridcolor = :transparent,
            width = 468,
            height = 365,
            yticklabelpad = .25,
        ),
        Hist = (strokewidth = 1, bins = 21)
)

plot3a = ggplot(df) +
    geom_histogram(aes(x = :x),
      color = (:transparent, 0.5), strokewidth = 1) +
    lims(x = c(-4, 4), y = c(0, 30)) + randy_pub_theme

ggsave(plot3a, joinpath(@OUTPUT, "themes_plot3a.png")) # hide