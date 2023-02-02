function auditory_filter_bank(mapping::SignalPressureMapping, frequencies::Array{Float64}, sampling_rate::Int64, n_filters::Int64)
    gt_filter_bank = gammatone_filter_bank(frequencies, sampling_rate, n_filters)
    oe_filter = outer_middle_ear_filter.(Ref(mapping), frequencies)

    filter_bank = Array{Float64, 2}(undef, n_filters, length(frequencies))
    for n in 1 : n_filters
        filter_bank[n, :] = gt_filter_bank[n, :] .* oe_filter[:]
    end
    
    return filter_bank
end

export auditory_filter_bank