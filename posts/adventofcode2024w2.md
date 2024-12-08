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