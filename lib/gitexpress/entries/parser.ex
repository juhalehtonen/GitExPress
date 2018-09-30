defmodule GitExPress.Entries.Parser do
  @moduledoc """
  Provide mechanisms for parsing markdown content and converting it to GitExPress
  friendly format.
  """
  require Logger
  alias GitExPress.Entries.Entry
  @source Application.get_env(:gitexpress, :local_path)
  @meta_title "Title: "
  @meta_date "Date: "

  @doc """
  Go through all markdown posts and generates Posts from each.
  """
  @spec generate_entries(String.t()) :: []
  def generate_entries(path \\ @source) do
    path
    |> get_files()
    |> Enum.map(fn file -> Task.async GitExPress.Entries.Parser, :read, [file] end)
    |> handle_tasks()
    |> Enum.map(fn entry ->
         Task.async GitExPress.Entries.Parser, :construct_entry, [entry]
       end)
    |> handle_tasks()
  end

  @doc """
  Gets files from the given location, or as specified in the GitExPress config.
  Returns a list of paths.
  """
  @spec get_files(String.t) :: list(String.t)
  def get_files(path \\ @source) do
    path = path <> "/**/*.md"
    Logger.info "Searching '.md' files using '#{path}' within '#{System.cwd}'"

    # Path.wildcard traverses paths according to the given glob expression and
    # returns a list of matches.
    Logger.info "Posts:"
    Logger.info Path.wildcard(path)
    Path.wildcard(path)
  end

  @doc """
  Reads and parses a single markdown file. Expects the file to be in the GitExPress
  format.

  If successful, returns in the format:

  ```
  [{:ok, ["Title: Future is far away\n", "Date: 2018-01-23\n"],
  ["This blog was built with Elixir and Phoenix.\n", "\n",
   "Here I just have arbitrary content.\n"]}]
  ```

  """
  @spec read(String.t) :: tuple()
  def read(file) do
    if File.exists?(file) do
      [meta, content] = file
      |> File.stream!
      |> Stream.chunk_by(fn(x) -> String.starts_with?(x, [@meta_title, @meta_date]) end)
      |> Enum.to_list()

      {:ok, meta, content}
    else
      {:error, "Could not read file #{file}"}
    end
  end

  @doc """
  Construct a GitExPress Post using the `meta` and `content`.
  """
  @spec construct_entry({:ok, map(), list()}) :: %Entry{}
  def construct_entry({:ok, meta, content}) do
    meta = Enum.map(meta, fn(x) ->
      x
      |> String.trim_leading("Title: ")
      |> String.trim_leading("Date: ")
      |> String.trim()
    end)

    title = Enum.at(meta, 0)
    date = extract_date(Enum.at(meta, 1))
    slug = Slugger.slugify_downcase(Enum.at(meta, 0))

    content_raw = List.to_string(content)
    content_html = Earmark.as_html!(content)

    %Entry{title: title, date: date, slug: slug, content_raw: content_raw, content_html: content_html, content_type: "blog"}
  end
  def construct_post({:error, reason}), do: {:error, reason}

  @doc """
  Await for async list of tasks.
  """
  @spec handle_tasks(any()) :: any()
  def handle_tasks(tasks) do
    Enum.map tasks, fn task -> Task.await task end
  end

  @doc """
  Extract date from a date string, or return empty string as placeholder if a
  date cannot be returned.

  ## Examples
  When a date can be extracted, it is returned.

      iex> GitExPress.Parser.extract_date("2017-01-01")
      ~D[2017-01-01]

  When a date cannot be extracted, an empty string is returned.

      iex> GitExPress.Parser.extract_date("notadate")
      ""

  """
  @spec extract_date(String.t) :: tuple() | String.t
  def extract_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      _           -> ""
    end
  end
end
