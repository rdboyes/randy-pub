# This file was generated, do not modify it. # hide
function select(args...)
    return TidyExpr(df -> df[:, [a for a in args]])
end