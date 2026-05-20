# =========================================================
# Steady state for SGU Model 5
# =========================================================

@with_kw struct SGUSteadyState
    c::Float64
    h::Float64
    y::Float64
    i::Float64
    k::Float64
    d::Float64
    tb_y::Float64
    ca_y::Float64
    λ::Float64
    r::Float64
    util::Float64
    a::Float64
    β::Float64
end

function steady_state(p::SGUParams = baseline_params())

    α = p.α
    ω = p.ω
    rbar = p.rbar
    δ = p.δ
    dbar = p.dbar
    γ = p.γ

    β = 1 / (1 + rbar)

    r = rbar
    d = dbar

    h = ((1 - α) * (α / (rbar + δ))^(α / (1 - α)))^(1 / (ω - 1))
    k = h / (((rbar + δ) / α)^(1 / (1 - α)))
    y = k^α * h^(1 - α)
    i = δ * k
    c = y - i - rbar * d

    tb_y = 1 - (c + i) / y
    ca_y = 0.0

    λ = (c - h^ω / ω)^(-γ)
    util = ((c - h^ω / ω)^(1 - γ) - 1) / (1 - γ)

    # a = 1.0
    a = 0.0

    return SGUSteadyState(
        c = c,
        h = h,
        y = y,
        i = i,
        k = k,
        d = d,
        tb_y = tb_y,
        ca_y = ca_y,
        λ = λ,
        r = r,
        util = util,
        a = a,
        β = β
    )
end