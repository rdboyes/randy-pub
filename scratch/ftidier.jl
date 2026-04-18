using DataFrames

struct TidyColRef
    colname::Symbol
end

macro c_str(colname)
    return TidyColRef(Symbol(colname))
end

struct TidyCondition
    x::Any
    y::Any
    op::Function
end

struct TidyExpr
    f::Function
end

import Base.isless
Base.isless(x::TidyColRef, y::Any) = TidyCondition(x.colname, y, <)
Base.isless(x::Any, y::TidyColRef) = TidyCondition(x, y.colname, <)
Base.isless(x::TidyColRef, y::TidyColRef) = TidyCondition(x.colname, y.colname, <)

Base.:(|>)(x::TidyExpr, y::TidyExpr) = TidyExpr(x.f ∘ y.f)
Base.:(|>)(x::DataFrames.DataFrame, y::TidyExpr) = y.f(x)

function filter(tc::TidyCondition)
    if tc.x isa Symbol
        if tc.y isa Symbol
            return TidyExpr(df ->
                DataFrames.filter([tc.x, tc.y] => (x, y) -> tc.op.(x, y), df)
            )
        else
            return TidyExpr(df ->
                DataFrames.filter([tc.x] => (x) -> tc.op.(x, tc.y), df)
            )
        end
    elseif tc.y isa Symbol
        return TidyExpr(df ->
            DataFrames.filter([tc.y] => y -> tc.op.(tc.x, y), df)
        )
    end
end

DataFrame(a = 1:10, b = 2:11, c = 3:12) |> filter(c"b" > 5)
