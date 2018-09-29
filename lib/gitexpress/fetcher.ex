defmodule GitExPress.Fetcher do
  @moduledoc """
  Contains functions responsible for fetching external data. This essentially
  means Git repositories.
  """
  require Logger
  @local_path Application.get_env(:gitexpress, :local_path)

  @doc """
  The main public-facing function that is used to facilitate the cloning and all
  necessary file system checks to see if we can clone the repo or not.

  Check if we can clone to the git repository. If we can, it means that the
  directory is empty and thus that's exactly what we need to do here.

  If we cannot clone to git repository, check if it is still a git repository.
  If it is a git repo, we can do git pull. If it is not a git repo, error out.
  """
  def get([repo_url, to_path]) do
    cond do
      can_git_clone?(to_path) -> clone([repo_url, to_path])
      is_git_repository?(to_path) -> pull(to_path)
      true -> {:error, "Cannot fetch #{repo_url} to #{to_path}."}
    end
  end

  @doc """
  Clone a repository in `repo_url` to given local `to_path`.
  """
  def clone([repo_url, to_path]) do
    Logger.info "Cloning #{repo_url} to #{to_path}"
    Git.clone([repo_url, to_path])
  end

  @doc """
  Run git pull in given `path`.
  """
  def pull(to_path \\ @local_path) do
    repo = %Git.Repository{path: to_path}
    Logger.info "Pulling at #{to_path}"

    case Git.pull(repo, ~w(origin master)) do
      {:ok, _} -> {:ok, "Pulled to #{to_path}"}
      _ -> {:error, "Failed to pull to #{to_path}"}
    end
  end

  @doc """
  To be able to git clone to a given path, the path must satisfy some requirements:
  1) If the directory exists, it must be empty
  2) If the directory does not exist, all is good (assuming permissions..)
  """
  def can_git_clone?(path) do
    if directory_exists?(path) do
      is_empty_directory?(path)
    else
      true
    end
  end

  @doc """
  Checks if a given directory at `path` exists.
  """
  def directory_exists?(path) do
    File.exists?(path)
  end

  @doc """
  Scans a given `path` for a `.git` directory.
  """
  def is_git_repository?(path) do
    path = path <> "/.git"

    case Path.wildcard(path) do
      [] -> false
      _ -> true
    end
  end

  @doc """
  Scans a given `path` and checks whether it is empty.
  """
  def is_empty_directory?(path) do
    case File.ls(path) do
      {:ok, []} -> true
      _ -> false
    end
  end
end
