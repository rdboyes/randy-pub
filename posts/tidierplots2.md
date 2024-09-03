@def title = "Developing TidierPlots.jl, Part 2"
@def date = "09/03/2024"
@def tags = ["julia", "TidierPlots.jl"]

@def rss_pubdate = Date(2024, 09, 03)

---

## Quick Wins

The early development on TidierPlots felt seamless. R's ggplot has a behaviour where plots will show automatically when you create them, and I was able to
replicate that experience with a call to `display` when the `+` operation was used to construct a ggplot object:

```julia
function Base.:+(x::ggplot, y...)::ggplot
    result = ggplot(vcat(x.geoms, [i for i in y]),
        x.default_aes,
        x.data,
        x.axis)

    # don't tell the julia police
    if autoplot
        display(draw_ggplot(result))
    end

    return result
end
```

I also quickly added support for `geoms` that lined up nicely with AlgebraOfGraphics plots, including `geom_bar`, `geom_col`, `geom_violin`, `geom_path`, `geom_text`, and `geom_boxplot`,
and convenience functions like `labs`, `lims`, themes, saving plots, facetting, and more. I tried to follow SemVer as best as I could and bumped by version number dutifully up to 0.3.2.
Collaborators started to show up, adding a logo for the package and some documentation. Things were going quite well, then I hit the first bump in the road in the form of a questionable `eval()` call.

## The First Mistake - Macros

Julia has a powerful but slightly unwieldy macro system. As far as I can tell, people use it for two very different reasons instead of normal functions.

- The intended reason, which is to write code that you want to evaluate at compile time rather than run time.
- To be sneaky and write non-standard code that nonetheless runs in julia.

Tidier.jl, and more specifically TidierData.jl, uses macros mostly for reason 2, and reason 1 is - if anything - a downside. I had written the whole package to use macros to be consistent with how the rest of the Tidier
system was shaping up. This resulted in having this block of code inside the function that builds geoms:

```julia
# if data is specified, call a questionable eval to grab it as a layer
if haskey(args_dict, "data")
  # if the code is running in a Pluto.jl notebook
  if !isnothing(match(r"#==#", @__FILE__))
    plot_data = AlgebraOfGraphics.data(eval(args_dict["data"]))
  else
    plot_data = AlgebraOfGraphics.data(Base.eval(Main, args_dict["data"]))
  end
else
  plot_data = mapping()
end
```

Ew. As I looked upon the monstrosity I had written, I had a realization. I didn't actually need macros for anything except the `aes` call. See, TidierData needs macros so that people can write things like:

```
@mutate(data, A = B * 2)
```

Where A and B are columns in data, *not objects in the global environment as julia would normally interpret them*. I needed macros for things like:

```
@geom_point(data, aes(x = x_col, y = y_col))
```

But in that call, `data` really ideally would just be the data - hence the questionable `eval` code above. Thus began the first full refactor of TidierPlots, and version 0.4.0 completely broke all previous code but switching out macros for function equivalents.


## The Second Mistake - Too many layers

Just as I finished rewriting the entire package, I realized that I needed to rewrite it again. TidierPlots was originally set up like this:

~~~
<figure>
<pre>
┌─────────────┐         ┌───────────────────┐         ┌───────────┐
│ TidierPlots │ ──────► │ AlgebraOfGraphics │ ──────► │   Makie   │
└─────────────┘         └───────────────────┘         └───────────┘
</pre>
</figure>
~~~

But that meant that TidierPlots could only support things that AlegebraOfGraphics supports, and - at the time - that wasn't too long of a list. For example, one thing that
it just couldn't seem to do was make a horizontal bar chart. I set out to strip away the AoG middleman, and version 0.5.0 was born. Thankfully, most of the code that had been written up until that point was
focused on building the objects, so it was mostly a matter of swapping out the interpretation part from AoG to Makie's shiny new SpecApi.

---
