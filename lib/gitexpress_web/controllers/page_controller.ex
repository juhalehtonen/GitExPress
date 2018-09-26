defmodule GitExPressWeb.PageController do
  use GitExPressWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
