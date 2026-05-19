# ============================================================================
# Tests for the replication of Schmitt-Grohé and Uribe (2003)
#
# Authors: Gianluca Romeo and Matteo Cagno
# ============================================================================

using Test
using MacroModelling

# Load project files
include("../src/models.jl")
include("../src/irf_tools.jl")
include("../src/moment_tools.jl")

# Test: steady states
@testset "Steady State Tests" begin

    models = [
        SGU_M1,
        SGU_M1a,
        SGU_M2,
        SGU_M3,
        SGU_M4
    ]

    for model in models

        ss = get_non_stochastic_steady_state(model)

        @test length(ss) > 0
        @test !any(isnan, ss)

    end
end

# Test: IRFs
@testset "IRF Tests" begin

    irf = get_irf(
        SGU_M1;
        periods = 3,
        variables = [:y]
    )

    @test size(irf, 2) == 3

end

# Test: moments
@testset "Moment Tests" begin

    stds = get_standard_deviation(SGU_M1)

    @test !any(isnan, stds)

end

# Test: output generation
@testset "Output File Tests" begin

    active_models = Dict(
        "M1"  => 1,
        "M1a" => 0,
        "M2"  => 0,
        "M3"  => 0,
        "M4"  => 0
    )

    output_dir = joinpath(@__DIR__, "..", "output", "test")

    run_moment_table(active_models; output_dir)

    @test isfile(joinpath(output_dir, "SGU_moments.csv"))

end