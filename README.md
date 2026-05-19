# CSOEM Replication Project

Replication of the small open economy models in:

> Schmitt-Grohé, S. and Uribe, M. (2003),  

> *Closing Small Open Economy Models*,  

> Journal of International Economics, 61, 163–185.

This project reproduces impulse response functions and second moments for the five SGU model specifications using Julia and `MacroModelling.jl`.

## Project Structure

```text
CSOE_Replication/
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
