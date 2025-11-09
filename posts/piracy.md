@def title = "You wouldn't pirate a type"
@def date = "10/12/2025"
@def tags = ["julia", "Tidier.jl"]

@def rss_pubdate = Date(2025, 10, 12)

## Type Piracy

If you aren't familiar, "type piracy" is when you define versions of methods/functions you don't own for types you don't own. The julia community is very anti-type-piracy. Unfortunately for them, piracy is cool. I don't make the rules.

Why would we want to pirate types? For me, it's because macros are icky. If I can write a version of code that doesn't use a macro that works, I prefer it. For example, julia has a native pipe operator (|>), but it is almost unusable (aesthetically) by default, requiring ugly anonymous functions if the output of one function doesn't match the input of the next function exactly:

```julia
df |> x -> transform(x, ...) # code to specify changes goes in ...
```

So people tend to use macros to implement r-style "pipe chains":

```julia
@chain df begin
    transform(...)
end
```

So many characters. Unnatural `@` symbols infecting my clean code. I want to write:

```julia
df |> transform(...)
```

And I will stop at nothing to do it.

## Start with `slice`

Starting simple, `slice` is a `dplyr` function that selects rows out of a DataFrame based on a given index. Lets make a new Type that wraps function so that we can redefine some behaviour. I'll call this `TidyExpr`:

```julia:/code/piracy/slice_1
struct TidyExpr
    f::Function
end
```

Define a function called `slice` that returns a `TidyExpr`:

```julia:/code/piracy/slice_2
function slice(args...)
    return TidyExpr(x -> x[args[1], :])
end
```

And redefine what it means to pipe stuff if a `TidyExpr` is involved.

```julia:/code/piracy/slice_3
using DataFrames
import Base.|>

Base.:(|>)(x::TidyExpr, y::TidyExpr) = TidyExpr(x.f ∘ y.f)
Base.:(|>)(x::DataFrames.DataFrame, y::TidyExpr) = y.f(x)
```

This is enough for a basic `slice` function to work, and we haven't really committed any crimes (yet)!

```julia:./code/piracy/slice_4
DataFrame(a = 1:10) |> slice(3:7) |> slice(2:3)
```

\show{./code/piracy/slice_4}

## Lets try `select`

Select picks columns to keep.

```julia:./code/piracy/select_1
function select(args...)
    return TidyExpr(df -> df[:, [a for a in args]])
end
```

Now we can include basic `select` commands in a hybrid pipeline:

```julia:./code/piracy/select_2
DataFrame(a = 1:10, b = 2:11, c = 3:12) |> slice(3:5) |> select(:a, :b)
```

\show{./code/piracy/select_2}

Here is a good place to note that my attempt to do this without macros is not *entirely* an aesthetics-driven personal vendetta. We gain a couple of nice abilities for free using this approach - automatic function pipelines and easy "variable interpolation":

```julia:./code/piracy/select_3
vars = [:b, :c]
my_pipeline = slice(3:5) |> select(vars...)

DataFrame(a = 1:10, b = 2:11, c = 3:12) |> my_pipeline
```
\show{./code/piracy/select_3}

## Oh no, now it's time for `filter`

The dplyr function `filter` is like slice in that it selects and retains a subset of rows, except you are supposed to pass it a condition rather than an index. The issue is that we ideally (if we want to have tidyverse-like behaviour) want to pass only a condition, like `filter(:b > 3)`.

```julia:./code/piracy/filter_1
struct TidyCondition
    x::Any
    y::Any
    op::Function
end

import Base.isless
Base.isless(x::Symbol, y::Any) = TidyCondition(x, y, <)
Base.isless(x::Any, y::Symbol) = TidyCondition(x, y, <)
Base.isless(x::Symbol, y::Symbol) = TidyCondition(x, y, <)

function filter(tc::TidyCondition)
    if tc.x isa Symbol
        if tc.y isa Symbol
            return TidyExpr(df ->
                DataFrames.filter([tc.x, tc.y] => (x, y) -> tc.op.(x, y), df)
            )
        else
            return TidyExpr(df ->
                DataFrames.filter([tc.x] => (x) -> tc.op.(x, tc.y), df)
            )
        end
    elseif tc.y isa Symbol
        return TidyExpr(df ->
            DataFrames.filter([tc.y] => y -> tc.op.(tc.x, y), df)
        )
    end
end
```

```julia:./code/piracy/filter_2
DataFrame(a = 1:10, b = 2:11, c = 3:12) |> filter(:b > 5)
```
\show{./code/piracy/filter_2}

```julia:./code/piracy/filter_3
DataFrame(
    a = [3, 4, 1, 2, 3, 4, 5, 6, 7, 8],
    b = 2:11,
    c = 3:12
  ) |> filter(:b < :a)
```
\show{./code/piracy/filter_3}

![](https://www.enworld.org/media/sickos-gif.167921/full)

## I will not be stopped (what about `mutate`)

Ok here's where it *really* starts going off the rails. `mutate` accepts functions, which it applies to columns.

```julia:./code/piracy/mutate_1
struct TidyMutation
    f::Function
    args::Vector{Any}
end

function mutate(args...; kwargs...)
    for m in kwargs
        symlist = Symbol[]
        for arg in m[2].args
            if arg isa Symbol # i.e., a column reference
                push!(symlist, arg)
            end
        end
        if length(symlist) == 1
            return TidyExpr(
                df -> transform(df,
                    symlist[1] => (x -> m[2].f(x)) => [Symbol(m[1])]
                )
            )
        end
    end
end

Base.:(|>)(x::Symbol, y::Function) = TidyMutation(y, [x])
```

Now we can use the pipe inside of mutate to apply functions:

```julia:./code/piracy/mutate_2
plus_one(x) = x .+ 1
DataFrame(a = 1:10) |> mutate(b = :a |> plus_one)
```
\show{./code/piracy/mutate_2}

Or override the unused `getindex` of a function to use a square-bracket function call:

```julia:./code/piracy/mutate_3
import Base.getindex
Base.getindex(f::Function, args...) = TidyMutation(f, [a for a in args])

plus_one(x) = x .+ 1
DataFrame(a = 1:10) |> mutate(b = plus_one[:a])
```
\show{./code/piracy/mutate_3}

## Is this a good idea?

No

{{ add_bsky_comments "at://did:plc:2h5e6whhbk5vnnerqqoi256k/app.bsky.feed.post/3m2zkdcuf4k26" }}

---
