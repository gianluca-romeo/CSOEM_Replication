# =========================================================
# Baseline calibration for SGU Model 5
# =========================================================

@with_kw struct SGUParams
    # Preferences
    γ::Float64 = 2.0                        # risk aversion
    ω::Float64 = 1.455                      # Frisch-elasticity parameter

    # Technology
    α::Float64 = 0.32                       # labor share
    δ::Float64 = 0.1                        # depreciation rate
    ρ::Float64 = 0.42                       # autocorrelation TFP
    σ_tfp::Float64 = 0.0129                 # standard deviation TFP

    # Capital adjustment cost
    ϕ::Float64 = 0.028                      # capital adjustment cost parameter

    # World interest rate
    rbar::Float64 = 0.04                    # world interest rate 

    # Initial debt level from table 2
    dbar::Float64 = 0.7442
end

function baseline_params()
    return SGUParams()
end