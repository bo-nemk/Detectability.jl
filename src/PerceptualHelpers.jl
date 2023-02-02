function frequencies_to_erb(frequency::Float64)
    return 24.7 * (4.37 * (frequency / 1000.0) + 1.0)
end

function frequencies_to_erbs(frequency::Float64)
    return 21.4 * log10(1.0 + 0.00437 * frequency)
end

function erbs_to_frequencies(erbs::Float64)
    return (10.0 ^ (erbs / 21.4) - 1.0) / 0.00437
end

function erbspace(fmin::Float64, fmax::Float64, n_filters::Int64)
    return erbs_to_frequencies.(Array{Float64}(LinRange(frequencies_to_erbs(fmin), frequencies_to_erbs(fmax), n_filters)))
end

function audfiltbw(center_frequency::Float64)
    return 24.7 + center_frequency / 9.265
end

function frequencies_to_bark(frequency::Float64)
    return 13.0 * atan(0.00076 * frequency) + 3.5 * atan((frequency / 7500.0) ^ 2.0)
end

export audfiltbw
export erbspace
export erbs_to_frequencies
export frequencies_to_bark
export frequencies_to_erb
export frequencies_to_erbs