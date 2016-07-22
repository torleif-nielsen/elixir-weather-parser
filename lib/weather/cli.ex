defmodule Weather.CLI do
  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def parse(argv) do
    argv
    |> parse_args()
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                        aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, [loc_code], _} -> loc_code
      _ -> :help
    end
  end

  def process( :help ) do
    IO.puts """
    usage: weather <4-digit location_code>
    """
    System.halt(0)
  end

  def process( loc_code ) do
    Weather.ParseData.fetch(loc_code)
    |> decode_response
    |> scan_xml_text
    |> parse_weather_data
  end

  def parse_weather_data({ xml, _ }) do
    tag_names = [ 'station_id'         ,
                  'location'           ,
                  'observation_time'   ,
                  'weather'            ,
                  'temperature_string' ,
                  'relative_humidity'  ,
                  'wind_string'        ,
                  'pressure_string'    ]

    for tag <- tag_names do
      [ element ] = :xmerl_xpath.string('/current_observation/' ++ tag, xml)
      [ element_text ] = xmlElement(element, :content)
      # element_value = xmlText(element_text, :value)
    end
    # IO.inspect to_string(value)
  end

  def scan_xml_text( text ) do
    :xmerl_scan.string(String.to_char_list(text))
  end

  def decode_response({ :ok, body }), do: body

  def decode_response({ :error, error }) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from weather service: #{message}"
    System.halt(2)
  end

  # def scan_text(text) do
  #   :xmerl_scan.string(String.to_char_list(text))
  # end
  #
  # def parse_xml({ xml, _ }) do
  #   # single element
  #   [element]  = :xmerl_xpath.string('/breakfast_menu/food[1]/description', xml)
  #   [text]     = xmlElement(element, :content)
  #   value      = xmlText(text, :value)
  #   IO.inspect to_string(value)
  #   # => "Two of our famous Belgian Waffles with plenty of real maple syrup"
  #
  #   # multiple elements
  #   elements   = :xmerl_xpath.string('/breakfast_menu//food/name', xml)
  #   Enum.each(
  #     elements,
  #     fn(element) ->
  #       [text]     = xmlElement(element, :content)
  #       value      = xmlText(text, :value)
  #       IO.inspect to_string(value)
  #     end
  #   )
  #   # => "Belgian Waffles"
  #   # => "Strawberry Belgian Waffles"
  #   # => "Berry-Berry Belgian Waffles"
  #   # => "French Toast"
  #   # => "Homestyle Breakfast"
  # end
end

# """
# <?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> \r
# <?xml-stylesheet href=\"latest_ob.xsl\" type=\"text/xsl\"?>\r
# <current_observation version=\"1.0\"\r
# \t xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\r
# \t xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r
# \t xsi:noNamespaceSchemaLocation=\"http://www.weather.gov/view/current_observation.xsd\">\r
# \t<credit>NOAA's National Weather Service</credit>\r
# \t<credit_URL>http://weather.gov/</credit_URL>\r
# \t<image>\r
# \t\t<url>http://weather.gov/images/xml_logo.gif</url>\r
# \t\t<title>NOAA's National Weather Service</title>\r
# \t\t<link>http://weather.gov</link>\r
# \t</image>\r
# \t<suggested_pickup>15 minutes after the hour</suggested_pickup>\r
# \t<suggested_pickup_period>60</suggested_pickup_period>
# \t<location>Honolulu, Honolulu International Airport, HI</location>
# \t<station_id>PHNL</station_id>
# \t<latitude>21.3275</latitude>
# \t<longitude>-157.94306</longitude>
# \t<observation_time>Last Updated on Jul 21 2016, 10:53 am HST</observation_time>\r
#         <observation_time_rfc822>Thu, 21 Jul 2016 10:53:00 -1000</observation_time_rfc822>
#         \t<weather>Mostly Cloudy</weather>
#         \t<temperature_string>85.0 F (29.4 C)</temperature_string>\r
#         \t<temp_f>85.0</temp_f>\r
#         \t<temp_c>29.4</temp_c>
#         \t<relative_humidity>57</relative_humidity>
#         \t<wind_string>from the Northeast at 15.0 gusting to 25.3 MPH (13 gusting to 22 KT)</wind_string>
#         \t<wind_dir>Northeast</wind_dir>
#         \t<wind_degrees>60</wind_degrees>
#         \t<wind_mph>15.0</wind_mph>
#         \t<wind_gust_mph>25.3</wind_gust_mph>
#         \t<wind_kt>13</wind_kt>
#         \t<wind_gust_kt>22</wind_gust_kt>
#         \t<pressure_string>1017.4 mb</pressure_string>
#         \t<pressure_mb>1017.4</pressure_mb>
#         \t<pressure_in>30.05</pressure_in>
#         \t<dewpoint_string>68.0 F (20.0 C)</dewpoint_string>\r
#         \t<dewpoint_f>68.0</dewpoint_f>\r
#         \t<dewpoint_c>20.0</dewpoint_c>
#         \t<heat_index_string>88 F (31 C)</heat_index_string>\r
#               \t<heat_index_f>88</heat_index_f>\r
#                     \t<heat_index_c>31</heat_index_c>
#                     \t<visibility_mi>10.00</visibility_mi>
#                      \t<icon_url_base>http://forecast.weather.gov/images/wtf/small/</icon_url_base>
#                      \t<two_day_history_url>http://www.weather.gov/data/obhistory/PHNL.html</two_day_history_url>
#                      \t<icon_url_name>bkn.png</icon_url_name>
#                      \t<ob_url>http://www.weather.gov/data/METAR/PHNL.1.txt</ob_url>
#                      \t<disclaimer_url>http://weather.gov/disclaimer.html</disclaimer_url>\r
#                      \t<copyright_url>http://weather.gov/disclaimer.html</copyright_url>\r
#                      \t<privacy_policy_url>http://weather.gov/notice.html</privacy_policy_url>\r
#                      </current_observation>
#
# """
