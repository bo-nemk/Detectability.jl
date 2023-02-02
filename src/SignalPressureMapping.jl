

struct SignalPressureMapping
	signal_level::Float64
	pressure_level::Float64
	offset_db::Float64

	function SignalPressureMapping(signal_level::Float64, pressure_level::Float64)
		new(signal_level, pressure_level, pressure_level - 20 * log10(signal_level))
	end
end

function signal_to_pressure_level(mapping::SignalPressureMapping, X::Float64)::Float64
	return 20 * log10(abs(X)) + mapping.offset_db
end

function pressure_to_signal_level(mapping::SignalPressureMapping, X::Float64)::Float64
	return 10 ^ ((X - mapping.offset_db) / 20)
end

export SignalPressureMapping
export signal_to_pressure_level
export pressure_to_signal_level 