module Backport

export @public, @backport

# Fall-back methods call the base ones.
for f in (:inv, :mapreduce, :reverse!, :reverse, :signed)
    @eval @inline $f(args...; kwds...) = Base.$f(args...; kwds...)
end

"""
    @backport
    @backport mapreduce signed ...

import in the current module the symbols defined by `Backport` to emulate features
appearing in more recent Julia versions. Without arguments, all symbols defined by
`Backport` and relevant for the running Julia version are imported; otherwise, only the
specified symbols are imported.

Typical usage is:

```julia
module Foo
    using Backport
    @backport [args...]

    # Module code here.
end # module
```

"""
macro backport(args::Symbol...)
    expr = Expr(:block)
    for (vmin, sym) in (
        v"1.2.0-rc1"   => :mapreduce,
        v"1.2.0-rc2"   => :inv,
        v"1.6.0-beta1" => :reverse!,
        v"1.6.0-beta1" => :reverse,
        v"1.6.0-beta1" => :signed,
        )
        if VERSION < vmin && (isempty(args) || sym ∈ args)
            push!(expr.args, :(using Backport: $sym))
        end
    end
    esc(expr)
end

if VERSION < v"1.2.0-rc1"
    # `mapreduce` is not implemented for multiple iterators prior to Julia 1.2.
    mapreduce(f, op, itr; kw...) = Base.mapreduce(f, op, itr; kw...)
    mapreduce(f, op, itrs...; kw...) = Base.reduce(op, Base.Generator(f, itrs...); kw...)
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
    signed(::Type{Bool}) = Int
    if VERSION < v"1.5.0-beta1"
        for (U, S) in (:UInt8 => :Int8, :UInt16 => :Int16, :UInt32 => :Int32,
                       :UInt64 => :Int64, :UInt128 => :Int128)
            @eval signed(::Type{$U}) = $S
        end
        signed(::Type{T}) where {T<:Signed} = T
    end
end

if VERSION < v"1.2.0-rc2"
    # `inv(x)` was not implemented for irrational numbers prior to Julia 1.2.0-rc2
    inv(x::AbstractIrrational) = 1/x
end

"""
    @public a b c ...
    @public a, b, c, ...

Declare symbols `a`, `b`, `c`, etc. as being `public` even though they are not exported. For
Julia version < 1.11, this macro does nothing. Using this macro also avoid errors with CI
and coverage tools.

"""
macro public(args...)
    VERSION ≥ v"1.11.0-DEV.469" || return nothing
    # `@public a b c` and `@public(a, b, c)` are the same, but `@public a, b, c` is
    # different. Make `xs` a tuple or a vector of public symbols in these different cases.
    xs = args isa Tuple{Expr} && args[1].head === :tuple ? args[1].args : args
    return esc(Expr(:public, map(
        x -> x isa Symbol ? x : x isa Expr && x.head == :macrocall ? x.args[1] :
            error("unexpected argument `$x` to `@public`"), xs)...))
end

end
