function outer_middle_ear_filter(mapping::SignalPressureMapping, frequencies::Array{Float64})
    return 1 ./ threshold_in_quiet_signal_level(mapping, frequencies)
end

export outer_middle_ear_filter