@def title = "Basics of Making Makie Themes for TidierPlots"
@def date = "09/08/2024"
@def tags = ["julia", "TidierPlots.jl"]

@def rss_pubdate = Date(2024, 09, 08)

## Themes

TidierPlots.jl has full support for Makie themes. For example:

```julia:themes_1
using TidierPlots
using Random
using DataFrames

Random.seed!(123)
n = 200
df = DataFrame(x = randn(n) / 2, y = randn(n))

plot1 = ggplot(df) +
    geom_histogram(aes(x = :x),
      color = (:orangered, 0.5),
      strokewidth = 0.5) +
    lims(x = c(-4, 4)) + theme_minimal() # theme_minimal is from Makie

ggsave(plot1, joinpath(@OUTPUT, "themes_plot1.png")) # hide
```

\fig{themes_plot1}

Lets make this plot fit a little better with the monospace theme we've got going on this site. First - the most obvious change. We need to change the font.

```julia:themes_2
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
```
\fig{themes_plot2}

The syntax looks a little funny if you're coming from R, so it's worth a little detour to talk about which elements can be used in themes, and how to pass them in. Makie themes can contain settings for the Attributes of any object. To change the font, we want to edit the ["fonts" Attribute](https://docs.makie.org/stable/reference/plots/text#fonts) of the Figure which says it needs a "dictionary" that ties font styles (e.g. "regular") to fonts ("JetBrains Mono"). I honestly don't know why it says it wants a dictionary and then demands a named tuple instead, but that's the way it works. For more info, see the explanation [here](https://docs.makie.org/stable/explanations/fonts).

Edits to the overall figure are done directly within the Theme call, while changes to ["Blocks"](https://docs.makie.org/stable/explanations/blocks) are done within a "UppercaseBlockName = (tuple of Attributes)" argument to Theme. We're going to need to change a lot of options for Axis (whose Attributes are listed [here](https://docs.makie.org/stable/reference/blocks/axis#attributes) in order to make this theme look right. Lets start by getting rid of the background and all of the axis lines except the bottom.

```julia:themes_3
randy_pub_theme = Theme(
    fonts=(;regular="JetBrains Mono"),
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
```
\fig{themes_plot3}

Notice that there are two different calls to "background = :transparent". The one inside the Axis group makes the Axis background transparent, and the one at the base level makes the figure's background transparent.

We need to tweak the colors now for dark mode:

```julia:themes_4
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
```
\fig{themes_plot4}

Success! There's lots more than can be done here but I'm happy with the basic look. We can use a little html to swap out the theme based on user's dark mode setting:

~~~
<picture>
  <source
    srcset="/assets/posts/themes/code/output/themes_plot4.png"
    media="(prefers-color-scheme: dark)"
  />
  <img
    src="/assets/posts/themes/code/output/themes_plot3.png"
  />
</picture>
~~~

---
