# This file was generated, do not modify it. # hide
import Base.getindex
Base.getindex(f::Function, args...) = TidyMutation(f, [a for a in args])

plus_one(x) = x .+ 1
DataFrame(a = 1:10) |> mutate(b = plus_one[:a])