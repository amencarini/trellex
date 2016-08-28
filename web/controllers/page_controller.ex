defmodule Trellex.PageController do
  use Trellex.Web, :controller

  alias Trellex.Repo

  def index(conn, _params) do
    render conn, "index.html"
  end
end
