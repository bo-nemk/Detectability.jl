using Roots
using FFTW

function get_training_sine(amplitude::Float64, training_rate::Int64, sampling_rate::Int64, n_samples::Int64)::Array{Float64}
    return amplitude .* cos.((2 * pi * Float64(training_rate) / Float64(sampling_rate)) .* (0:(n_samples - 1)))
end


struct ParModelCalibration
    Ca::Float64
    Cs::Float64

    function ParModelCalibration(mapping::SignalPressureMapping, sampling_rate::Int64, n_samples::Int64, n_filters::Int64 = 64, training_rate::Int64 = 1000)
        frequencies::Array{Float64} = FFTW.rfftfreq(n_samples, sampling_rate)
        filter_bank = auditory_filter_bank(mapping, frequencies, sampling_rate, n_filters)
        
        sine_zero = abs.(FFTW.rfft(get_training_sine(0.0, training_rate, sampling_rate, n_samples)))
        sine_threshold_in_quiet = abs.(FFTW.rfft(get_training_sine(threshold_in_quiet_signal_level(mapping, Float64(training_rate)), training_rate, sampling_rate, n_samples)))
        sine_masker = abs.(FFTW.rfft(get_training_sine(pressure_to_signal_level(mapping, 70.0), training_rate, sampling_rate, n_samples)))
        sine_masked = abs.(FFTW.rfft(get_training_sine(pressure_to_signal_level(mapping, 52.0), training_rate, sampling_rate, n_samples)))

        function ComputeDetectability(masker::Array{Float64}, masked::Array{Float64}, Ca::Float64, Cs::Float64)
            internal_masker::Array{Float64} = zeros(Float64, length(masker))
            internal_masked::Array{Float64} = zeros(Float64, length(masked))

            for i in 1:n_filters
                internal_masker .+= abs.(masker .* filter_bank[i,:]) .^ 2.0
                internal_masked .+= abs.(masked .* filter_bank[i,:]) .^ 2.0
            end
            
            return Cs .* sum((internal_masked ./ (internal_masker .+ Ca)))
        end
        
        function CalibrationFunction(Cs::Float64)::Float64
            return ComputeDetectability(sine_masker, sine_masked, ComputeDetectability(sine_zero, sine_threshold_in_quiet, 1.0, Cs), Cs) - 1.0
        end
        
        Cs::Float64 = Roots.find_zero(CalibrationFunction, (0.001, 1000.0), Roots.Bisection())
        Ca::Float64 = ComputeDetectability(sine_zero, sine_threshold_in_quiet, 1.0, Cs)
        
        new(Ca, Cs)
    end
end

function ParModelGain(calibration::ParModelCalibration, masker::Array{Float64})
end

export ParModelCalibration