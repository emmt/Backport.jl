# `Backport` makes your code run on older Julia versions

[![Build Status](https://github.com/emmt/Backport.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/Backport.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/Backport.jl?svg=true)](https://ci.appveyor.com/project/emmt/Backport-jl) [![Coverage](https://codecov.io/gh/emmt/Backport.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/Backport.jl)

`Backport` intends to make your code run on older [Julia](http://julialang.org/) versions.
This package takes advantage on the fact that many features introduced by new Julia
versions are written in Julia itself and are thus easy to backport into older Julia
versions and make them more widely available.

## Usage

Once [installed](#installation), just do:

``` julia
using Backport
```

## Related projects

[`Compat`](https://github.com/JuliaLang/Compat.jl) has a similar objective but via a
`@compat` macro and does not backport some useful things.

## Features

Method `mapreduce` with more than one iterator was introduced in Julia 1.2:

``` julia
Backport.mapreduce(f, op, itrs...; kwds...)
```

Note that, to avoid type-piracy `Backport.mapreduce` is distinct from `Base.mapreduce`,
its use must therefore be qualified by the `Backport.` prefix. Inside a module it is
possible to use `mapreduce` without prefix with something like:

``` julia
module Foo
using Backport
using Backport: mapreduce
...
end # module
```

Type `Returns` was introduced in Julia 1.7:

``` julia
f = Returns(val)
```

yields a callable object `f` such that `f(args...; kwds...)` always yields `val`.

The `public` keyword was introduced in Julia 1.11; as a replacement:

``` julia
@public foo [bar ...]
```

declares symbols `foo`, `bar`, etc. as `public` in Julia ≥ 1.11 and does nothing with
older Julia versions.

## Installation

To install `Backport` so as to follow the main development branch:

``` julia
using Pkg
Pkg.add(url="https://github.com/emmt/Backport.jl")
```

or from the prompt of Julia's package manager (after typing `]` in Julia's REPL):

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

Adding the `General` registry (2nd line of the above example) is mandatory to have access
to the official Julia packages if you never have used the package manager before.
