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

## Day 11

Ended up using two completely different approaches for parts 1 and 2. The memoized recursion approach here works really quickly for part 1, but self-destructs when you try it for part 2. The dict-based approach is slower but still finishes p2 in 8 milliseconds so who's complaining...

```julia
using Memoization

initial = [64599, 31, 674832, 2659361, 1, 0, 8867, 321]

@memoize function split_once(n)
    n == 0 && return [1]
    dn = digits(n)
    ln = length(dn)
    if isodd(ln)
        return [2024n]
    else
        n1 = floor(Int, n / (10^(ln ÷ 2)))
        n2 = n - n1 * 10^(ln ÷ 2)
        return [n1, n2]
    end
end

@memoize function split(n, iter)
    if iter == 1
        return split_once(n)
    else
        return_value = Int[]
        for ni in split_once(n)
            append!(return_value, split(ni, iter - 1))
        end
        return return_value
    end
end

@btime sum(length.(split.(initial, 25)))

function split_dict_once(stone_dict)
    new_dict = Dict{Int,Int}()
    for (k, v) in stone_dict
        for r in split_once(k)
            current = get(new_dict, r, 0)
            new_dict[r] = current + v
        end
    end
    return new_dict
end

function solvep2(initial, iter)
    initial_dict = Dict(v => 1 for v in initial)
    for i in 1:iter
        initial_dict = split_dict_once(initial_dict)
    end
    return sum(values(initial_dict))
end

solvep2(initial, 75)
```


## Day 13

Pretty clean solution for Day 13. Don't love the round/isinteger solution but floating point problems were causing headaches.

```julia
inst = readlines("data/13.txt")

A = [parse.(Int, m.captures) for m in
     match.(r"A: X\+(\d+), Y\+(\d+)", inst) if !isnothing(m)]
B = [parse.(Int, m.captures) for m in
     match.(r"B: X\+(\d+), Y\+(\d+)", inst) if !isnothing(m)]
P = [parse.(Int, m.captures) for m in
     match.(r"Prize: X\=(\d+), Y\=(\d+)", inst) if !isnothing(m)]

function solve(adjust=0)
    ans = 0
    for i in eachindex(A)
        sol = hcat(A[i], B[i]) \ (P[i] .+ adjust)
        if all(isinteger.(round.(sol, digits=3)))
            ans += sum((3, 1) .* sol)
        end
    end
    return ans
end

println(solve())
println(solve(10000000000000))
```


## Day 14

Solution to part one runs fast, clean solution. Part two requires you to watch a nearly 17 minute long video generated by Makie.jl to find the tree. I'm sure there was a smart way to do this, but when in doubt, look at the data...

```julia
struct Robot
    initial::CartesianIndex
    velocity::CartesianIndex
end

to_ints(x) = [parse.(Int, m.match) for m in eachmatch(r"-*\d+", x)]

robots = [
    Robot(CartesianIndex(x[1],x[2]), CartesianIndex(x[3],x[4]))
    for x in [to_ints(l) for l in readlines("data/14.txt")]
]

function move(r::Robot, steps::Int, grid::Tuple)
    return mod.(Tuple(r.initial + steps * r.velocity), grid)
end

function which_quad(position, grid)
    return position[1] < grid[1] ÷ 2 && position[2] < grid[2] ÷ 2 ? 1 :
           position[1] > grid[1] ÷ 2 && position[2] < grid[2] ÷ 2 ? 2 :
           position[1] < grid[1] ÷ 2 && position[2] > grid[2] ÷ 2 ? 3 :
           position[1] > grid[1] ÷ 2 && position[2] > grid[2] ÷ 2 ? 4 : 0
end

q = which_quad.(move.(robots, Ref(100), Ref((101, 103))), Ref((101, 103)))
p1 = prod([n[2] for n in [(i, count(==(i), q)) for i in unique(q) if i != 0]])

println(p1)

using GLMakie

point_locs(x) = Point2f.(move.(robots, Ref(x), Ref((101, 103))))
points = Observable(point_locs(0))

fig, ax = scatter(points)
limits!(ax, 0, 101, 0, 103)

frames = 1:2000

record(fig, "tree_animation.mp4", frames; framerate = 10) do frame
    points[] = point_locs(frame)
    ax.title = string(frame)
end
```
