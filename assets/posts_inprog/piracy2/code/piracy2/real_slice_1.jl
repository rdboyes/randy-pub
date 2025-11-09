# This file was generated, do not modify it. # hide
using DataFrames

struct TidyExpr
    f::Function
end

import Base.|>
Base.:(|>)(x::TidyExpr, y::TidyExpr) = TidyExpr(x.f ∘ y.f)
Base.:(|>)(x::DataFrames.DataFrame, y::TidyExpr) = y.f(x)