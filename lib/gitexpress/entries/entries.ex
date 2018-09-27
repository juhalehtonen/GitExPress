defmodule GitExPress.Entries do
  @moduledoc """
  The Entries context. This module will be the public API for all entries
  functionality in our system.
  """
  alias GitExPress.Entries.Entry
  alias GitExPress.Entries.Storage

  @doc """
  Update all entries to their latest available batch. Called by the GenServer
  worker. This controls what kind of data we ultimately end up saving on our
  service.

  TODO: Make async. Use `with` and check that all fetches succeed, and if not,
  retry.
  """
  @spec fetch_entries(atom()) :: no_return()
  def fetch_entries(location) when is_atom(location) do
    case location do
      :local ->
        entries = GitExPress.Entries.Parser.generate_entries()
        {:ok, entries}
      :remote -> {:error, "Not implemented yet"}
    end
  end

  @doc """
  Returns all entries stored in the storage for the given source.
  """
  def list_entries do
    {:ok, entries} = Storage.get_entries()

    Enum.map(entries, fn {_table, title, date, slug, content_raw, content_html, content_type} ->
      %Entry{title: title, date: date, slug: slug, content_raw: content_raw, content_html: content_html, content_type: content_type}
    end)
    |> Enum.sort_by(fn entry -> entry.date end)
  end

  @doc """
  Creates an entry and saves it to the database.
  """
  def create_entry(entry) do
    %Entry{title: entry.title, date: entry.date, slug: entry.slug, content_raw: entry.content_raw, content_html: entry.content_html}
    |> Storage.insert_entry()
  end
end
