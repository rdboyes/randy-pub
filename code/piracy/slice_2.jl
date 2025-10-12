# This file was generated, do not modify it. # hide
function slice(args...)
    return TidyExpr(x -> x[args[1], :])
end