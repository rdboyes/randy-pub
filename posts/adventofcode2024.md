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

TidierStrings.str\_extract\_all doesn't (currently! PR submitted) support capture groups so I wrote a version that does. Otherwise this is kind of a "classic" AoC regex problem, nothing too difficult. Something tells me Day 4 is going to be difficult...

### Day 4

```julia
using TidierStrings

text = readlines("data/4.txt")
nl = length(text)
ts = split.(text, "")

fb = text

ud = reduce(*, reduce(hcat, ts), dims = 2)

diag1 = [
    [ts[x][y] for (x, y) in
    Iterators.product(1:nl, 1:nl) if x + y == z]
    for z in 2:(nl*2)
]

diag2 = [
    [ts[x][y] for (x, y) in
    Iterators.product(1:nl, 1:nl) if x - y == z]
    for z in (nl-1):-1:(-(nl-1))
]

function str_count_overlap(column, pattern::Union{String,Regex}; overlap::Bool=false)
    if ismissing(column)
        return (column)
    end

    if pattern isa String
        pattern = Regex(pattern) # treat pattern as regular expression
    end

    # Count the number of matches for the regular expression
    return length(collect(eachmatch(pattern, column, overlap = overlap)))
end

p1 = sum(vcat(
    str_count_overlap.(text, "XMAS|SAMX", overlap=true),
    str_count_overlap.(ud, "XMAS|SAMX", overlap=true),
    str_count_overlap.(map(x -> *(x...), diag1), "XMAS|SAMX", overlap=true),
    str_count_overlap.(map(x -> *(x...), diag2), "XMAS|SAMX", overlap=true)
))

println("Part 1: $p1")

mat = reduce(hcat, ts)

function is_x_mas(g)
    g[2,2] != "A" && return false
    sum([g[1,1], g[1,3], g[3,1], g[3,3]] .== "S") != 2 && return false
    sum([g[1,1], g[1,3], g[3,1], g[3,3]] .== "M") != 2 && return false
    (g[1,1] == g[3,3] || g[1,3] == g[3,1]) && return false
    return true
end

p2 = sum([is_x_mas(mat[((cx-1):(cx+1), (cy-1):(cy+1))...]) for
    (cx, cy) in Iterators.product(2:(nl-1),2:(nl-1))])

println("Part 2: $p2")
```

Another AoC classic, a "grid problem", and another improvement for TidierStrings to submit as a PR! Julia's eachmatch function allows for overlaps, no reason not to allow the overlap Bool to pass through from str_count.

### Day 5

One of those days where you hit Part 2 and just think ... not today. Happy enough with my part one, although it is very light on the Tidier.jl. *(edit: saw a hint about custom sort functions on BlueSky and finished it off)*

```julia
data = readlines("data/5.txt")
div = findall(data .== "")[1]

to_int(x) = parse.(Int, x)
rules = to_int.(split.(data[1:(div-1)], "|"))
pages = to_int.(split.(data[(div+1):end], ","))

check_rules(p, rl) = ifelse(
    any([r ⊆ p && !all(p ∩ r .== r) for r in rl]),
    0, p[ceil(Int, end / 2)])

p1 = sum(check_rules.(pages, (rules,)))

println("Part 1: $p1")

rulesort(x, y) = [x, y] in rules
p2 = sum(check_rules.(sort.(pages, lt=rulesort), (rules,))) - p1

println("Part 1: $p2")
```

### Day 6

Brute force implementation. It works, but it is sloooooow. One to revisit, I suspect a ton of optimizations are possible.

```julia
data = permutedims(reduce(hcat, split.(readlines("data/6.txt"), "")))
side_length = size(data, 1)
dir_list = [[-1,0], [0, 1], [1, 0], [0, -1]]
ci = findfirst(i -> i == "^", data)

function check_path(pos, dir, path_history, data)
    dir_vector = dir_list[(dir%4)+1]
    if (pos, dir_vector) in path_history
        return (:looped, path_history)
    else
        push!(path_history, (pos, dir_vector))
    end
    if any(1 .> pos .+ dir_vector) || any(pos .+ dir_vector .> side_length)
        return (:escaped, path_history)
    end
    if data[(pos .+ dir_vector)...] == "#"
        return (:blocked, path_history)
    end
    return (:clear, path_history)
end

function findpath(grid; block = nothing)
    pos = [ci[1], ci[2]]
    dir = 0
    path_history = []
    path = :clear

    if !isnothing(block)
        grid[block...] = "#"
    end

    while !(path in [:escaped, :looped])
        path, path_history = check_path(pos, dir, path_history, grid)
        if path == :blocked
            dir = dir + 1
        elseif path == :clear
            pos = pos .+ dir_list[(dir%4)+1]
        end
    end

    return (path, path_history)
end

status, clear_path = findpath(data)
p1_path_positions = unique([p[1] for p in clear_path])

println("Part 1: $(length(p1_path_positions))")

status_list = []
possible_blocks = [p[1] .+ p[2] for p in clear_path[1:(end-1)]]

for block in unique(possible_blocks)
    p2status, p2paths = findpath(copy(data); block = block)
    push!(status_list, p2status)
end

println("Part 2: $(length([s for s in status_list if s == :looped]))")
```


{{ add_bsky_comments "at://did:plc:2h5e6whhbk5vnnerqqoi256k/app.bsky.feed.post/3lcbbseb55c27" }}
