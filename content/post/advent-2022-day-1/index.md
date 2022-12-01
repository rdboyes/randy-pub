---
title: "Day 1"
format: hugo-md
fontsize: 10pt
theme: journal
monofont: "Fira Code Retina"
execute: 
  warning: false
  error: false
  message: false
---



# Problem

Given a txt file consisting of one column of integers with missing rows indicating the start of a new individual, find:

-   The individual with the highest sum
-   The three individuals with the highest sum

# Thoughts

This was a relatively straightforward problem in R. Using `cumsum` on missing values to create an index is an idiom that comes up a lot in Advent problems.

Translating to Julia, I had a couple of minor issues.

-   Forgot that `ismissing` would need to be broadcast, which ruined my groups in Julia for a bit.
-   I tried a couple of suggestions that didn't work correctly for me before finding the `* -1` strategy for a descending sort in `@orderby`.

On the plus side,

-   The `@aside` macro is a really nice feature when you want two outputs.
-   As expected, the Julia version is way faster!

# Code

<div class="columns">

<div class="column" width="49%">

# R

Load the data into a `tibble` using the `tidyverse` packages.

``` r
library(tidyverse)

df <- tibble(
  num = as.numeric(
    read_lines("data/1.txt")
  )
) 
```

</div>

<div class="column" width="2%">

<!-- empty column to create gap -->

</div>

<div class="column" width="49%">

# Julia

Load the data into a `DataFrame` using `CSV`.

``` julia
using DelimitedFiles, CSV
using DataFrames, DataFramesMeta

df = CSV.read(
    "data/1.txt", 
    DataFrame, 
    ignoreemptyrows = false,
    header = ["x1"]
)
```

</div>

</div>

<div class="columns">

<div class="column" width="49%">

Group the individuals by adding a cumulative sum of missing values, then sum within groups.

``` r
solve_day <- function(df){
  prep <- df |>
    mutate(id = cumsum(is.na(num))) |>
    group_by(id) |>
    summarize(total_cal = sum(num, na.rm = TRUE)) |>
    arrange(desc(total_cal))

  p1 <- slice(prep, 1) |> pull(total_cal)
  p2 <- slice(prep, 1:3) |> pull(total_cal) |> sum()

  return(c(p1, p2))
}
```

</div>

<div class="column" width="2%">

<!-- empty column to create gap -->

</div>

<div class="column" width="49%">

Group the individuals by adding a cumulative sum of missing values, then sum within groups.

``` julia
function solve_day(df)
  p2 = @chain df begin
    @transform :id = cumsum(ismissing.(:x1))
    groupby(:id)
    @combine :total_cal = sum(skipmissing(:x1))
    @aside p1 = maximum(_.total_cal)
    @orderby(:total_cal * -1)
    sum(_.total_cal[1:3])
  end
  return([p1, p2])
end
```

</div>

</div>

<div class="columns">

<div class="column" width="49%">

Run our `solve_day` function to get our solution:

``` r
solve_day(df)
```

    [1]  74711 209481

</div>

<div class="column" width="2%">

<!-- empty column to create gap -->

</div>

<div class="column" width="49%">

Run our `solve_day` function to get our solution:

``` julia
solve_day(df)
```

    2-element Vector{Int64}:
      74711
     209481

</div>

</div>

<div class="columns">

<div class="column" width="49%">

Run benchmark using `bench::mark()`:

``` r
select(bench::mark(solve_day(df)), median, mem_alloc)
```

    # A tibble: 1 × 2
        median mem_alloc
      <bch:tm> <bch:byt>
    1   11.6ms     192KB

</div>

<div class="column" width="2%">

<!-- empty column to create gap -->

</div>

<div class="column" width="49%">

Run benchmark using `BenchmarkTools`:

``` julia
using BenchmarkTools
median(@benchmark solve_day(df))
```

    BenchmarkTools.TrialEstimate: 
      time:             197.050 μs
      gctime:           0.000 ns (0.00%)
      memory:           107.63 KiB
      allocs:           613

</div>

</div>
