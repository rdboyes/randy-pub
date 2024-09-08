# This file was generated, do not modify it. # hide
randy_pub_theme_dark = Theme(
    fonts=(;regular="JetBrains Mono"),
    backgroundcolor = :transparent,
    Axis = (
            backgroundcolor = :transparent,
            leftspinevisible = false,
            rightspinevisible = false,
            topspinevisible = false,
            bottomspinecolor = :white,
            xticklabelcolor = :white,
            xtickcolor = :white,
            yticklabelcolor = :white,
            ytickcolor = :white,
            xgridcolor = :transparent,
            ygridcolor = :transparent,
        ),
    Hist = (strokecolor = :white, strokewidth = 1,)
)

plot4 = ggplot(df) +
    geom_histogram(aes(x = :x),
      color = (:transparent, 0.5)) +
    lims(x = c(-4, 4)) + randy_pub_theme_dark

ggsave(plot4, joinpath(@OUTPUT, "themes_plot4.png")) # hide