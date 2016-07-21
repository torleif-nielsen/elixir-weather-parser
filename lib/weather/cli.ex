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

  def process(:help) do
    IO.puts """
    usage: weather <4-digit location_code>
    """
    System.halt(0)
  end

  def process(loc_code) do
    Weather.ParseData.fetch(loc_code)
    |> decode_response
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
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
