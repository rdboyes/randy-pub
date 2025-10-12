# This file was generated, do not modify it. # hide
struct TidyCondition
    x::Any
    y::Any
    op::Function
end

import Base.isless
Base.isless(x::Symbol, y::Any) = TidyCondition(x, y, <)
Base.isless(x::Any, y::Symbol) = TidyCondition(x, y, <)
Base.isless(x::Symbol, y::Symbol) = TidyCondition(x, y, <)

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