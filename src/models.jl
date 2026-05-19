# ============================================================================
# Replication of Schmitt-Grohé and Uribe (2003)
#
# Authors: Gianluca Romeo and Matteo Cagno
#
# This file defines the five SGU model specifications using MacroModelling.jl.
# The implementation follows the original Dynare replication files by
# Johannes Pfeifer, with equations rewritten in levels and adapted to the
# MacroModelling.jl syntax.
#
# The models correspond to:
#   M1  : Endogenous discount factor
#   M1a : Endogenous discount factor (without internalization)
#   M2  : Debt-elastic interest rate premium
#   M3  : Portfolio adjustment costs
#   M4  : Complete asset market closure
#
# Reference:
# Schmitt-Grohé, S. and Uribe, M. (2003),
# "Closing Small Open Economy Models",
# Journal of International Economics, 61, 163-185.
# ============================================================================

using MacroModelling

# Compute manually psi_1
gamma_val = 2.0
omega_val = 1.455
alpha_val = 0.32
phi_val = 0.028
r_bar_val = 0.04
delta_val = 0.1
d_bar_val = 0.7442

h_ss = ((1 - alpha_val) * (alpha_val / (r_bar_val + delta_val))^(alpha_val / (1 - alpha_val)))^(1 / (omega_val - 1))
k_ss = h_ss / (((r_bar_val + delta_val) / alpha_val)^(1 / (1 - alpha_val)))
y_ss = k_ss^alpha_val * h_ss^(1 - alpha_val)
i_ss = delta_val * k_ss
c_ss = y_ss - i_ss - r_bar_val * d_bar_val

psi_1_val = -log(1 / (1 + r_bar_val)) / log(1 + c_ss - h_ss^omega_val / omega_val)

# println("psi_1 = ", psi_1_val)


@model SGU_M1 begin
    d[0] = (1 + r[-1]) * d[-1] - y[0] + c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2
    y[0] = A[0] * k[-1]^alpha * h[0]^(1 - alpha)
    k[0] = i[0] + (1 - delta) * k[-1]
    lambda[0] = beta_fun[0] * (1 + r[0]) * lambda[1]
    lambda[0] = (c[0] - h[0]^omega / omega)^(-gamma) - eta[0] * (-psi_1 * (1 + c[0] - h[0]^omega / omega)^(-psi_1 - 1))
    eta[0] = -util[1] + eta[1] * beta_fun[1]
    (c[0] - h[0]^omega / omega)^(-gamma) * h[0]^(omega - 1) + eta[0] * (-psi_1 * (1 + c[0] - h[0]^omega / omega)^(-psi_1 - 1) * (-h[0]^(omega - 1))) = lambda[0] * (1 - alpha) * y[0] / h[0]
    lambda[0] * (1 + phi * (k[0] - k[-1])) = beta_fun[0] * lambda[1] * (alpha * y[1] / k[0] + 1 - delta + phi * (k[1] - k[0]))
    log(A[0]) = rho * log(A[-1]) + sigma_tfp * eps_a[x]
    beta_fun[0] = (1 + c[0] - h[0]^omega / omega)^(-psi_1)
    util[0] = ((c[0] - h[0]^omega / omega)^(1 - gamma) - 1) / (1 - gamma)
    r[0] = r_bar + 0 * r[-1]
    tb_y[0] = 1 - (c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2) / y[0]
    ca_y[0] = (d[-1] - d[0]) / y[0]
end

@parameters SGU_M1 begin
    gamma = 2.0
    omega = 1.455
    alpha = 0.32
    phi = 0.028
    r_bar = 0.04
    delta = 0.1
    rho = 0.42
    sigma_tfp = 0.0129
    psi_1 = 0.11193249752934411
    d_bar = 0.7442
end



@model SGU_M1a begin
    d[0] = (1 + r[-1]) * d[-1] - y[0] + c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2
    y[0] = A[0] * k[-1]^alpha * h[0]^(1 - alpha)
    k[0] = i[0] + (1 - delta) * k[-1]
    lambda[0] = beta_fun[0] * (1 + r[0]) * lambda[1]
    lambda[0] = (c[0] - h[0]^omega / omega)^(-gamma)
    (c[0] - h[0]^omega / omega)^(-gamma) * h[0]^(omega - 1) = lambda[0] * (1 - alpha) * y[0] / h[0]
    lambda[0] * (1 + phi * (k[0] - k[-1])) = beta_fun[0] * lambda[1] * (alpha * y[1] / k[0] + 1 - delta + phi * (k[1] - k[0]))
    log(A[0]) = rho * log(A[-1]) + sigma_tfp * eps_a[x]
    beta_fun[0] = (1 + c[0] - h[0]^omega / omega)^(-psi_1)
    util[0] = ((c[0] - h[0]^omega / omega)^(1 - gamma) - 1) / (1 - gamma)
    r[0] = r_bar + 0 * r[-1]
    tb_y[0] = 1 - (c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2) / y[0]
    ca_y[0] = (d[-1] - d[0]) / y[0]
end


@parameters SGU_M1a begin
    gamma = 2.0
    omega = 1.455
    alpha = 0.32
    phi = 0.028
    r_bar = 0.04
    delta = 0.1
    rho = 0.42
    sigma_tfp = 0.0129
    d_bar = 0.7442

    psi_1 = 0.11134984300920668
end



@model SGU_M2 begin
    d[0] = (1 + r[-1]) * d[-1] - y[0] + c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2
    y[0] = A[0] * k[-1]^alpha * h[0]^(1 - alpha)
    k[0] = i[0] + (1 - delta) * k[-1]
    lambda[0] = beta * (1 + r[0]) * lambda[1]
    lambda[0] = (c[0] - h[0]^omega / omega)^(-gamma)
    (c[0] - h[0]^omega / omega)^(-gamma) * h[0]^(omega - 1) = lambda[0] * (1 - alpha) * y[0] / h[0]
    lambda[0] * (1 + phi * (k[0] - k[-1])) = beta * lambda[1] * (alpha * y[1] / k[0] + 1 - delta + phi * (k[1] - k[0]))
    log(A[0]) = rho * log(A[-1]) + sigma_tfp * eps_a[x]
    r[0] = r_bar + riskpremium[0]
    riskpremium[0] = psi_2 * (exp(d[0] - d_bar) - 1)
    tb_y[0] = 1 - (c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2) / y[0]
    ca_y[0] = (d[-1] - d[0]) / y[0]
    util[0] = ((c[0] - h[0]^omega / omega)^(1 - gamma) - 1) / (1 - gamma)
end

@parameters SGU_M2 begin
    gamma = 2.0
    omega = 1.455
    alpha = 0.32
    phi = 0.028
    r_bar = 0.04
    delta = 0.1
    rho = 0.42
    sigma_tfp = 0.0129
    psi_2 = 0.000742
    d_bar = 0.7442
    beta = 1 / (1 + r_bar)
end



@model SGU_M3 begin
    d[0] = (1 + r[-1]) * d[-1] - y[0] + c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2 + (psi_3 / 2) * (d[0] - d_bar)^2
    y[0] = A[0] * k[-1]^alpha * h[0]^(1 - alpha)
    k[0] = i[0] + (1 - delta) * k[-1]
    lambda[0] * (1 - psi_3 * (d[0] - d_bar)) = beta * (1 + r[0]) * lambda[1]
    lambda[0] = (c[0] - h[0]^omega / omega)^(-gamma)
    (c[0] - h[0]^omega / omega)^(-gamma) * h[0]^(omega - 1) = lambda[0] * (1 - alpha) * y[0] / h[0]
    lambda[0] * (1 + phi * (k[0] - k[-1])) = beta * lambda[1] * (alpha * y[1] / k[0] + 1 - delta + phi * (k[1] - k[0]))
    log(A[0]) = rho * log(A[-1]) + sigma_tfp * eps_a[x]
    r[0] = r_bar + 0 * r[-1] #fake zero per
    tb_y[0] = 1 - (c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2) / y[0]
    ca_y[0] = (d[-1] - d[0]) / y[0]
    util[0] = ((c[0] - h[0]^omega / omega)^(1 - gamma) - 1) / (1 - gamma)
end

@parameters SGU_M3 begin
    gamma = 2.0
    omega = 1.455
    alpha = 0.32
    phi = 0.028
    r_bar = 0.04
    delta = 0.1
    rho = 0.42
    sigma_tfp = 0.0129
    psi_3 = 0.00074
    d_bar = 0.7442
    beta = 1 / (1 + r_bar)
end


# Compute manually psi_4
gamma_val = 2.0
omega_val = 1.455
alpha_val = 0.32
r_bar_val = 0.04
delta_val = 0.1

h_ss = ((1 - alpha_val) * (alpha_val / (r_bar_val + delta_val))^(alpha_val / (1 - alpha_val)))^(1 / (omega_val - 1))
c_ss = exp(0.110602)

psi_4_val = (c_ss - h_ss^omega_val / omega_val)^(-gamma_val)

# println(psi_4_val)


@model SGU_M4 begin
    y[0] = A[0] * k[-1]^alpha * h[0]^(1 - alpha)
    k[0] = i[0] + (1 - delta) * k[-1]
    lambda[0] = (c[0] - h[0]^omega / omega)^(-gamma)
    (c[0] - h[0]^omega / omega)^(-gamma) * h[0]^(omega - 1) = lambda[0] * (1 - alpha) * y[0] / h[0]
    lambda[0] * (1 + phi * (k[0] - k[-1])) = beta * lambda[1] * (alpha * y[1] / k[0] + 1 - delta + phi * (k[1] - k[0]))
    lambda[0] = psi_4 + 0 * lambda[-1]
    log(A[0]) = rho * log(A[-1]) + sigma_tfp * eps_a[x]
    tb_y[0] = 1 - (c[0] + i[0] + (phi / 2) * (k[0] - k[-1])^2) / y[0]
    util[0] = ((c[0] - h[0]^omega / omega)^(1 - gamma) - 1) / (1 - gamma)
end

@parameters SGU_M4 begin
    gamma = 2.0
    omega = 1.455
    alpha = 0.32
    phi = 0.028
    r_bar = 0.04
    delta = 0.1
    rho = 0.42
    sigma_tfp = 0.0129
    beta = 1 / (1 + r_bar)

    psi_4 = 5.609090644454163
end