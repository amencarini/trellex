defmodule Trellex.PageController do
  use Trellex.Web, :controller

  alias Trellex.Repo

  def index(conn, _params) do
    render conn, "index.html",
      cards: Poison.encode!(cards),
      card_lists: Poison.encode!(card_lists),
      board_name: board.name
  end

  defp cards do
    card_lists
    |> Enum.map(&(&1.cards))
    |> List.flatten
  end

  defp card_lists, do: board.lists

  defp board do
    board = Repo.get(Trellex.Board, 1)
    |> Repo.preload([{:lists, :cards}])
  end
end
