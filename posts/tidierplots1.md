@def title = "Developing TidierPlots.jl, Part 1"
@def date = "09/02/2024"
@def tags = ["julia", "TidierPlots.jl"]

@def rss_pubdate = Date(2024, 09, 02)

---

## Making TidierPlots.jl

If you're unfamiliar, [TidierPlots](https://github.com/TidierOrg/TidierPlots.jl) is my attempt to build a more modern-feeling,
100% julia version of the popular R data visualization package [ggplot2](https://ggplot2.tidyverse.org/). This is my first julia package, and I have
already made quite a few mistakes in developing it. This series of posts will walk through my experience of transforming a script into a package, the problems
I've had, and the solutions I've come up with so far.

## Version 1

To start, I want to show you the basic idea of the package, as it existed when I first wrote out the original script. I had two structs:

```julia
using Makie, CairoMakie, AlgebraOfGraphics
using PalmerPenguins, DataFrames

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

struct geom
    visual::Union{Symbol, Nothing}
    aes::Dict
    args::Dict
    analysis::Any
    required_aes::AbstractArray
end

struct ggplot
    geoms::AbstractArray
    default_aes::Dict
    data::Symbol
    axis::NamedTuple
end
```

A method to add things to a `ggplot`, which essentially just adds any `geom` to an internal array inside the `ggplot`:

```julia
function Base.:+(x::ggplot, y...)::ggplot
    result = ggplot(vcat(x.geoms, [i for i in y]),
        x.default_aes,
        x.data,
        x.axis)

    return result
end
```

A function to turn arguments passed to a geom into two dictionaries, one for things inside `aes` and one for things outside of it:

```julia
function extract_aes(geom)
    aes_dict = Dict{String, Symbol}()
    args_dict = Dict{String, Any}()

    for section in geom
        if section isa Expr
            # if the section is an expression
            # check if it is a aes function call
            if section.args[1] == :aes
                for aes_ex in section.args
                    if aes_ex isa Expr
                        aes_dict[String(aes_ex.args[1])] = aes_ex.args[2]
                    end
                end
            # if not, its a generic argument
            else
                args_dict[String(section.args[1])] = section.args[2]
            end
        end
    end

    return (aes_dict, args_dict)
end
```

A couple of geom creation macros, which essentially build geom structs with the appropriate arguments:

```julia
macro geom_point(exprs...)
    geom_visual = :Scatter
    aes_dict, args_dict = extract_aes(:($(exprs)))
    analysis = nothing
    required_aes = ["x", "y"]
    return geom(geom_visual, aes_dict, args_dict, nothing, required_aes)
end

macro geom_smooth(exprs...)
    geom_visual = nothing
    aes_dict, args_dict = extract_aes(:($(exprs)))
    analysis = AlgebraOfGraphics.smooth
    required_aes = ["x", "y"]
    if haskey(args_dict, "method")
        if args_dict["method"] == "lm"
            analysis = AlgebraOfGraphics.linear
        end
    end
    return geom(geom_visual, aes_dict, args_dict, analysis, required_aes)
end
```

A way to convert the geom objects into `AlgebraOfGraphics` Layer objects:

```julia
function geom_to_layer(geom)
    mapping_args = (geom.aes[key] for key in geom.required_aes)

    layer = data(eval(geom.args["data"])) *
        mapping(mapping_args...)

    if !isnothing(geom.analysis)
        layer = layer * (geom.analysis)()
    end

    if !isnothing(geom.visual)
        layer = layer * visual(eval(geom.visual))
    end

    if haskey(geom.aes, "color")
        layer = layer * mapping(color = geom.aes["color"])
    end

    return layer
end
```

And finally, some basic inheritance rules to make it work the way ggplot does:

```julia
function draw_ggplot(plot::ggplot)
    for geom in plot.geoms
        # if data is not specified at the geom level
        #  use the ggplot default
        if !haskey(geom.args, "data")
            geom.args["data"] = plot.data
        end

        # if an aes isn't given in the geom, use the ggplot aes
        for aes in keys(plot.default_aes)
            if !haskey(geom.aes, aes)
                geom.aes[aes] = plot.default_aes[aes]
            end
        end
    end

    layers = []

    for geom in plot.geoms
        push!(layers, geom_to_layer(geom))
    end

    if length(layers) == 0
        error("No geoms supplied")
    elseif length(layers) == 1
        draw(layers[1]; axis = plot.axis)
    else
        draw((+)(layers...); axis = plot.axis)
    end
end
```

These 100-or-so lines of julia were enough to get something like a minimal working example going:

```julia
test_plot = @ggplot(data = penguins, aes(color = species)) +
    @geom_point(aes(x = bill_length_mm, y = bill_depth_mm)) +
    @geom_smooth(aes(x = bill_length_mm, y = bill_depth_mm),
        method = "lm")

draw_ggplot(test_plot)
```

![](/assets/original_tidierplot.png)

At this point, I was convinced that this was going to be easy, and I pushed [essentially this code](https://github.com/TidierOrg/TidierPlots.jl/tree/c1d97aee2758498806504e740a000bc84ff55d34) plus a PkgTemplates skeleton to a repo as version 0.1.0.
How hard could this really be?

---
