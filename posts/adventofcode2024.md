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
using DataFrames

df = read_csv("data/1.txt", col_names = false, delim = "   ")

p1 = @chain DataFrame(c1 = sort(df.Column1), c2 = sort(df.Column2)) begin
    @mutate(diff = abs(c1 - c2))
    @pull(diff)
    sum
end

println("Part 1: $p1")

p2 = @chain df begin
    @aside c1 = @count(_, Column1)
    @count(Column2)
    @rename(n_1 = n)
    @left_join(c1, "Column2" = "Column1")
    @mutate(sim_score = Column2 * n * n_1)
    @filter(!ismissing(sim_score))
    @pull(sim_score)
    sum
end

print("Part 2: $p2")
```

Not much to say about Part 1. Independently sorting columns not really a useful operation on a DataFrame usually so the support for it in Tidier is non-existent as far as I can tell, and I think that's a good thing.

Part 2 has more rough edges:

- There seems to be no way to name the column that contains @count's counts, which means I have to rely on a extra line'd @rename (ew) or type out the equivalent @summarize call (even worse?) - looking it up, this is how it works in R's tidyverse as well. Fair enough, I guess, but I want a .col_name argument anyway.
- There's no way to pass arguments through to DataFrames.leftjoin directly, so we can't solve the rename problem with makeunique, either. This one seems like an actual improvement to add rather than a pointless nitpick like the first point.
- The required syntax for non-matching column joins doesn't match R's left_join OR the DataFrames.leftjoin syntax. This seems unintuitive. Scared to check the git blame and find out it was me who implemented this...

On the plus side, I love the @aside macro more every time I use it and wish it existed in R as well.

### Day 2

Does it still count as "pure Tidier.jl" if you write functions outside of the chain? I'm going with yes.

```julia
df = read_csv("data/2.txt", col_names = false)

to_int(x) = parse.(Int, x)
check_safe(steps) = all(steps .> 0 .&& steps .<  4) ||
                    all(steps .< 0 .&& steps .> -4)

p1 = @chain df begin
    @transmute(list = to_int(split(Column1)))
    @mutate(steps = diff(list))
    @mutate(safe = check_safe(steps))
    @pull(safe)
    sum
end

println("Part 1: $p1")

check_all(l) = check_safe.(diff.([l[1:end .!= i] for i in 1:length(l)]))

p2 = @chain df begin
    @transmute(list = to_int(split(Column1)))
    @mutate(safe = any(check_all(list)))
    @pull(safe)
    sum
end

println("Part 2: $p2")
```

One of the biggest struggles here was trying to get fine control of the exact vectorization of functions across list-columns with the Tidier toolbox. You can turn on and off vectorization, sure, but to write a solution to this problem I needed to vectorize *inside rows* and I don't know if that functionality exists or is fully developed. Using list comprehesion inside macros also doesn't seem possible, since you get errors related to the variable "i" and "end" if you try to use the "check_all" function inside a mutate.

### Day 3

The first regex problem of many!

```julia
using TidierStrings
using TidierData

function str_extract_all_cap(string::AbstractString, pattern::Union{String, Regex}; captures::Bool=false)
    regex_pattern = isa(pattern, String) ? Regex(pattern) : pattern
    to_missing(l) = [ifelse(isnothing(c), missing, c) for c in l]
    matches = captures ?
        [to_missing(m.captures) for m in eachmatch(regex_pattern, string)] :
        [String(m.match) for m in eachmatch(regex_pattern, string)]
    return isempty(matches) ? missing : matches
end

p1 = @chain *(readlines("data/3.txt")...) begin
    str_extract_all_cap(r"mul\((?<n1>\d+),(?<n2>\d+)\)", captures = true)
    map(x -> prod(parse.(Int, x)), _)
    sum
end

println("Part 1: $p1")

p2 = @chain *(readlines("data/3.txt")...) begin
    str_extract_all_cap(r"mul\((\d+),(\d+)\)|(do(?:n't)?\(\))", captures = true)
    DataFrame(mapreduce(permutedims, vcat, _), :auto)
    @fill_missing(x3, "down")
    @mutate(x3 = replace_missing(x3, "do()"))
    @filter(x3 != "don't()")
    @mutate(prod = as_integer(x1) * as_integer(x2))
    @filter(!ismissing(prod))
    @pull(prod)
    sum
end

println("Part 2: $p2")
```

TidierStrings.str_extract_all doesn't (currently! PR submitted) support capture groups so I wrote a version that does. Otherwise this is kind of a "classic" AoC regex problem, nothing too difficult. Something tells me Day 4 is going to be difficult...


{{ add_bsky_comments "at://did:plc:2h5e6whhbk5vnnerqqoi256k/app.bsky.feed.post/3lcbbseb55c27" }}
