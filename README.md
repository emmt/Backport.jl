# `Backport.jl` makes your code run with older Julia versions

[![Build Status](https://github.com/emmt/Backport.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Backport.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Backport.jl?svg=true)](https://ci.appveyor.com/project/emmt/Backport-jl) [![Coverage](https://codecov.io/gh/emmt/Backport.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Backport.jl)

`Backport.jl` helps to make your code run with older [Julia](http://julialang.org/)
versions. This package takes advantage on the fact that many features introduced by new
Julia versions are written in pure Julia and are thus easy to back-port into older Julia
versions and make them more widely available.

## Usage

Once [installed](#installation), just do:

``` julia
using Backport
```

where `using Backport` loads the package and brings into scope the restricted set of
symbols defined in `Backport`, that are relevant for the running Julia version, and that
do not conflict with existing definitions.

To use some back-ported method like `mapreduce` and `signed`:

``` julia
using Backport: mapreduce, signed
```

or use the `@backport` macro:

``` julia
@backport mapreduce signed
```

without this, the version of `mapreduce` fixing the behavior of this method for Julia
older than 1.2 must be qualified, that is called as `Backport.mapreduce(...)`.

To back-port all relevant symbols for the running Julia version:

``` julia
@backport
```


## Related projects

[`Compat`](https://github.com/JuliaLang/Compat.jl) has a similar objective but via a
`@compat` macro and does not back-port some useful things, in particular no substitute for
the `public` keyword, nor for the methods .


## Features

### `mapreduce` with more than one iterator

Method `mapreduce` with more than one iterator was introduced in Julia 1.2:

``` julia
mapreduce(f, op, itrs...; kwds...)
```

To back-port this specific feature in your code:

``` julia
@backport mapreduce
```

or back-port all features with:

``` julia
@backport
```

### `Memory{T}`

Type `Memory{T}` was introduced in Julia 1.11 to represent a fixed-size dense vector of
elements of type `T`. In older Julia versions, `Backport` defines `Memory{T}` as an alias
to `Vector{T}` so that:

``` julia
Memory{T}(undef, n)
```

yields a dense vector of `n` elements of type `T`. The main difference is that the result
is not fixed-size but resizable.


### `Returns`

Type `Returns` was introduced in Julia 1.7:

``` julia
f = Returns(val)
```

yields a callable object `f` such that `f(args...; kwds...)` always yields `val`.


### `reverse` and `reverse!` along all dimensions

Prior to Julia 1.6, `reverse(A; dims=:)` and `reverse!(A; dims=:)` to reverse array `A`
along all its dimensions was not implemented. To back-port this feature in your code:

To back-port these specific features in your code:

``` julia
@backport reverse reverse!
```

or back-port all features with:

``` julia
@backport
```

### `signed(T::Type)`

Method `signed(T)` for `T<:Integer` appeared in Julia 1.5 and `signed(Bool)` appeared in
Julia 1.6 to yield the signed counterpart of an unsigned integer type. To back-port this
feature in your code:

To back-port this specific feature in your code:

``` julia
@backport signed
```

or back-port all features with:

``` julia
@backport
```

### `inv` for irrational numbers

Method `inv(x)` for `x` irrational numbers only appeared in Julia 1.2. To back-port this
feature in your code:

To back-port this specific feature in your code:

``` julia
@backport inv
```

or back-port all features with:

``` julia
@backport
```

### `public`

The `public` keyword was introduced in Julia 1.11; as a replacement:

``` julia
@public foo bar [...]
```

declares symbols `foo`, `bar`, etc. as `public` in Julia ≥ 1.11 and does nothing in older
Julia versions.

## Extending methods

Substitute methods are implemented in `Backport.jl` avoiding type-piracy. This is done by
having a method like `inv` be defined in the `Backport` module so as to fix the behavior
for specific arguments that falls-back to calling the base method for other arguments. For
a method like `inv`, `Backport.inv` and `Base.inv` are two different things that can be
called or extended separately (provided the method be qualified by the module prefix).


## Installation

To install `Backport` so as to follow the main development branch:

``` julia
using Pkg
Pkg.add(url="https://github.com/emmt/Backport.jl")
```

or at the prompt of Julia's package manager (after typing `]` in Julia's REPL):

``` julia
add https://github.com/emmt/Backport.jl
```

Another possibility is to install `Backport` via Julia registry
[`EmmtRegistry`](https://github.com/emmt/EmmtRegistry), from the prompt of Julia's package
manager:

```julia
registry add General
registry add https://github.com/emmt/EmmtRegistry
add Backport
```

Adding the `General` registry (1st line of the above example) is mandatory to have access
to the official Julia packages if you never have used the package manager before.
