using Backport
@backport
using Test

@testset "Backport.jl" begin
    @testset "mapreduce" begin
        @test mapreduce(*, +, (1,2), (3,4)) === 11
        @test mapreduce(+, *, (1,2), (3,4)) === 24
        @test mapreduce(abs, +, (-1, 2, 3, -4)) === 10
    end
    @testset "Memory{T}" begin
        v = @inferred Memory{UInt8}(undef, 7)
        @test v isa Memory{UInt8}
        @test v isa AbstractVector{UInt8}
        @test v isa DenseVector{UInt8}
        @test length(v) == 7
        @test keys(v) == 1:7
    end
    @testset "Returns" begin
        f = @inferred Returns(pi)
        @test f() === pi
        @test f(1,"e"; a=9) === pi
        f = @inferred Returns{Float32}(pi)
        @test f() === Float32(pi)
        @test f(; c=:foo, d=1) === Float32(pi)
    end
    @testset "`reverse` and `reverse!` with `dims=$d`" for d in (Colon(), 1, 2)
        if d isa Colon || d == 1
            # Check for vectors.
            A = 1:12
            R = 12:-1:1
            B = @inferred reverse(A; dims=d)
            @test B == R
            @test B isa AbstractRange{eltype(A)}
            @test step(B) == -step(A)
            @test last(B) == first(A)
            @test first(B) == last(A)
            C = Array{eltype(A)}(undef, size(A))
            @test C === @inferred reverse!(copyto!(C, A); dims=d)
            @test C == R
            if d isa Colon
                @test R == @inferred reverse(A)
                @test C === @inferred reverse!(copyto!(C, A))
                @test C == R
            end
            A = -2:3:7
            R = 7:-3:-2
            B = @inferred reverse(A; dims=d)
            @test B == R
            @test B isa AbstractRange{eltype(A)}
            @test step(B) == -step(A)
            @test last(B) == first(A)
            @test first(B) == last(A)
            C = Array{eltype(A)}(undef, size(A))
            @test C === @inferred reverse!(copyto!(C, A); dims=d)
            @test C == R
            if d isa Colon
                @test R == @inferred reverse(A)
                @test C === @inferred reverse!(copyto!(C, A))
                @test C == R
            end
        end
        if d isa Colon || d ≤ 2
            # Check for 2-dimensional arrays.
            A = reshape(1:12, 3,4)
            R = d isa Colon ? reshape(12:-1:1, size(A)) : Base.reverse(A; dims=d)
            C = Array{eltype(A)}(undef, size(A))
            @test R == @inferred reverse(A; dims=d)
            @test C === @inferred reverse!(copyto!(C, A); dims=d)
            @test C == R
            if d isa Colon
                @test R == @inferred reverse(A)
                @test C === @inferred reverse!(copyto!(C, A))
                @test C == R
            end
            A = reshape(1:12, 4,3)
            C = Array{eltype(A)}(undef, size(A))
            R = d isa Colon ? reshape(12:-1:1, size(A)) : Base.reverse(A; dims=d)
            @test R == @inferred reverse(A; dims=d)
            @test C === @inferred reverse!(copyto!(C, A); dims=d)
            @test C == R
            if d isa Colon
                @test R == @inferred reverse(A)
                @test C === @inferred reverse!(copyto!(C, A))
                @test C == R
            end
        end
        if d isa Colon || d ≤ 3
            # Check for 3-dimensional arrays.
            A = reshape(-4:5:111, 2,3,4)
            R = d isa Colon ? reshape(111:-5:-4, size(A)) : Base.reverse(A; dims=d)
            C = Array{eltype(A)}(undef, size(A))
            @test R == @inferred reverse(A; dims=d)
            @test C === @inferred reverse!(copyto!(C, A); dims=d)
            @test C == R
            if d isa Colon
                @test R == @inferred reverse(A)
                @test C === @inferred reverse!(copyto!(C, A))
                @test C == R
            end
        end
    end
end
