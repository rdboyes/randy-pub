# This file was generated, do not modify it. # hide
struct TidyMutation
    f::Function
    args::Vector{Any}
end

function mutate(args...; kwargs...)
    for m in kwargs
        symlist = Symbol[]
        for arg in m[2].args
            if arg isa Symbol # i.e., a column reference
                push!(symlist, arg)
            end
        end
        if length(symlist) == 1
            return TidyExpr(
                df -> transform(df,
                    symlist[1] => (x -> m[2].f(x)) => [Symbol(m[1])]
                )
            )
        end
    end
end

Base.:(|>)(x::Symbol, y::Function) = TidyMutation(y, [x])