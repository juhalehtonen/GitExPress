defmodule GitExPress.Entries.Entry do
  @moduledoc """
  The Entry struct represents a single entry in the GitExPress system. All saved
  entries are converted to a format that fits the struct defined here, which allows
  us to keep all our web-facing representations of data follow the same shape.

  Entries are completely independent of their source, so they are kept separeted
  in their own module.
  """

  defstruct [:title, :date, :slug, :content_raw, :content_html]
end
