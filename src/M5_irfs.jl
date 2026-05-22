# =========================================================
# IRF generation and plotting for SGU Model 5
# =========================================================

function M5_plot_irfs(;
    p::SGUParams = baseline_params(),
    horizon::Int = 40,
    shock_std::Float64 = 1.0,
    output_dir::String = "output"
)

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
        linewidth = 2,
        title = "Output",
        xlabel = "Period",
        linestyle = :solid,
        marker = :circle,
        markersize = 4
    )
    plot!(p1, df_dbar.period, df_dbar.output, label = "d_T = dbar", linewidth = 2, linestyle = :dash, marker = :diamond, markersize = 4)
    plot!(p1, df_lambda.period, df_lambda.output, label = "lambda_T = lambda_ss", linewidth = 2, linestyle = :dot, marker = :square, markersize = 4)

    hline!(
    p1,
    [0],
    color = :black,
    linestyle = :dash,
    linewidth = 1,
    label = ""
    )

    p2 = plot(
        df_free.period,
        df_free.consumption,
        label = "free debt",
        linewidth = 2,
        title = "Consumption",
        xlabel = "Period",
        linestyle = :solid,
        marker = :circle,
        markersize = 4
    )
    plot!(p2, df_dbar.period, df_dbar.consumption, label = "d_T = dbar", linewidth = 2, linestyle = :dash, marker = :diamond, markersize = 4)
    plot!(p2, df_lambda.period, df_lambda.consumption, label = "lambda_T = lambda_ss", linewidth = 2, linestyle = :dot, marker = :square, markersize = 4)

    hline!(
    p2,
    [0],
    color = :black,
    linestyle = :dash,
    linewidth = 1,
    label = ""
    )

    p3 = plot(
        df_free.period,
        df_free.investment,
        label = "free debt",
        linewidth = 2,
        title = "Investment",
        xlabel = "Period",
        linestyle = :solid,
        marker = :circle,
        markersize = 4
    )
    plot!(p3, df_dbar.period, df_dbar.investment, label = "d_T = dbar", linewidth = 2, linestyle = :dash, marker = :diamond, markersize = 4)
    plot!(p3, df_lambda.period, df_lambda.investment, label = "lambda_T = lambda_ss", linewidth = 2, linestyle = :dot, marker = :square, markersize = 4)

    hline!(
    p3,
    [0],
    color = :black,
    linestyle = :dash,
    linewidth = 1,
    label = ""
    )

    p4 = plot(
        df_free.period,
        df_free.hours,
        label = "free debt",
        linewidth = 2,
        title = "Hours",
        xlabel = "Period",
        linestyle = :solid,
        marker = :circle,
        markersize = 4
    )
    plot!(p4, df_dbar.period, df_dbar.hours, label = "d_T = dbar", linewidth = 2, linestyle = :dash, marker = :diamond, markersize = 4)
    plot!(p4, df_lambda.period, df_lambda.hours, label = "lambda_T = lambda_ss", linewidth = 2, linestyle = :dot, marker = :square, markersize = 4)

    hline!(
    p4,
    [0],
    color = :black,
    linestyle = :dash,
    linewidth = 1,
    label = ""
    )

    p5 = plot(
        df_free.period,
        df_free.trade_balance_to_gdp,
        label = "free debt",
        linewidth = 2,
        title = "Trade Balance / GDP",
        xlabel = "Period",
        linestyle = :solid,
        marker = :circle,
        markersize = 4
    )
    plot!(p5, df_dbar.period, df_dbar.trade_balance_to_gdp, label = "d_T = dbar", linewidth = 2, linestyle = :dash, marker = :diamond, markersize = 4)
    plot!(p5, df_lambda.period, df_lambda.trade_balance_to_gdp, label = "lambda_T = lambda_ss", linewidth = 2, linestyle = :dot, marker = :square, markersize = 4)

    hline!(
    p5,
    [0],
    color = :black,
    linestyle = :dash,
    linewidth = 1,
    label = ""
    )

    p6 = plot(
        df_free.period,
        df_free.current_account_to_gdp,
        label = "free debt",
        linewidth = 2,
        title = "Current Account / GDP",
        xlabel = "Period",
        linestyle = :solid,
        marker = :circle,
        markersize = 4
    )
    plot!(p6, df_dbar.period, df_dbar.current_account_to_gdp, label = "d_T = dbar", linewidth = 2, linestyle = :dash, marker = :diamond, markersize = 4)
    plot!(p6, df_lambda.period, df_lambda.current_account_to_gdp, label = "lambda_T = lambda_ss", linewidth = 2, linestyle = :dot, marker = :square, markersize = 4)

    hline!(
    p6,
    [0],
    color = :black,
    linestyle = :dash,
    linewidth = 1,
    label = ""
    )

    fig = plot(
        p1, p2, p3, p4, p5, p6,
        layout = (3, 2),
        size = (1000, 800)
    )

    fig_path = joinpath(figures_dir, "model5_pf_irfs.png")
    savefig(fig, fig_path)

    println("M5 IRFs in:")
    println("  ", fig_path)

end