defmodule GitExPress.ParserTest do
  use ExUnit.Case
  alias GitExPress.Entries.Parser

  # setup_all do
  #   [state: "whatever state we can refer to later on"]
  # end

  # Files

  test "Can read an entry in a valid format" do
    file = "sample_entry.md"
    assert {:ok, meta, content} = Parser.read(file)
  end

  test "Can locate .md files in a directory" do
    {:ok, path} = File.cwd()
    assert Parser.get_files(path) != []
  end

  # Dates

  test "Can extract a valid date from a valid string" do
    date = Parser.extract_date("2017-01-01")
    assert date == ~D[2017-01-01]
  end

  test "Extracting a date from an invalid string returns an empty string" do
    date = Parser.extract_date("Whoops")
    assert date == ""
  end
end
