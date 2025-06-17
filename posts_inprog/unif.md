```julia
using Statistics, CairoMakie

barplot(
    var.(eachrow(
        reduce(hcat, 
            [parse.(Int, x) for x in 
                split.(bitstring.(rand(1000)), "")
            ]
        )
    )); bins = 64, breaks = 0:
)


```