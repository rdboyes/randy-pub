# This file was generated, do not modify it. # hide
function example(args...; kwargs...)
  println(args)
  println("Keyword args:")
  println(Dict(kwargs))
end

example(1:10, by = :a, order_by = :b, na_rm = true)