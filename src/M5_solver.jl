# =========================================================
# Perfect-foresight solver for SGU Model 5
# =========================================================

function model5_pf_quantities(
    c::Float64,
    k::Float64,
    k_next::Float64,
    d::Float64,
    d_prev::Float64,
    A::Float64,
    p::SGUParams
)

    # Eq. (26) in Dynare: intratemporal labor FOC.
    # The labor condition is solved analytically for h_t
    # after substituting out marginal utility λ_t.
    #
    # Dynare equation:
    # ((exp(c)-((exp(h)^omega)/omega))^(-gamma))*(exp(h)^(omega-1))  = exp(lambda)*(1-alpha)*exp(y)/exp(h)
    #
    # Using λ_t = (c_t - h_t^ω/ω)^(-γ) : see eq. (25)
    #
    # the marginal utility terms cancel out and imply:
    # h_t^(ω-1) = (1-α) * y_t / h_t
    #
    # together with the production function.
    # ---------------------------------------------------------
    h = ((1 - p.α) * A * k^p.α)^(1 / (p.ω - 1 + p.α))

    # Eq. (5) in Dynare: production function.
    #
    # In Dynare:
    # exp(y) = exp(a)*(exp(k(-1))^alpha)*(exp(h)^(1-alpha))
    #
    # In levels (k denotes predetermined capital, that is k(-1) in Dynare)
    # y_t = A_t * k_t^α * h_t^(1-α)
    #
    # where:
    # A_t = exp(a_t)
    # ---------------------------------------------------------
    y = A * k^p.α * h^(1 - p.α)

    # Eq. (6) in Dynare: law of motion for capital.
    #
    # In Dynare:
    # exp(k) = exp(i)+(1-delta)*exp(k(-1))
    #
    # In levels:
    # k_{t+1} = i_t + (1-δ)k_t
    #
    # Rearranged to recover investment:
    # i_t = k_{t+1} - (1-δ)k_t
    # ---------------------------------------------------------
    i = k_next - (1 - p.δ) * k

    # Capital adjustment costs appearing in:
    # - Eq. (4): debt accumulation
    # - Eq. (27): investment Euler equation
    # - trade balance definition
    #
    # Adjustment cost:
    # (ϕ/2)(k_{t+1} - k_t)^2
    # ---------------------------------------------------------
    capital_adjustment_cost = (p.ϕ / 2) * (k_next - k)^2

    # Eq. (25) in Dynare: marginal utility definition.
    #
    # Dynare:
    # (exp(c)-((exp(h)^omega)/omega))^(-gamma)   = exp(lambda)
    #
    # In levels:
    # λ_t = (c_t - h_t^ω / ω)^(-γ)
    # ---------------------------------------------------------
    λ = (c - h^p.ω / p.ω)^(-p.γ)

    # Eq. (23) in Dynare: exogenous constant world interest rate.
    #
    # Dynare:
    # exp(r) = r_bar
    #
    # In levels:
    # r_t = r_bar
    # ---------------------------------------------------------
    r = p.rbar

    # Definition of trade-balance-to-output ratio (p.169)
    #
    # Dynare:
    # tb_y = 1-((exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2)/exp(y))
    #
    # In levels:
    # ---------------------------------------------------------
    tb_y = 1 - ((c + i + capital_adjustment_cost) / y)

    # Current-account-to-output ratio.
    #
    # Dynare:
    # ca_y = (1/exp(y))*(d(-1)-d);
    #
    # In levels:
    # ---------------------------------------------------------
    ca_y = (d_prev - d) / y

    return (
        c = c,
        h = h,
        y = y,
        i = i,
        k = k,
        k_next = k_next,
        d = d,
        A = A,
        λ = λ,
        r = r,
        tb_y = tb_y,
        ca_y = ca_y,
        capital_adjustment_cost = capital_adjustment_cost
    )
end


function solve_model5_pf(;
    p::SGUParams = baseline_params(),
    horizon::Int = 40,
    shock_std::Float64 = 1.0,
    terminal_condition::Symbol = :zero_terminal_debt_drift
)

    ss = steady_state(p)
    T = horizon

    # Eq. (14) in Dynare: Law of motion for TFP (that is an AR(1))
    #
    # Dynare:
    # a = rho*a(-1)+sigma_tfp*e 
    #
    # then:
    # ---------------------------------------------------------
    a_path = [p.σ_tfp * shock_std * p.ρ^(t - 1) for t in 1:T]

    # Convert log-TFP into TFP levels:
    # A_t = exp(a_t)
    A_path = exp.(a_path)

    # Unknown vector:
    # x = [k_next_1,...,k_next_T, d_1,...,d_T, c_1,...,c_T]
    x0 = vcat(
        fill(ss.k, T),
        fill(ss.d, T),
        fill(ss.c, T)
    )

    function residuals!(F, x)

        # Unpackaging the unkown vector in 3 vectors, one for each variable
        k_next_path = x[1:T]
        d_path = x[T+1:2T]
        c_path = x[2T+1:3T]

        # Foreign debt accumulation equation
        # -------------------------------------------------
        for t in 1:T

            # Initial conditions: if we are at time 1 the level is the ss level
            k_t = t == 1 ? ss.k : k_next_path[t - 1]
            d_prev = t == 1 ? ss.d : d_path[t - 1]

            # Compute quantities using as input the dynamic variables and parameters
            q_t = model5_pf_quantities(
                c_path[t],
                k_t,
                k_next_path[t],
                d_path[t],
                d_prev,
                A_path[t],
                p
            )

            # Compute residuals, considering the Eq. (4) in Dynare:
            # d = (1+exp(r(-1)))*d(-1)- exp(y)+exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2
            # ---------------------------------------------------------
            F[t] =
                d_path[t] -
                (
                    (1 + p.rbar) * d_prev
                    - q_t.y
                    + q_t.c
                    + q_t.i
                    + q_t.capital_adjustment_cost
                )
        end

        # Euler equation for foreign debt
        # -------------------------------------------------
        # We have to fill the vector of residuals from T, the previous positions are occupied by residuals of debt
        offset_bond = T

        for t in 1:(T - 1)

            k_t = t == 1 ? ss.k : k_next_path[t - 1]
            d_prev = t == 1 ? ss.d : d_path[t - 1]

            q_t = model5_pf_quantities(
                c_path[t],
                k_t,
                k_next_path[t],
                d_path[t],
                d_prev,
                A_path[t],
                p
            )

            q_next = model5_pf_quantities(
                c_path[t + 1],
                k_next_path[t],
                k_next_path[t + 1],
                d_path[t + 1],
                d_path[t],
                A_path[t + 1],
                p
            )

            # Eq. (24) Euler equation in Dynare:
            # exp(lambda)= beta*(1+exp(r))*exp(lambda(+1)); 
            # Compute residuals
            F[offset_bond + t] =
                q_t.λ -
                ss.β * (1 + p.rbar) * q_next.λ
        end

        # Euler equation for capital
        # -------------------------------------------------
        offset_capital = T + (T - 1)

        for t in 1:(T - 1)

            k_t = t == 1 ? ss.k : k_next_path[t - 1]
            d_prev = t == 1 ? ss.d : d_path[t - 1]

            q_t = model5_pf_quantities(
                c_path[t],
                k_t,
                k_next_path[t],
                d_path[t],
                d_prev,
                A_path[t],
                p
            )

            q_next = model5_pf_quantities(
                c_path[t + 1],
                k_next_path[t],
                k_next_path[t + 1],
                d_path[t + 1],
                d_path[t],
                A_path[t + 1],
                p
            )

            mpk_next =
                A_path[t + 1] *
                p.α *
                k_next_path[t]^(p.α - 1) *
                q_next.h^(1 - p.α)

            # Residuals of Eq. (27) in Dynare:
            # exp(lambda)*(1+phi*(exp(k)-exp(k(-1)))) = beta*exp(lambda(+1))*(alpha*exp(y(+1))/exp(k)+1-delta+phi*(exp(k(+1))-exp(k)));
            F[offset_capital + t] =
                q_t.λ * (1 + p.ϕ * (k_next_path[t] - k_t)) -
                ss.β * q_next.λ *
                (
                    mpk_next
                    + 1
                    - p.δ
                    + p.ϕ * (k_next_path[t + 1] - k_next_path[t])
                )
        end


        # Terminal conditions
        # -------------------------------------------------
        terminal_1_index = 3T - 1
        terminal_2_index = 3T

        # Common terminal condition:
        # capital chosen in the final period returns to steady state
        F[terminal_1_index] = k_next_path[T] - ss.k

        # Model 5 is particular because we have to test some artificial terminal conditions for debt
        # 3 possible terminal conditions:
        if terminal_condition == :zero_terminal_debt_drift

            # Debt is free to end at a new level.
            # We only impose that it stops moving at the end.
            F[terminal_2_index] = d_path[T] - d_path[T - 1]

        elseif terminal_condition == :debt_to_dbar

            # Debt is forced back to its initial steady-state value.
            F[terminal_2_index] = d_path[T] - ss.d

        elseif terminal_condition == :k_and_lambda_to_ss

            # Marginal utility returns to steady state.
            k_T = T == 1 ? ss.k : k_next_path[T - 1]
            d_prev_T = T == 1 ? ss.d : d_path[T - 1]

            q_T = model5_pf_quantities(
                c_path[T],
                k_T,
                k_next_path[T],
                d_path[T],
                d_prev_T,
                A_path[T],
                p
            )
            
            F[terminal_2_index] = q_T.λ - ss.λ

        end
    end

    # Solve the nonlinear perfect-foresight system: find x such that all residuals F(x)=0.
    solution = nlsolve(
        residuals!,
        x0;
        method = :trust_region,
        xtol = 1e-10,
        ftol = 1e-10
    )

    if !converged(solution)
        @warn "Model 5 perfect-foresight solver did not fully converge."
    end

    # Extraction of the optimal vector that make zero the residuals
    x = solution.zero

    k_next_path = x[1:T]
    d_path = x[T+1:2T]
    c_path = x[2T+1:3T]

    periods = collect(0:T-1)

    output_irf = zeros(T)
    consumption_irf = zeros(T)
    investment_irf = zeros(T)
    hours_irf = zeros(T)
    tb_y_irf = zeros(T)
    ca_y_irf = zeros(T)
    debt_irf = zeros(T)
    lambda_irf = zeros(T)

    # Reconstruct period-t quantities from the solved paths.
    for t in 1:T

        k_t = t == 1 ? ss.k : k_next_path[t - 1]
        d_prev = t == 1 ? ss.d : d_path[t - 1]

        q_t = model5_pf_quantities(
            c_path[t],
            k_t,
            k_next_path[t],
            d_path[t],
            d_prev,
            A_path[t],
            p
        )

        # Store IRFs as percent deviations from steady state.
        output_irf[t] = 100 * (q_t.y / ss.y - 1)
        consumption_irf[t] = 100 * (q_t.c / ss.c - 1)
        investment_irf[t] = 100 * (q_t.i / ss.i - 1)
        hours_irf[t] = 100 * (q_t.h / ss.h - 1)

        tb_y_irf[t] = 100 * (q_t.tb_y - ss.tb_y)
        ca_y_irf[t] = 100 * q_t.ca_y

        debt_irf[t] = 100 * (q_t.d / ss.d - 1)
        lambda_irf[t] = 100 * (q_t.λ / ss.λ - 1)
    end

    return DataFrame(
        period = periods,
        output = output_irf,
        consumption = consumption_irf,
        investment = investment_irf,
        hours = hours_irf,
        trade_balance_to_gdp = tb_y_irf,
        current_account_to_gdp = ca_y_irf,
        debt = debt_irf,
        lambda = lambda_irf,
        terminal_condition = string(terminal_condition)
    )
end