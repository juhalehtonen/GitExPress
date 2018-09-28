defmodule GitExPress.Entries.Storage do
  @moduledoc """
  This Storage module handles the Mnesia database.
  """
  require Logger
  alias :mnesia, as: Mnesia
  alias GitExPress.Entries.Entry
  @entry_table GitExPressEntries

  @doc """
  1. Initialize a new empty schema by passing in a Node List.
  2. Create a table index for :source, allowing us to query by source.
  3. Create the table called entries and define the schema.
  4. Start Mnesia.
  TODO: Check if this succeeds? Does it matter? These four, respectively, return these
  when the table and the schema already exist on the system:
  {:error, {:nonode@nohost, {:already_exists, :nonode@nohost}}}
  :ok
  {:aborted, {:already_exists, Entries}}
  {:aborted, {:already_exists, Entries, 6}}
  """
  @spec init() :: :ok | {:error, any()}
  def init do
    Mnesia.create_schema([node()])
    Mnesia.start()

    case Mnesia.create_table(@entry_table,
           record_name: @entry_table,
           attributes: [:title, :date, :slug, :content_raw, :content_html, :content_type]
         ) do
      {:atomic, :ok} ->
        Mnesia.add_table_index(@entry_table, :content_type)
        :ok

      _ ->
        :ok
    end
  end

  @doc """
  Insert an entry to our Mnesia database. We do this with an Mnesia transaction.
  An Mnesia transaction is a mechanism by which a series of database operations
  can be executed as one functional block.
  """
  @spec insert_entry(%Entry{}) :: {:ok, String.t()} | {:error, String.t()}
  def insert_entry(entry) when is_map(entry) do
    data_to_write = fn ->
      Mnesia.write(
        {@entry_table, entry.title, entry.date, entry.slug, entry.content_raw, entry.content_html,
         entry.content_type}
      )
    end

    perform_transaction(data_to_write)
  end

  def insert_entry(_other) do
    {:error, "Entry not of required type (Entry Struct)"}
  end

  @doc """
  Return all entries. We do this with an Mnesia transaction.
  An Mnesia transaction is a mechanism by which a series of database operations
  can be executed as one functional block.
  """
  def get_entries() do
    data_to_read = fn ->
      Mnesia.index_read(@entry_table, "blog", :content_type)
    end

    perform_transaction(data_to_read)
  end

  @doc """
  Get entries by field and value, where field is the field in the Entry struct you
  want to look for, and value is the value of that field.

  [:title, :date, :slug, :content_raw, :content_html, :content_type]

  # TODO: Restrict only to specific field atoms, now we can pass anything and still attempt a transaction
  """
  def get_entries_by(field, value) when is_atom(field) do
    data_to_read =
      case field do
        :title ->
          fn -> Mnesia.match_object({@entry_table, value, :_, :_, :_, :_, :_}) end
        :date ->
          fn -> Mnesia.match_object({@entry_table, :_, value, :_, :_, :_, :_}) end
        :slug ->
          fn -> Mnesia.match_object({@entry_table, :_, :_, value, :_, :_, :_}) end
        :content_type ->
          fn -> Mnesia.match_object({@entry_table, :_, :_, :_, :_, :_, value}) end
      end

    perform_transaction(data_to_read)
  end

  # Perform an Mnesia transaction on given `data`, where `data` is an Entry.
  @spec perform_transaction(fun()) :: tuple()
  defp perform_transaction(data) do
    case Mnesia.transaction(data) do
      {:atomic, result} ->
        Logger.info("Transaction OK")
        {:ok, result}

      {:aborted, reason} ->
        Logger.info("Transaction error")
        IO.inspect(reason)
        {:error, reason}
    end
  end
end
