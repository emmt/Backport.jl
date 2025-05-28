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
    @testset "`reverse` and `reverse!`" begin
        @testset "... basic use" begin
            @test reverse("abcd") == "dcba"
            r = 1:8
            v = Array{Int}(undef, length(r))
            @test reverse(r, 2) == [1,8,7,6,5,4,3,2]
            @test reverse(r, 3, 6) == [1,2,6,5,4,3,7,8]
            @test reverse(r; dims=:) === 8:-1:1
            @test reverse(r; dims=1) === 8:-1:1
            @test reverse(copyto!(v, r); dims=:) == 8:-1:1
            @test_throws ArgumentError reverse(r; dims=0)
            @test v === reverse!(copyto!(v, r), 2) && v == [1,8,7,6,5,4,3,2]
            @test v === reverse!(copyto!(v, r), 3, 6) && v == [1,2,6,5,4,3,7,8]
            @test v === reverse!(copyto!(v, r); dims=:) && v == [8,7,6,5,4,3,2,1]
            @test_throws ArgumentError reverse!(v; dims=0)
        end
        @testset "... with `dims=$d`" for d in (Colon(), 1, 2)
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

    @testset "`signed($T) -> $S`" for (T, S) in (Bool    => Int,
                                                 UInt8   => Int8,   Int8   => Int8,
                                                 UInt16  => Int16,  Int16  => Int16,
                                                 UInt32  => Int32,  Int32  => Int32,
                                                 UInt64  => Int64,  Int64  => Int64,
                                                 UInt128 => Int128, Int128 => Int128,
                                                 BigInt  => BigInt)
        # Check new behavior.
        @test signed(T) === S

        # Check previously existing behavior.
        if isbitstype(T)
            @test signed(zero(T)) === zero(S)
            @test signed(one(T)) === one(S)
        else
            @test signed(zero(T)) == zero(S)
            @test typeof(signed(zero(T))) === S
            @test signed(one(T)) == one(S)
            @test typeof(signed(one(T))) === S
        end
    end

    @testset "`inv($x)`" for x in (1.0, pi, [1 0; 0 2])
        if x isa Number
            @test inv(x) === true/x
        elseif x == [1 0; 0 2]
            @test inv(x) == [1//1 0//1; 0//1 1//2]
        end
    end

end
