class WeatherDecorator
  def initialize(weather)
    @weather = weather || {}
  end

  def name
    @weather[:name].to_s || "Unknown Location"
  end

   def temperature
    @weather[:temperature].to_s || "N/A"
  end

  def max_temp
    @weather[:max_temp].to_s || "N/A"
  end

  def min_temp
    @weather[:min_temp].to_s || "N/A"
  end

  def condition
    @weather[:condition].to_s || "N/A"
  end

  def error
    @weather[:error].to_s
  end

  def error?
    @weather[:error].to_s.present?
  end
end