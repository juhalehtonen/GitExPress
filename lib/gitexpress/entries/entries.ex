defmodule GitExPress.Entries do
  @moduledoc """
  The Entries context. This module will be the public API for all entries
  functionality in our system.
  """
  alias GitExPress.Entries.Entry
  alias GitExPress.Entries.Parser
  alias GitExPress.Entries.Storage
  alias GitExPress.Fetcher

  @local_path Application.get_env(:gitexpress, :local_path)
  @remote_repository_url Application.get_env(:gitexpress, :remote_repository_url)

  @doc """
  Update all entries to their latest available batch. Called by the GenServer
  worker. This controls what kind of data we ultimately end up saving on our
  service.
  """
  @spec fetch_entries() :: {:ok, list()}
  def fetch_entries do
    Fetcher.get([@remote_repository_url, @local_path])
    entries = Parser.generate_entries()
    {:ok, entries}
  end

  @doc """
  Returns all entries stored in the storage for the given source.
  """
  @spec list_entries() :: list()
  def list_entries do
    {:ok, entries} = Storage.get_entries()

    entries
    |> Enum.map(fn {_table, title, date, slug, content_raw, content_html, content_type} ->
      %Entry{
        title: title,
        date: date,
        slug: slug,
        content_raw: content_raw,
        content_html: content_html,
        content_type: content_type
      }
    end)
    |> Enum.sort_by(fn entry -> entry.date end)
  end

  @doc """
  Creates an entry and saves it to the database.
  """
  @spec create_entry(%Entry{}) :: {:ok, String.t()} | {:error, String.t()}
  def create_entry(entry) do
    entry
    |> Storage.insert_entry()
  end
end
