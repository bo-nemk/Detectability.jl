using Detectability
using FFTW
using Test

@testset "SignalPressureMapping.jl" begin
    @test Detectability.SignalPressureMapping(1.0, 100.0).offset_db == 100.0
    @test Detectability.SignalPressureMapping(10.0, 100.0).offset_db == 80.0
    mapping::Detectability.SignalPressureMapping = Detectability.SignalPressureMapping(1.0, 100.0) 
    @test Detectability.signal_to_pressure_level.(Ref(mapping), Array{Float64}([1.0, 10.0])) == Array{Float64}([100.0, 120.0])
    @test Detectability.pressure_to_signal_level.(Ref(mapping), Array{Float64}([100.0, 120.0])) == Array{Float64}([1.0, 10.0])
end

@testset "ThresholdInQuiet.jl" begin
    sampling_rate::Float64 = 48000
    n_samples::Int64 = 10
    frequencies::Array{Float64} = FFTW.rfftfreq(n_samples, sampling_rate)
    mapping::Detectability.SignalPressureMapping = Detectability.SignalPressureMapping(1.0, 100.0) 
    @test Detectability.threshold_in_quiet_signal_level.(Ref(mapping), frequencies)[2:end-1] ≈ Array{Float64}([9.86684635e-06, 2.84757976e-05, 1.48407282e-03,6.48469551e+01])
end

@testset "PerceptualHelpers.jl" begin
    sampling_rate::Float64 = 48000
    n_samples::Int64 = 10
    frequencies::Array{Float64} = FFTW.rfftfreq(n_samples, sampling_rate)
    @test Detectability.frequencies_to_erb.(frequencies) ≈ Array{Float64}([24.7, 542.8072, 1060.9144, 1579.0216, 2097.1288, 2615.236])
    @test Detectability.frequencies_to_erbs.(frequencies) ≈ Array{Float64}([0., 28.71770103, 34.94584457, 38.64178992, 41.27906244, 43.33101816])
    @test Detectability.erbs_to_frequencies.(Array{Float64}([0., 28.71770103, 34.94584457, 38.64178992, 41.27906244, 43.33101816])) ≈ frequencies
    @test Detectability.erbspace(10.0, 48000.0, 6) ≈ Array{Float64}([1.00000000e+01, 4.61624224e+02, 1.76725305e+03, 5.54177740e+03, 1.64537868e+04, 4.80000000e+04])
    @test Detectability.audfiltbw(200.0) ≈ 46.28661629789531
    @test Detectability.frequencies_to_bark.(frequencies) ≈ Array{Float64}([0., 18.30283725, 22.22938788, 23.80643889, 24.4986613, 24.86541638])
end

@testset "OuterMiddleEarFilter.jl" begin
    sampling_rate::Float64 = 48000
    n_samples::Int64 = 10
    frequencies::Array{Float64} = FFTW.rfftfreq(n_samples, sampling_rate)
    mapping::Detectability.SignalPressureMapping = Detectability.SignalPressureMapping(1.0, 100.0) 
    @test Detectability.outer_middle_ear_filter.(Ref(mapping), frequencies) ≈ Array{Float64}([0.00000000e+00, 1.01349506e+05, 3.51175414e+04, 6.73821383e+02, 1.54209245e-02, 2.49391323e-12])
end

@testset "LowpassFilter.jl" begin
    sampling_rate::Int64 = 48000
    n_samples::Int64 = 10
    frequencies::Array{Float64} = FFTW.rfftfreq(n_samples, sampling_rate)
    cutoff_frequency::Float64 = 10000
    @test Detectability.lowpass_filter(frequencies, cutoff_frequency, sampling_rate) ≈ Array{Float64}([1., 0.91529938, 0.76682988, 0.65551098, 0.59399849, 0.57469052])
end

@testset "GammatoneFilter.jl" begin
    sampling_rate::Int64 = 48000
    n_samples::Int64 = 10
    frequencies::Array{Float64} = FFTW.rfftfreq(n_samples, sampling_rate)
    center_frequency::Float64 = 10000
    gammatone = Detectability.gammatone_filter(frequencies, center_frequency) 
    @test gammatone ≈ Array{Float64}([1.55991749e-04, 1.99663777e-03, 7.88012398e-01, 3.76045497e-03, 2.16762345e-04, 4.11073327e-05])
    n_filters::Int64 = 3
    filterbank = Detectability.gammatone_filter_bank(frequencies, sampling_rate, n_filters)
    @test filterbank[1,:] ≈ Array{Float64}([7.46480833e-02, 1.73492119e-09, 1.06186164e-10, 2.08294979e-11, 6.56769582e-12, 2.68452143e-12])
    @test filterbank[2,:] ≈ Array{Float64}([2.09483461e-04, 1.22926608e-04, 1.83808385e-06, 2.47200785e-07, 6.53673001e-08, 2.41298499e-08])
    @test filterbank[3,:] ≈ Array{Float64}([1.48717984e-04, 3.99991954e-04, 1.47926075e-03, 9.99981528e-03, 2.49997434e-01, 2.49997434e-01])
end

@testset "AuditoryFilterBank.jl" begin
    sampling_rate::Int64 = 48000
    n_samples::Int64 = 10
    frequencies::Array{Float64} = FFTW.rfftfreq(n_samples, sampling_rate)
    center_frequency::Float64 = 10000
    n_filters::Int64 = 3
    mapping::Detectability.SignalPressureMapping = Detectability.SignalPressureMapping(1.0, 100.0) 
    filterbank = Detectability.auditory_filter_bank(mapping, frequencies, sampling_rate, n_filters)
    @test filterbank[1, 2:end-1] ≈ Array{Float64}([1.75833405e-04, 3.72899702e-06, 1.40353611e-08, 1.01279942e-13])
    @test filterbank[2, 2:end-1] ≈ Array{Float64}([1.24585509e+01, 6.45489857e-02, 1.66569175e-04, 1.00802420e-09])
    @test filterbank[3, 2:end-1] ≈ Array{Float64}([4.05389868e+01, 5.19480005e+01, 6.73808936e+00, 3.85519157e-03])
end

@testset "Detectability.jl" begin
    sampling_rate::Int64 = 48000
    n_samples::Int64 = 10
    mapping::Detectability.SignalPressureMapping = Detectability.SignalPressureMapping(1.0, 100.0) 
    calibration::ParModelCalibration = ParModelCalibration(mapping, sampling_rate, n_samples)
    # @test calibration.Ca ≈ 12.832880801010313 
    # @test calibration.Cs ≈ 2.5064636877711877
end