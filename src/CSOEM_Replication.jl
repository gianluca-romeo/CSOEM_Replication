module CSOEM_Replication

using MacroModelling
using CSV
using DataFrames
using NLsolve
using LinearAlgebra
using Parameters
using Plots
using AxisKeys
using DelimitedFiles

# Models 1 to 4
include("models.jl")
include("irf_tools.jl")
include("moment_tools.jl")

# Model 5: perfect foresight
include("M5_calibration.jl")
include("M5_steadystate.jl")
include("M5_solver.jl")
include("M5_irfs.jl")

export run_sgu_irfs
export run_moment_table
export M5_plot_irfs

end