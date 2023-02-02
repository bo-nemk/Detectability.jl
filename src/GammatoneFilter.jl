using Combinatorics

function gammatone_filter(frequencies::Array{Float64}, center_frequency::Float64)::Array{Float64}
    filter_order::Int64 = 4
    sq::Float64 = 2 ^ (filter_order - 1)
    f1::Float64 = factorial(filter_order - 1)
    f2::Float64 = Combinatorics.doublefactorial(2 * filter_order - 3)
    factor::Float64 = (sq * f1) / (pi * f2)
    
    fd = frequencies .- center_frequency
    fc = (fd / (factor * frequencies_to_erb(center_frequency))) .^ 2.0
    return (1.0 .+ fc) .^ (-filter_order / 2.0)
end

function gammatone_filter_bank(frequencies::Array{Float64}, sampling_rate::Int64, n_filters::Int64)
    center_frequencies = erbspace(50.0, 0.9 * Float64(sampling_rate / 2.0), n_filters)
    filter_bank = Array{Float64, 2}(undef, n_filters, length(frequencies))
    for n in 1 : n_filters
        gammatone = gammatone_filter(frequencies, center_frequencies[n])
        filter_bank[n, :] = gammatone
    end
    
    return filter_bank
end