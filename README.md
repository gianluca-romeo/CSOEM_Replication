# CSOEM Replication

Replication of the models in:

> Schmitt-Grohé, S. and Uribe, M. (2003),  
> *Closing Small Open Economy Models*,  
> Journal of International Economics, 61, 163–185.

The project reproduces impulse response functions and second moments for the models using Julia.

The implementation is based on the Dynare replication code by Johannes Pfeifer:
https://github.com/JohannesPfeifer/DSGE_mod/tree/master/SGU_2003


## Project Structure

```text
CSOEM_Replication/
│
├── src/
│   ├── models.jl          # SGU model specifications
│   ├── irf_tools.jl       # IRF generation and plotting
│   └── moment_tools.jl    # Computation of second moments
│
├── test/
│   └── runtests.jl        # Basic project tests
│
├── output/
│   └── figures and tables/
│
├── run.jl                 # Main execution script
├── Project.toml           # Project dependencies
├── Manifest.toml          # Reproducible package versions
└── README.md
```

## Installation

Open Julia in the project directory and run:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Run

From the terminal, inside the project directory:

```bash
julia run.jl
```

## Authors

- Gianluca Romeo
- Matteo Cagno
