# This file was generated, do not modify it. # hide
function slice(args...; kwargs...)
  f = identity
  for (k, v) in Dict(kwargs)
    if k == :by
      f = f ∘ (x -> groupby(x, v))
    elseif k == :order_by
      f = f ∘ (x -> sort(x, v))
    end
  end

  return TidyExpr(x -> f(x) isa GroupedDataFrame ?
    combine(y -> getindex(y, args[1], :), f(x)) :
    f(x)[args[1], :])
end

DataFrame(a = 1:6, b = [1, 1, 1, 2, 2, 2]) |> slice(1, by = :b)