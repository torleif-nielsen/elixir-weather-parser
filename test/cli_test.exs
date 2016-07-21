defmodule CliTest do
  use ExUnit.Case
  doctest Weather

  import Weather.CLI, only: [parse_args: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "one value given if one given" do
    assert parse_args(["location_code"]) == "location_code"
  end
end
