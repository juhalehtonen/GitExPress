defmodule GitExPress.Worker do
  @moduledoc """
  Initializes the entry database on startup.
  """
  use GenServer

  # Client API

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, :ok, args)
  end

  def reload_entries() do
    GenServer.call(__MODULE__, :reload_entries)
  end

  # Server callbacks

  @doc """
  Initialize GenServer & handle storage setup without having start_link block.
  """
  def init(state) do
    send(self(), :setup)
    {:ok, state}
  end

  def handle_info(:setup, state) do
    hydrate_entries()
    {:noreply, state}
  end

  @doc """
  Receives the request, the process from which we received the request (_from),
  and the current server state.
  Returns a tuple in the format {:reply, reply, new_state}.
  """
  def handle_call(:reload_posts, _from, state) do
    hydrate_entries()

    {:reply, state, state}
  end

  defp hydrate_entries do
    with :ok <- GitExPress.Entries.Storage.init(),
         {:ok, entries} <- GitExPress.Entries.fetch_entries() do
      Enum.each(entries, fn x -> GitExPress.Entries.Storage.insert_entry(x) end)
    end
  end
end
