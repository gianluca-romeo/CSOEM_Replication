using Plots
using AxisKeys

function get_model_dictionary()
    return Dict(
        "M1"  => SGU_M1,
        "M1a" => SGU_M1a,
        "M2"  => SGU_M2,
        "M3"  => SGU_M3,
        "M4"  => SGU_M4
    )
end

function get_style_dictionary()
    return Dict(
        "M1"  => (:solid, :circle),
        "M1a" => (:dash, :rect),
        "M2"  => (:dot, :diamond),
        "M3"  => (:dashdot, :utriangle),
        "M4"  => (:solid, :xcross)
    )
end

function run_sgu_irfs(active_models;
    output_dir,
    periods = 10,
    shock_size = 1 / 0.0129,
    save_name = "SGU_IRFs.png"
)

    mkpath(output_dir)

    all_models = get_model_dictionary()
    styles = get_style_dictionary()

    # Filter only selected models passed in input
    selected_models = Dict(
        name => all_models[name]
        for (name, active) in active_models
        if active == 1
    )

    vars = [:y, :c, :i, :h, :tb_y, :ca_y]

    titles = Dict(
        :y => "Output",
        :c => "Consumption",
        :i => "Investment",
        :h => "Hours",
        :tb_y => "Trade Balance / GDP",
        :ca_y => "Current Account / GDP"
    )

    # Figure: 3 rows and 2 columns
    p = plot(layout = (3, 2), size = (1000, 750), legend = :topright)

    # For each variable
    for (panel, v) in enumerate(vars)
        
        # For each active model
        for (name, model) in selected_models

            # M4 doesn't have ca_y
            if model == SGU_M4 && v == :ca_y
                continue
            end

            # Compute irfs
            irf = get_irf(
                model;
                periods = periods,
                variables = [v],
                shock_size = shock_size,
                levels = false
            )
            
            irf_mat = dropdims(irf, dims = 3)

            series = size(irf_mat, 1) == 1 ?
                vec(irf_mat[1, :]) :
                vec(irf_mat[:, 1])

            linestyle, marker = styles[name]

            plot!(
                p[panel],
                0:length(series)-1,
                series,
                label = name,
                linewidth = 2,
                linestyle = linestyle,
                marker = marker,
                markersize = 4,
                title = titles[v],
                xlabel = ""
            )
        end

        hline!(
            p[panel],
            [0],
            color = :black,
            linestyle = :dash,
            linewidth = 1,
            label = ""
        )
    end

    display(p)

    path = joinpath(output_dir, save_name)
    savefig(p, path)

    return p
end