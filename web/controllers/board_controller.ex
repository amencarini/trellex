defmodule Trellex.BoardController do
  use Trellex.Web, :controller

  alias Trellex.Board

  def index(conn, _params) do
    boards = Repo.all(Board)
    render(conn, "index.html", boards: boards)
  end

  def new(conn, _params) do
    changeset = Board.changeset(%Board{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"board" => board_params}) do
    changeset = Board.changeset(%Board{}, board_params)

    case Repo.insert(changeset) do
      {:ok, _board} ->
        conn
        |> put_flash(:info, "Board created successfully.")
        |> redirect(to: board_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    board = Repo.get!(Board, id) |> Repo.preload([{:lists, :cards}])
    render conn, "show.html", 
      board: board,
      cards: Poison.encode!(cards(board)),
      card_lists: Poison.encode!(board.lists)
  end

  def edit(conn, %{"id" => id}) do
    board = Repo.get!(Board, id)
    changeset = Board.changeset(board)
    render(conn, "edit.html", board: board, changeset: changeset)
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    board = Repo.get!(Board, id)
    changeset = Board.changeset(board, board_params)

    case Repo.update(changeset) do
      {:ok, board} ->
        conn
        |> put_flash(:info, "Board updated successfully.")
        |> redirect(to: board_path(conn, :show, board))
      {:error, changeset} ->
        render(conn, "edit.html", board: board, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    board = Repo.get!(Board, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(board)

    conn
    |> put_flash(:info, "Board deleted successfully.")
    |> redirect(to: board_path(conn, :index))
  end

  defp cards(board) do
    board.lists
    |> Enum.map(&(&1.cards))
    |> List.flatten
  end
end
