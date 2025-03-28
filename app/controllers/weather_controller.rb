class WeatherController < ApplicationController
  before_action :validate_address, only: [:fetch_weather]


  def fetch_weather
    zip_code = Geocoder.search(params[:address])&.first&.postal_code
    return handle_invalid_address if zip_code.nil?

    weather, cached = fetch_weather_data(zip_code)

    if weather.nil? || weather[:error]   #weather_data.is_a?(Hash) && weather_data[:error]
      # @weather = weather_data # Keep as hash if there's an error
      @weather = { error: "Failed to fetch weather data"}
    else
      @weather = WeatherDecorator.new(weather) # Decorate only if valid
    end

    @cached = cached
    render :fetch_weather
  end

  private

  def validate_address
    if params[:address].blank?
      flash[:alert] = "Address cannot be blank."
      redirect_to root_path
    end
  end

  def handle_invalid_address
    flash[:alert] = "Invalid address. Please try again."
    redirect_to root_path
  end

  def fetch_weather_data(zip_code)
    api_key = Rails.application.credentials.dig(:openweather_api_key)
    return { error: "Missing API key" } if api_key.blank?

    url = "https://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},us&units=metric&appid=#{api_key}"
    
    begin
      response = HTTParty.get(url)
      json_data = JSON.parse(response.body)

      if response.code == 200
        {
          name: json_data["name"],
          temperature: json_data.dig("main", "temp"),
          max_temp: json_data.dig("main", "temp_max"),
          min_temp: json_data.dig("main", "temp_min"),
          condition: json_data.dig("weather", 0, "description")
        }
      else
        { error: json_data["message"] || "Failed to fetch weather data" }
      end
    rescue StandardError => e
      { error: "Error fetching weather data: #{e.message}" }
    end
  end
end

