function a_factor(cutoff_frequency::Float64, sampling_rate::Int64)
    return -1 * exp(-2 * pi * cutoff_frequency / Float64(sampling_rate))
end

function lowpass_filter(frequencies::Array{Float64}, cutoff_frequency::Float64, sampling_rate::Int64)
    a = a_factor(cutoff_frequency, sampling_rate)
    return (1 + a) ./ sqrt.(1 .+ a ^ 2 .+ 2 .* a .* cos.(2 .* pi .* frequencies ./ Float64(sampling_rate)))
end

export lowpass_filter