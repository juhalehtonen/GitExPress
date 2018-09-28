defmodule GitExPress.Fetcher do
  @moduledoc """
  Contains functions responsible for fetching external data. This essentially
  means Git repositories.
  """

  @local_path Application.get_env(:gitexpress, :local_path)

  # TODO: Webhook config that allows us to expose an endpoint that can be plugged
  # into by web apps, allowing us to get updates whenever updates are pushed to git.

  @doc """
  The main public-facing function that is used to facilitate the cloning and all
  necessary file system checks to see if we can clone the repo or not. Will also
  attempt to create the configured directory if it does not exist.
  """
  def fetch([repo_url, to_path]) do
    # If the path does not exist, attempt to create it
    if not File.exists?(to_path) do
      File.mkdir(to_path)
    end
    # Attempt to clone repository after creation
    clone([repo_url, to_path])
  end

  @doc """
  Clone a repository in `repo_url` to given local `to_path`.
  """
  def clone([repo_url, to_path]) do
    with {:ok, _stats} <- File.stat(to_path),
         {:ok, []} <- File.ls(to_path) do
      Git.clone([repo_url, to_path])
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Could not clone"}
    end
  end

  def pull(path \\ @local_path) do
    repo = %Git.Repository{path: path}
    Git.pull(repo, ~w(origin master))
  end
end
