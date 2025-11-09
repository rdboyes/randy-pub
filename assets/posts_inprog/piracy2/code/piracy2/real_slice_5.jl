# This file was generated, do not modify it. # hide
function slice(args...; kwargs...)
  f = identity
  selection = args[1]
  if any(selection .< 0)
    selection = setdiff(setdiff)
  end
  dkw = Dict(kwargs)
  for (k, v) in dkw
    if k == :n
      selection = 1:v
    elseif k == :prop
      f = f ∘ (x -> x[1:floor(nrow(x) * prop), :])
    elseif k == :by
      f = f ∘ (x -> groupby(x, v))
    elseif k == :order_by
      f = f ∘ (x -> sort(x, v))
    elseif k == :replace

    elseif k == :weight_by

    elseif k == :na_rm

    elseif k == :preserve

    end
  end

  return TidyExpr(x -> f(x) isa GroupedDataFrame ?
    combine(y -> getindex(y, selection, :), f(x)) :
    f(x)[selection, :])
end