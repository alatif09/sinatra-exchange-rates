require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

get("/") do
  api_url = "https://api.exchangerate.host/list?access_key=#{ENV["EXCHANGE_RATE_KEY"]}"
  raw_data = HTTP.get(api_url)
  parsed_data = JSON.parse(raw_data.to_s)

  # Check if the API call was successful and if the 'currencies' key exists
  if parsed_data && parsed_data['currencies']
    @symbols = parsed_data['currencies'].keys
    @currency_descriptions = parsed_data['currencies']
  else
    @error_message = "Failed to fetch currency data."
    return erb :error
  end

  erb :homepage
end

get("/:from_currency") do
  @original_currency = params.fetch("from_currency")

  api_url = "https://api.exchangerate.host/list?access_key=#{ENV["EXCHANGE_RATE_KEY"]}"
  
  # Make the API request using the HTTP gem
  response = HTTP.get(api_url)
  data = JSON.parse(response.to_s)

  # Extract the full list of currency codes
  @currency_codes = data["currencies"].keys

  erb :convert # Assuming you have a view template named 'currency_template.erb'
end

get("/:from_currency/:to_currency") do
  @original_currency = params.fetch("from_currency")
  @destination_currency = params.fetch("to_currency")
  api_url = "https://api.exchangerate.host/convert?access_key=#{ENV["EXCHANGE_RATE_KEY"]}&from=#{@original_currency}&to=#{@destination_currency}&amount=1"
  raw_data = HTTP.get(api_url)
  parsed_data = JSON.parse(raw_data.to_s)
  @converted_value = parsed_data['result']
  erb :conversion_result
end
