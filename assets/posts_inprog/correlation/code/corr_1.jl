# This file was generated, do not modify it. # hide
using TidierPlots
using TidierData
using Random
using DataFrames
using Makie

Random.seed!(123)
n = 200
x = randn(n)
y = 0.1 * x + randn(n)
df = DataFrame(x = x, y = y)

randy_pub_theme_dark = Theme(#hide
    fonts=(;regular="JetBrains Mono"),#hide
    backgroundcolor = :transparent,#hide
    Axis = (#hide
            backgroundcolor = :transparent,#hide
            leftspinevisible = false,#hide
            rightspinevisible = false,#hide
            topspinevisible = false,#hide
            bottomspinecolor = :white,#hide
            xticklabelcolor = :white,#hide
            xtickcolor = :white,#hide
            yticklabelcolor = :white,#hide
            ytickcolor = :white,#hide
            xgridcolor = :transparent,#hide
            ygridcolor = :transparent,#hide
            width = 468,#hide
            height = 365,#hide
            yticklabelpad = .8#hide
        ),#hide
    Scatter = (color = :white)#hide
) #hide
randy_pub_theme = Theme(#hide
    fonts=(;regular="JetBrains Mono"),#hide
    backgroundcolor = :transparent,#hide
    Axis = (#hide
            backgroundcolor = :transparent,#hide
            leftspinevisible = false,#hide
            rightspinevisible = false,#hide
            topspinevisible = false,#hide
            xgridcolor = :transparent,#hide
            ygridcolor = :transparent,#hide
            width = 468,#hide
            height = 365,#hide
            yticklabelpad = .8#hide
        ),#hide
      Scatter = (color = :black)#hide
) #hide
plot = ggplot(df) +
  geom_point(aes(x = :x, y = :y))

df_di = @chain df begin
  @mutate belowzero = x < 0
  @mutate jitter = (rand(!!n) - .5) / 20
  @mutate x_new = jitter + as_float(belowzero)
  @mutate label = belowzero ? "Low" : "High"
end

plot2 = ggplot(df_di) +
  geom_point(aes(x = :x_new, y = :y))

plot1_dark = plot + randy_pub_theme_dark #hide
plot1_light = plot + randy_pub_theme #hide
plot2_dark = plot2 + randy_pub_theme_dark #hide
plot2_light = plot2 + randy_pub_theme #hide

ggsave(plot2_dark, joinpath(@OUTPUT, "corr_plot1_dark.png")) # hide
ggsave(plot2_light, joinpath(@OUTPUT, "corr_plot1_light.png")) # hide