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
end
