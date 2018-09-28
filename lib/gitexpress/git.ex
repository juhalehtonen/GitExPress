defmodule GitExPress.Remote do
  # TODO: Webhook config that allows us to expose an endpoint that can be plugged
  # into by web apps, allowing us to get updates whenever updates are pushed to git.

  def clone([url, path]) do
    with {:ok, _stats} <- File.stat(path),
         {:ok, []} <- File.ls(path) do
      Git.clone([url, path])
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Could not clone"}
    end
  end

  # Where to store repository information after initial run?
  def pull(path) do
    repo = %Git.Repository{path: path}
    Git.pull(repo, ~w(origin master))
  end
end
