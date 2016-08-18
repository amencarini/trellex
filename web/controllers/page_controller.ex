defmodule Trellex.PageController do
  use Trellex.Web, :controller

  alias Trellex.Repo

  def index(conn, _params) do
    render conn, "index.html", initial_state: Poison.encode!(initial_state)
  end

  defp initial_state do
    Repo.get(Trellex.Board, 1) |> Repo.preload([{:lists, :cards}])
  end
end
