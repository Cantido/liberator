defmodule Liberator.HTTPDateTimeTest do
  use ExUnit.Case
  doctest Liberator.HTTPDateTime

  describe "parse!/1" do
    test "raises on error" do
      assert_raise Timex.Parse.ParseError, "Expected `weekday abbreviation` at line 1, column 1.", fn ->
        Liberator.HTTPDateTime.parse!("asdf")
      end
    end
  end
end
