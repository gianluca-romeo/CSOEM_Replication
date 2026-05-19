# ============================================================================
# Replication of Schmitt-Grohé and Uribe (2003)
#
# Authors: Gianluca Romeo and Matteo Cagno
#
# Affiliation: Collegio Carlo Alberto
# Date: May 2026
#
# Reference:
# Schmitt-Grohé, S. and Uribe, M. (2003),
# "Closing Small Open Economy Models",
# Journal of International Economics, 61, 163-185.
# ============================================================================

# Uncomment and run only once when initializing the project environment:
# using Pkg
# Pkg.activate(".")
# Pkg.instantiate()

using Pkg
Pkg.activate(@__DIR__)

include("src/models.jl")
include("src/irf_tools.jl")
include("src/moment_tools.jl")

# Select which model specifications to run:
# 1 = run model
# 0 = skip model (the model will be executed but will not be in the irf's plot and moment's table)
active_models = Dict(
    "M1"  => 1,
    "M1a" => 1,
    "M2"  => 1,
    "M3"  => 1,
    "M4"  => 1
)

output_dir = joinpath(@__DIR__, "output")

run_sgu_irfs(
    active_models;
    output_dir = output_dir,
    periods = 10,
    # Scale the shock so that the effective TFP innovation equals one:
    # sigma_tfp (that is 0.0129) * shock_size = 1
    shock_size = 1 / 0.0129,
    save_name = "Selected_models_IRFs.png"
)

run_moment_table(active_models; output_dir)