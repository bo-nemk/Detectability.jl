using Roots
using DSP
using DSP.Util

function get_training_sine(amplitude::Float64, training_rate::Int64, sampling_rate::Int64, n_samples::Int64)
    return amplitude * cos.((2 * pi * Float64(training_rate) / Float64(sampling_rate)) .* LinRange(0, n_samples, n_samples))
end

struct ParModelCalibration
    Ca::Float64
    Cs::Float64

    function ParModelCalibration(mapping::SignalPressureMapping, sampling_rate::Int64, n_samples::Int64, n_filters::Int64 = 64, training_rate::Int64 = 1000)
        frequencies = DSP.Util.rfftfreq(n_samples, sampling_rate)
        filter_bank = auditory_filter_bank(mapping, frequencies, sampling_rate, n_filters)
        
        sine_zero = get_training_sine(0, training_rate, sampling_rate, n_samples)
        sine_threshold_in_quiet = get_training_sine(threshold_in_quiet_signal_level(mapping, training_rate), training_rate, sampling_rate, n_samples)
        sine_masker = get_training_sine(pressure_to_signal_level(mapping, 70), training_rate, sampling_rate, n_samples)
        sine_masked = get_training_sine(pressure_to_signal_level(mapping, 52), training_rate, sampling_rate, n_samples)
        
        function Calibration(Cs::Float64)  
        end
        
    end
end