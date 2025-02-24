# User visible changes in `Backport`

- Provide `reverse(A; dims=:)` and `reverse!(A; dims=:)` to reverse array `A` along all
  its dimensions, a possibility that appears in Julia 1.6.

# Version 0.1.2

- `@backport` macro to automatically inserts `using Backport: ...` statements depending
  on Julia version.

# Version 0.1.1

- `Memory{T}` is an alias for `Vector{T}` on Julia versions < 1.11.

# Version 0.1.0

- `mapreduce(f, op, itrs...; kwds...)` to extend `mapreduce` for multiple iterators.

- `Returns(val)` yields a callable object that returns `val` when called with any
  arguments and keywords.

- `@public` macro to replace the `public` keyword that appears in Julia 1.11.
