# User visible changes in `Backport`

This page describes the most important changes in `Backport`. The format is based on [Keep
a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic
Versioning](https://semver.org/spec).

## Version 0.1.4 (20205-05-21)

### Fixed

- Macro `@public` can deal with simple macros names prefixed by `@`.

### Added

- Provide `signed(T)` for `T<:Integer` appearing in Julia 1.5 and `signed(Bool)` appearing
  in Julia 1.6.

## Version 0.1.3 (20205-02-26)

### Added

- Provide `reverse(A; dims=:)` and `reverse!(A; dims=:)` to reverse array `A` along all
  its dimensions, a possibility that appears in Julia 1.6.

## Version 0.1.2 (20205-02-13)

### Added

- `@backport` macro to automatically inserts `using Backport: ...` statements depending
  on Julia version.

## Version 0.1.1 (20205-02-13)

### Added

- `Memory{T}` is an alias for `Vector{T}` on Julia versions < 1.11.

## Version 0.1.0 (20205-02-13)

### Added

- `mapreduce(f, op, itrs...; kwds...)` to extend `mapreduce` for multiple iterators.

- `Returns(val)` yields a callable object that returns `val` when called with any
  arguments and keywords.

- `@public` macro to replace the `public` keyword that appears in Julia 1.11.
