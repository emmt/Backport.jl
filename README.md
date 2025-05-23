# `Backport` makes your code run on older Julia versions

[![Build Status](https://github.com/emmt/Backport.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Backport.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Backport.jl?svg=true)](https://ci.appveyor.com/project/emmt/Backport-jl) [![Coverage](https://codecov.io/gh/emmt/Backport.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Backport.jl)

`Backport` helps to make your code run on older [Julia](http://julialang.org/) versions.
This package takes advantage on the fact that many features introduced by new Julia
versions are written in Julia itself and are thus easy to back-port into older Julia
versions and make them more widely available.

## Usage

Once [installed](#installation), just do:

``` julia
using Backport
@backport
```

where `using Backport` loads the package and brings into scope some symbols while
`@backport` automatically uses replacement methods/symbols from `Backport` depending on
the Julia version. These 2 steps are needed to avoid conflicts with existing definitions.
For example, without the 2nd step and in Julia older than 1.2, the `mapreduce`, `reverse`,
and `reverse!` replacement methods must be qualified, that is called as
`Backport.mapreduce(...)`, `Backport.reverse(...)`, etc.


## Related projects

[`Compat`](https://github.com/JuliaLang/Compat.jl) has a similar objective but via a
`@compat` macro and does not backport some useful things.

## Features

### `mapreduce` with more than one iterator

Method `mapreduce` with more than one iterator was introduced in Julia 1.2:

``` julia
mapreduce(f, op, itrs...; kwds...)
```

To back-port this feature in your code:

``` julia
using Backport
@backport
```

or

``` julia
using Backport
using Backport: mapreduce
```

### `Memory{T}`

Type `Memory{T}` was introduced in Julia 1.11 to represent a fixed-size dense vector of
elements of type `T`. On older Julia versions, `Backport` defines `Memory{T}` as an alias
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

``` julia
using Backport
@backport
```

or

``` julia
using Backport
using Backport: reverse, reverse!
```

### `signed(T::Type)`

Method `signed(T)` for `T<:Integer` appeared in Julia 1.5 and `signed(Bool)` appeared in
Julia 1.6 to yield the signed counterpart of an unsigned integer type. To back-port this
feature in your code:

``` julia
using Backport
@backport
```

or

``` julia
using Backport
using Backport: signed
```

### `public`

The `public` keyword was introduced in Julia 1.11; as a replacement:

``` julia
@public foo bar [...]
```

declares symbols `foo`, `bar`, etc. as `public` in Julia ≥ 1.11 and does nothing in older
Julia versions.


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
