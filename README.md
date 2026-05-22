# CSOEM Replication

Replication and extension of the models in:

> Schmitt-Grohé, S. and Uribe, M. (2003),  
> *Closing Small Open Economy Models*,  
> Journal of International Economics, 61, 163–185.
> <https://www.sciencedirect.com/science/article/abs/pii/S0022199602000569>

The project reproduces impulse response functions and second moments for the small open economy models presented in Schmitt-Grohé and Uribe (2003), using Julia.

The implementation of Models 1–4 is based on the Dynare replication code by Johannes Pfeifer:
https://github.com/JohannesPfeifer/DSGE_mod/tree/master/SGU_2003

In addition, the project extends the analysis of Model 5 by implementing a nonlinear perfect-foresight solver in Julia and comparing alternative terminal conditions for foreign debt dynamics.

### Report

The report of the replication project is available online at:
https://gianluca-romeo.github.io/CSOEM_Replication/

---

## Repository Structure

```text
CSOEM_Replication/
│
├── src/
│   ├── CSOEM_Replication.jl   # Main project module
│   ├── models.jl              # SGU Models 1–4 specifications
│   ├── irf_tools.jl           # IRF generation and plotting
│   ├── moment_tools.jl        # Computation of second moments
│   │
│   ├── M5_calibration.jl      # Calibration for Model 5
│   ├── M5_steadystate.jl      # Steady-state computation for Model 5
│   ├── M5_solver.jl           # Nonlinear perfect-foresight solver
│   └── M5_irfs.jl             # IRFs and terminal-condition comparison
│
├── test/
│   ├── runtests.jl            # Basic project tests
│   └── output/                # Test-generated outputs
│
├── output/
│   ├── figures/               # Generated figures
│   └── tables/                # Generated tables
│
├── run.jl                     # Main execution script
├── Project.toml               # Project dependencies
├── Manifest.toml              # Reproducible package versions
├── report.qmd                 # Online report
├── figures/                   # Folder with images for the report
│
└── README.md
```

---

## Installation

Open Julia in the project directory and run:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

---

## Run

From the terminal, inside the project directory:

```bash
julia run.jl
```

The `run.jl` script allows the user to choose which models to execute.

Models 1–4 can be activated through the `active_models` dictionary:

```julia
active_models = Dict(
    "M1"  => 1,
    "M1a" => 1,
    "M2"  => 1,
    "M3"  => 1,
    "M4"  => 1
)
```

A value equal to `1` activates the model, while `0` skips it.

The perfect foresight extension for Model 5 can be activated separately through:

```julia
run_model5 = 1
```

---

## Tests

Open Julia in the project directory and run:

```julia
using Pkg
Pkg.activate(".")
Pkg.test()
```

The test suite checks:

- Models 1–4 functionality and IRFs;
- moment table generation;
- Model 5 steady state and perfect-foresight solver output.

---

## Authors

- Gianluca Romeo  
- Matteo Cagno
