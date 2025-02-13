module Backport

export @public, @backport

"""
    @backport

imports in a module the symbols defined by `Backport` to emulate features appearing in
more recent Julia versions than that of the Julia executing the code.

Typical usage is:

```julia
module Foo
    using Backport
    @backport

    # Module code here.
end # module
```

"""
macro backport()
    expr = Expr(:block)
    #VERSION < v"1.2.0-rc1" && push!(expr, :(const mapreduce = Backport.mapreduce))
    VERSION < v"1.2.0-rc1" && push!(expr.args, :(using Backport: mapreduce))
    esc(expr)
end

if VERSION < v"1.2.0-rc1"
    # `mapreduce` is not implemented for multiple iterators prior to Julia 1.2.
    mapreduce(f, op, itr; kw...) = Base.mapreduce(f, op, itr; kw...)
    mapreduce(f, op, itrs...; kw...) = Base.reduce(op, Base.Generator(f, itrs...); kw...)
    mapreduce(args...; kwds...) = Base.mapreduce(args...; kwds...)
end

if VERSION < v"1.11.0-alpha1"
    # Replace `Memory{T}` by `Vector{T}`.
    const Memory{T} = Vector{T}
    eval(:(export Memory))
end

if VERSION < v"1.7.0-beta1"
    # `Returns` is not defined prior to Julia 1.7.
    """
        f = Returns(val)

    yields a callable object `f` such that `f(args...; kwds...) === val` always
    holds. This is similar to `Returns` which appears in Julia 1.7.

    You may call:

        f = Returns{T}(val)

    to force the returned value to be of type `T`.

    """
    struct Returns{T}
        value::T
        Returns{T}(value) where {T} = new{T}(value)
        Returns(value::T) where {T} = new{T}(value)
    end
    (obj::Returns)(@nospecialize(args...); @nospecialize(kwds...)) = getfield(obj, :value)
    eval(:(export Returns))
end

"""
    @public args...

declares `args...` as being `public` even though they are not exported. For Julia version
< 1.11, this macro does nothing. Using this macro also avoid errors with CI and coverage
tools.

"""
macro public(args::Union{Symbol,Expr}...)
    if VERSION ≥ v"1.11.0-DEV.469"
        esc(Expr(:public, args...))
    else
        nothing
    end
end

end
