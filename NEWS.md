# User visible changes in `Backport`

- `mapreduce(f, op, itrs...; kwds...)` to extend `mapreduce` for multiple iterators.

- `Memory{T}` is an alias for `Vector{T}` on Julia versions < 1.11.

- `Returns(val)` yields a callable object that returns `val` when called with any
  arguments and keywords.

- `@public` macro to replace the `public` keyword that appears in Julia 1.11.
