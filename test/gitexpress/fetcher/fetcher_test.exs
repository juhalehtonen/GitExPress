defmodule GitExPress.FetcherTest do
  use ExUnit.Case
  alias GitExPress.Fetcher

  setup_all do
    {:ok, path} = File.cwd()
    [current_dir: path]
  end

  test "Affirms that we cannot git clone to current directory", state do
    assert Fetcher.can_git_clone?(state[:current_dir]) == false
  end

  test "Affirms that current directory is a git repository", state do
    assert Fetcher.is_git_repository?(state[:current_dir]) == true
  end

  test "Affirms current directory exists", state do
    assert Fetcher.directory_exists?(state[:current_dir]) == true
  end

  test "Affirms current directory is not empty", state do
    assert Fetcher.is_empty_directory?(state[:current_dir]) == false
  end
end
