# ============================================================================
# Tests for the replication of Schmitt-Grohé and Uribe (2003)
# Authors: Gianluca Romeo and Matteo Cagno
# ============================================================================

using Test

include("../src/CSOEM_Replication.jl")
using .CSOEM_Replication

@testset "Models 1-4 basic functionality" begin

    ss = CSOEM_Replication.get_non_stochastic_steady_state(CSOEM_Replication.SGU_M1)
    @test length(ss) > 0
    @test !any(isnan, ss)

    irf = CSOEM_Replication.get_irf(
        CSOEM_Replication.SGU_M1;
        periods = 3,
        variables = [:y]
    )
    @test size(irf, 2) == 3

    stds = CSOEM_Replication.get_standard_deviation(CSOEM_Replication.SGU_M1)
    @test !any(isnan, stds)

end

@testset "Moment table output" begin

    active_models = Dict(
        "M1"  => 1,
        "M1a" => 0,
        "M2"  => 0,
        "M3"  => 0,
        "M4"  => 0
    )

    output_dir = joinpath(@__DIR__, "output")

    CSOEM_Replication.run_moment_table(
        active_models;
        output_dir = output_dir
    )

    @test isfile(joinpath(output_dir, "tables", "selected_models_moments.csv"))

end

@testset "Model 5 steady state and solver" begin

    p = CSOEM_Replication.baseline_params()
    ss = CSOEM_Replication.steady_state(p)

    @test ss.c > 0
    @test ss.k > 0
    @test ss.h > 0
    @test ss.y > 0
    @test ss.i > 0
    @test ss.λ > 0
    @test ss.a == 0.0

    df = CSOEM_Replication.solve_model5_pf(
        horizon = 10,
        shock_std = 0.01 / p.σ_tfp,
        terminal_condition = :zero_terminal_debt_drift
    )

    @test size(df, 1) == 10
    @test "output" in names(df)
    @test "consumption" in names(df)
    @test "debt" in names(df)
    @test !any(any.(ismissing, eachcol(df)))

end