@def title = "Advent of Code Week 1"
@def date = "12/07/2024"
@def tags = ["julia", "adventofcode"]

@def rss_pubdate = Date(2024, 12, 07)

## Takeaways from Advent of Code Week 1

It's the most wonderful time of year again - time to engage in my time-honored tradition of starting advent of code and losing steam after the first week when it gets hard. As I did last year, I'll try this in pure Tidier.jl, hoping to find some rough edges that we can smooth out.

### Day 1

Unlike last year's first week, Day 1 is nice and easy.

```julia
using TidierFiles
using TidierData

df = read_csv("data/1.txt", col_names = false, delim = "   ")

println("Part 1: $(sum(abs.(sort(df.Column1) .- sort(df.Column2))))")

p2 = @chain df begin
    @aside c1 = @count(_, Column1)
    @count(Column2)
    @rename(n_1 = n)
    @left_join(c1, "Column2" = "Column1")
    @mutate(sim_score = Column2 * n * n_1)
    @summarize(sum = sum(skipmissing(sim_score)))
end

print("Part 2: $(p2[1,1])")
```

Not much to say about Part 1. Independently sorting columns not really a useful operation on a DataFrame usually so the support for it in Tidier is non-existent as far as I can tell, and I think that's a good thing.

Part 2 has more rough edges:

- There seems to be no way to name the column that contains @count's counts, which means I have to rely on a extra line'd @rename (ew) or type out the equivalent @summarize call (even worse?) - looking it up, this is how it works in R's tidyverse as well. Fair enough, I guess, but I want a .col_name argument anyway.
- There's no way to pass arguments through to DataFrames.leftjoin directly, so we can't solve the rename problem with makeunique, either. This one seems like an actual improvement to add rather than a pointless nitpick like the first point.
- The required syntax for non-matching column joins doesn't match R's left_join OR the DataFrames.leftjoin syntax. This seems unintuitive. Scared to check the git blame and find out it was me who implemented this...

On the plus side, I love the @aside macro more every time I use it and wish it existed in R as well.

### Day 2
