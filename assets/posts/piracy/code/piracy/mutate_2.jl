# This file was generated, do not modify it. # hide
plus_one(x) = x .+ 1
DataFrame(a = 1:10) |> mutate(b = :a |> plus_one)