# This file was generated, do not modify it. # hide
vars = [:b, :c]
my_pipeline = slice(3:5) |> select(vars...)

DataFrame(a = 1:10, b = 2:11, c = 3:12) |> my_pipeline