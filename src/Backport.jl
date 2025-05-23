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
    VERSION < v"1.2.0-rc1" && push!(expr.args, :(using Backport: mapreduce))
    VERSION < v"1.6.0-beta1" && push!(expr.args, :(using Backport: reverse, reverse!))
    VERSION < v"1.6.0-beta1" && push!(expr.args, :(using Backport: signed))
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

if VERSION < v"1.6.0-beta1"
    # Prior to Julia 1.6, `reverse` for all dimensions is not defined and `reverse!` does
    # not accept keywords. NOTE Helper functions `_reverse` and `_reverse!` are introduced
    # for inference to work.
    reverse(args...; kwds...) = Base.reverse(args...; kwds...)
    reverse!(args...; kwds...) = Base.reverse!(args...; kwds...)
    reverse(A::AbstractArray; dims = :) = _reverse(A, dims)
    reverse!(A::AbstractArray; dims = :) = _reverse!(A, dims)
    _reverse(A::AbstractVector, d::Integer) =
        isone(d) ? Base.reverse(A) : throw(ArgumentError("invalid dimension $d ≠ 1"))
    _reverse!(A::AbstractVector, d::Integer) =
        isone(d) ? Base.reverse!(A) : throw(ArgumentError("invalid dimension $d ≠ 1"))
    _reverse(A::AbstractArray, d) = Base.reverse(A; dims=d)
    _reverse!(A::AbstractArray, d) = copyto!(A, Base.reverse(A; dims=d))
    _reverse(A::AbstractVector, ::Colon) = Base.reverse(A)
    _reverse!(A::AbstractVector, ::Colon) = Base.reverse!(A)
    _reverse(A::AbstractArray, ::Colon) = _reverse!(Base.copymutable(A), :)
    function _reverse!(A::AbstractArray, ::Colon)
        I = eachindex(A)
        k = last(I) + first(I)
        @inbounds for i in I
            (j = k - i) > i || break
            Ai = A[i]
            Aj = A[j]
            A[i] = Aj
            A[j] = Ai
        end
        return A
    end
end

if VERSION < v"1.6.0-beta1"
    signed(args...; kwds...) = Base.signed(args...; kwds...)
    signed(::Type{Bool}) = Int
    if VERSION < v"1.5.0-beta1"
        for (U, S) in (:UInt8 => :Int8, :UInt16 => :Int16, :UInt32 => :Int32,
                       :UInt64 => :Int64, :UInt128 => :Int128)
            @eval signed(::Type{$U}) = $S
        end
        signed(::Type{T}) where {T<:Signed} = T
    end
end

"""
    @public args...

declares `args...` as being `public` even though they are not exported. For Julia version
< 1.11, this macro does nothing. Using this macro also avoid errors with CI and coverage
tools.

"""
macro public(args::Union{Symbol,Expr}...)
    VERSION ≥ v"1.11.0-DEV.469" ? esc(Expr(:public, map(
        x -> x isa Symbol ? x :
            x isa Expr && x.head == :macrocall ? x.args[1] :
            error("unexpected argument `$x` to `@public`"), args)...)) : nothing
end

end
