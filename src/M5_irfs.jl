# =========================================================
# IRF generation and plotting for SGU Model 5
# =========================================================

function M5_plot_irfs(;
    p::SGUParams = baseline_params(),
    horizon::Int = 40,
    shock_std::Float64 = 1.0,
    output_dir::String = "output"
)

    println("Running Model 5 perfect-foresight experiment")
    println("Terminal conditions: free_debt, debt_to_dbar, lambda_k_to_ss")

    # tables_dir = joinpath(output_dir, "tables")
    figures_dir = joinpath(output_dir, "figures")

    # mkpath(tables_dir)
    mkpath(figures_dir)

    # Solve Model 5 under the three terminal conditions
    df_free = solve_model5_pf(
        p = p,
        horizon = horizon,
        shock_std = shock_std,
        terminal_condition = :zero_terminal_debt_drift
    )

    df_dbar = solve_model5_pf(
        p = p,
        horizon = horizon,
        shock_std = shock_std,
        terminal_condition = :debt_to_dbar
    )

    df_lambda = solve_model5_pf(
        p = p,
        horizon = horizon,
        shock_std = shock_std,
        terminal_condition = :k_and_lambda_to_ss
    )

    # Save CSV files
    # free_path = joinpath(tables_dir, "model5_pf_free_debt.csv")
    # dbar_path = joinpath(tables_dir, "model5_pf_debt_to_dbar.csv")
    # lambda_path = joinpath(tables_dir, "model5_pf_lambda_k_to_ss.csv")

    # CSV.write(free_path, df_free)
    # CSV.write(dbar_path, df_dbar)
    # CSV.write(lambda_path, df_lambda)

    # Plot comparison figure
    p1 = plot(
        df_free.period,
        df_free.output,
        label = "free debt",
        title = "Output",
        xlabel = "Period"
    )
    plot!(p1, df_dbar.period, df_dbar.output, label = "d_T = dbar")
    plot!(p1, df_lambda.period, df_lambda.output, label = "lambda_T = lambda_ss")

    p2 = plot(
        df_free.period,
        df_free.consumption,
        label = "free debt",
        title = "Consumption",
        xlabel = "Period"
    )
    plot!(p2, df_dbar.period, df_dbar.consumption, label = "d_T = dbar")
    plot!(p2, df_lambda.period, df_lambda.consumption, label = "lambda_T = lambda_ss")

    p3 = plot(
        df_free.period,
        df_free.investment,
        label = "free debt",
        title = "Investment",
        xlabel = "Period"
    )
    plot!(p3, df_dbar.period, df_dbar.investment, label = "d_T = dbar")
    plot!(p3, df_lambda.period, df_lambda.investment, label = "lambda_T = lambda_ss")

    p4 = plot(
        df_free.period,
        df_free.hours,
        label = "free debt",
        title = "Hours",
        xlabel = "Period"
    )
    plot!(p4, df_dbar.period, df_dbar.hours, label = "d_T = dbar")
    plot!(p4, df_lambda.period, df_lambda.hours, label = "lambda_T = lambda_ss")

    p5 = plot(
        df_free.period,
        df_free.trade_balance_to_gdp,
        label = "free debt",
        title = "Trade Balance / GDP",
        xlabel = "Period"
    )
    plot!(p5, df_dbar.period, df_dbar.trade_balance_to_gdp, label = "d_T = dbar")
    plot!(p5, df_lambda.period, df_lambda.trade_balance_to_gdp, label = "lambda_T = lambda_ss")

    p6 = plot(
        df_free.period,
        df_free.current_account_to_gdp,
        label = "free debt",
        title = "Current Account / GDP",
        xlabel = "Period"
    )
    plot!(p6, df_dbar.period, df_dbar.current_account_to_gdp, label = "d_T = dbar")
    plot!(p6, df_lambda.period, df_lambda.current_account_to_gdp, label = "lambda_T = lambda_ss")

    fig = plot(
        p1, p2, p3, p4, p5, p6,
        layout = (3, 2),
        size = (1000, 800)
    )

    display(fig)

    fig_path = joinpath(figures_dir, "model5_pf_irfs.png")
    savefig(fig, fig_path)

    println("M5 IRFs in:")
    println("  ", fig_path)

end