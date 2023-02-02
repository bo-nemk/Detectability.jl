include("SignalPressureMapping.jl")

function threshold_in_quiet_pressure_level(frequencies::Float64)::Float64
    return 3.64 * ((frequencies / 1000) ^ -0.8) - 6.5 * exp.(-0.6 * ((frequencies / 1000 - 3.3) ^ 2.0)) + 10e-4 * ((frequencies / 1000) ^ 4.0)
end

# function threshold_in_quiet_signal_level(mapping::SignalPressureMapping, frequencies::Array{Float64})::Array{Float64}
function threshold_in_quiet_signal_level(mapping::SignalPressureMapping, frequencies::Float64)::Float64
    return pressure_to_signal_level(mapping, threshold_in_quiet_pressure_level(frequencies))
end