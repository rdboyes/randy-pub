@def title = "Advent of Code Week 2"
@def date = "12/14/2024"
@def tags = ["julia", "adventofcode"]

@def rss_pubdate = Date(2024, 12, 14)

## Takeaways from Advent of Code Week 2

To my surprise, I haven't fallen off the advent of code train yet this year. Full solutions and takeaways for week 1 in julia are in the previous post [here](https://www.randy.pub/posts/adventofcode2024/). I haven't done the best job of using Tidier packages like I wanted, but for some AoC problems it just feels like a bad fit.

### Day 8

First time using CartesianIndex somehow, so useful! I made the choice early to iterate through the potential nodes rather than through the pairs of antennas, I think it was correct but the antenna pairs might be faster since there's no more than 4 of each type in the file. I was originally thinking I wouldn't have to recheck nodes that were "on the path" but quickly realized that that would miss a lot of nodes since multiple paths intersect.

```julia
data = permutedims(reduce(hcat, split.(readlines("data/8.txt"), "")))
side_length = size(data)[1]
antennas = findall(x -> x != ".", data)
nodesp1 = Set{CartesianIndex}()
nodesp2 = Set{CartesianIndex}()

in_bounds(x) = all([i > 0 && i <= side_length for i in Tuple(x)])
gcd_dir(x) = CartesianIndex(x[1] ÷ gcd(Tuple(x)...), x[2] ÷ gcd(Tuple(x)...))

for loc in CartesianIndices(data)
    for antenna in filter(x -> x != loc, antennas)
        res_antenna = loc + 2 * (antenna - loc)
        if in_bounds(res_antenna) && data[res_antenna] == data[antenna]
            push!(nodesp1, loc)
            dir = gcd_dir(res_antenna - loc)

            cursor1 = loc + dir
            cursor2 = loc - dir

            while in_bounds(cursor1)
                push!(nodesp2, cursor1)
                cursor1 = cursor1 + dir
            end

            while in_bounds(cursor2)
                push!(nodesp2, cursor2)
                cursor2 = cursor2 - dir
            end
        end
    end
end

println("Part 1: $(length(nodesp1))")
println("Part 2: $(length(union(nodesp1, nodesp2, antennas)))")
```

### Day 9

Still struggling with Part 2 on this one.

```julia
to_int(x) = parse.(Int, x)
d = to_int(split.(readline("data/9test1.txt"), ""))

function solve(d)
    c1 = 1
    c2 = length(d)
    total = 0
    count = 0

    while true
        if c1 % 2 == 0
            if d[c2] <= d[c1]
                d[c1] -= d[c2]
                new_count = count + d[c2]
                total += (c2 ÷ 2) * sum(count:(new_count-1))
                if d[c1] == 0
                    c1 += 1
                end
                c2 -= 2
                count = new_count
            else
                d[c2] -= d[c1]
                new_count = count + d[c1]
                total += (c2 ÷ 2) * sum(count:(new_count-1))
                c1 += 1
                count = new_count
            end
        else
            new_count = count + d[c1]
            total += (c1 ÷ 2) * sum(count:(new_count-1))
            count = new_count
            c1 += 1
        end
        c1 > c2 && break
    end

    return total
end

println(solve(d))
```

### Day 10

First graph problem! I found julia's Graphs.jl package to be much smoother to work with than R's igraph, once I understood what it wanted. Most of the code is setup, once the graph is created the solution is easy.

```julia
to_int(x) = parse.(Int8, x)

data = permutedims(
    reduce(hcat, to_int.(split.(readlines("data/10.txt"), "")))
)

side_length = size(data)[1]

in_bounds(x) = all([i > 0 && i <= side_length for i in Tuple(x)])

neighbor_dirs = [
    CartesianIndex(0, 1),
    CartesianIndex(0, -1),
    CartesianIndex(1, 0),
    CartesianIndex(-1, 0)
]

using Graphs

c2i = Dict(c => i for (c, i) in zip(CartesianIndices(data), eachindex(data)))

g = DiGraph()

add_vertices!(g, side_length^2)

for point in CartesianIndices(data)
    for n in neighbor_dirs
        if in_bounds(n + point)
            if data[n + point] == data[point] + 1
                add_edge!(g, c2i[point], c2i[n+point])
            end
        end
    end
end

pathsp1 = Bool[]
pathsp2 = Int[]

for (v0, v9) in Iterators.product(
    [c2i[c] for c in (findall(x -> x == 0, data))],
    [c2i[c] for c in (findall(x -> x == 9, data))])

    push!(pathsp1, has_path(g, v0, v9))
    push!(pathsp2, length(collect(all_simple_paths(g, v0, v9))))
end

println(sum(pathsp1))
print(sum(pathsp2))
```
