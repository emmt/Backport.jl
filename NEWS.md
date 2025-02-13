# User visible changes in `Backport`

- `mapreduce(f, op, itrs...; kwds...)` to extend `mapreduce` for multiple iterators.

- `Returns(val)` yields a callable object that returns `val` when called with any
  arguments and keywords.

- `@public` macro to replace the `public` keyword that appears in Julia 1.11.
