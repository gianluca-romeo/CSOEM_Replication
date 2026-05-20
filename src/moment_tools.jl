# =========================================================
# Moment computation
# =========================================================

function run_moment_table(active_models; output_dir)

    table_dir = joinpath(output_dir, "tables")
    mkpath(table_dir)

    all_models = Dict(
        "M1"  => SGU_M1,
        "M1a" => SGU_M1a,
        "M2"  => SGU_M2,
        "M3"  => SGU_M3,
        "M4"  => SGU_M4
    )

    vars = [:y, :c, :i, :h, :tb_y, :ca_y]

    row_labels = [
        "std(y)",
        "std(c)",
        "std(i)",
        "std(h)",
        "std(tb/y)",
        "std(ca/y)",
        "corr(c,y)",
        "corr(i,y)",
        "corr(h,y)",
        "corr(tb/y,y)",
        "corr(ca/y,y)",
        "autocorr(y)",
        "autocorr(c)",
        "autocorr(i)",
        "autocorr(h)",
        "autocorr(tb/y)",
        "autocorr(ca/y)"
    ]

    table = [["Moment"]]

    for (name, active) in sort(collect(active_models))
        active == 1 || continue
        push!(table[1], name)
    end

    for label in row_labels
        push!(table, [label])
    end

    for (name, active) in sort(collect(active_models))

        active == 1 || continue

        model = all_models[name]

        model_vars = Symbol.(get_variables(model))
        
        function index(v)
            return findfirst(==(v), model_vars)
        end

        stds = get_standard_deviation(model)[:, 1]
        ss = get_non_stochastic_steady_state(model)

        cors = get_correlation(model)
        autos = get_autocorrelation(model)[:, 1]

        yidx = index(:y)

        values = Float64[]

        # Standard deviations
        for v in vars
            j = index(v)

            if isnothing(j)
                push!(values, NaN)

            elseif v in [:tb_y, :ca_y]
                # tb_y and ca_y are already ratios
                push!(values, 100 * stds[j])

            else
                # For y, c, i, and h compute percentage deviations
                # relative to their steady-state values
                push!(values, 100 * stds[j] / ss[j])
            end
        end

        # Correlations with output
        for v in vars[2:end]
            j = index(v)

            if isnothing(j) || isnothing(yidx)
                push!(values, NaN)
            else
                push!(values, cors[j, yidx])
            end
        end

        # First-order autocorrelations
        for v in vars
            j = index(v)

            if isnothing(j)
                push!(values, NaN)
            else
                push!(values, autos[j])
            end
        end

        for r in 2:length(table)
            x = values[r - 1]
            push!(table[r], isnan(x) ? "" : string(round(x; digits = 1)))
        end
    end

    csv_path = joinpath(table_dir, "selected_models_moments.csv")

    open(csv_path, "w") do io
        for row in table
            println(io, join(row, ","))
        end
    end

end