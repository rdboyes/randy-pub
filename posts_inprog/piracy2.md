@def title = "You wouldn't pirate a type (part 2)"
@def date = "10/13/2025"
@def tags = ["julia", "Tidier.jl"]

@def rss_pubdate = Date(2025, 10, 12)

## A more complete `slice`

[Part 1](/posts/piracy/) looked at some basic half-implementations of tidyverse functions, but can we actually get a full implementation of at least one function? `slice` seems like the easiest, so lets try. Tidyverse `slice` has the following options:

- slice variants: `slice_head`, `slice_tail`, `slice_sample`, `slice_min`, and `slice_max`
- selection: should support vector-like objects that contain integers as well as ranges, provided they are all positive (to keep) or all negative (to drop)
- by: optionally group the dataframe for the duration of this operation only
- preserve: should the original grouping, if present, be preserved? (Bool)
- n/prop: the number or proportion of rows to keep
- order_by: sort the df by this variable prior to slicing if provided
- na\_rm: should na values of the order\_by variable be removed? (Bool)
- weight_by: sampling weights
- replace: should sampling be with (true) or without (false, the default) replacement

Set up as in the last post:

```julia:./code/piracy2/real_slice_1
using DataFrames

struct TidyExpr
    f::Function
end

import Base.|>
Base.:(|>)(x::TidyExpr, y::TidyExpr) = TidyExpr(x.f ∘ y.f)
Base.:(|>)(x::DataFrames.DataFrame, y::TidyExpr) = y.f(x)
```

We'll need to expand the slice function to take kwargs and do things with the provided values. Slurped kwargs in julia are represented as Pairs, which can be easily turned into a Dict:

```julia:./code/piracy2/real_slice_2
function example(args...; kwargs...)
  println(args)
  println("Keyword args:")
  println(Dict(kwargs))
end

example(1:10, by = :a, order_by = :b, na_rm = true)
```
\show{./code/piracy2/real_slice_2}

As a first pass, lets set up a loop over a couple of supported kwargs with basic implementations of their functionality.

```julia:./code/piracy2/real_slice_3
function slice(args...; kwargs...)
  f = identity
  for (k, v) in Dict(kwargs)
    if k == :by
      f = f ∘ (x -> groupby(x, v))
    elseif k == :order_by
      f = f ∘ (x -> sort(x, v))
    end
  end

  return TidyExpr(x -> f(x) isa GroupedDataFrame ?
    combine(y -> getindex(y, args[1], :), f(x)) :
    f(x)[args[1], :])
end

DataFrame(a = 1:6, b = [1, 1, 1, 2, 2, 2]) |> slice(1, by = :b)
```
\show{./code/piracy2/real_slice_3}

```julia:./code/piracy2/real_slice_4
DataFrame(a = 1:6, b = 6:-1:1) |> slice(1, order_by = :b)
```
\show{./code/piracy2/real_slice_4}

The structure of the function works, we just need to add the rest of the arguments:

```julia:./code/piracy2/real_slice_5
function slice(args...; kwargs...)
  f = identity
  selection = args[1]
  if any(selection .< 0)
    selection = setdiff(setdiff)
  end
  dkw = Dict(kwargs)
  for (k, v) in dkw
    if k == :n
      selection = 1:v
    elseif k == :prop
      f = f ∘ (x -> x[1:floor(nrow(x) * prop), :])
    elseif k == :by
      f = f ∘ (x -> groupby(x, v))
    elseif k == :order_by
      f = f ∘ (x -> sort(x, v))
    elseif k == :replace

    elseif k == :weight_by

    elseif k == :na_rm

    elseif k == :preserve

    end
  end

  return TidyExpr(x -> f(x) isa GroupedDataFrame ?
    combine(y -> getindex(y, selection, :), f(x)) :
    f(x)[selection, :])
end
```
