defmodule Trellex.BoardControllerTest do
  use Trellex.ConnCase

  alias Trellex.Board
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, board_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing boards"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, board_path(conn, :new)
    assert html_response(conn, 200) =~ "New board"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, board_path(conn, :create), board: @valid_attrs
    assert redirected_to(conn) == board_path(conn, :index)
    assert Repo.get_by(Board, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, board_path(conn, :create), board: @invalid_attrs
    assert html_response(conn, 200) =~ "New board"
  end

  test "shows chosen resource", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = get conn, board_path(conn, :show, board)
    assert html_response(conn, 200) =~ "Show board"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, board_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = get conn, board_path(conn, :edit, board)
    assert html_response(conn, 200) =~ "Edit board"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = put conn, board_path(conn, :update, board), board: @valid_attrs
    assert redirected_to(conn) == board_path(conn, :show, board)
    assert Repo.get_by(Board, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = put conn, board_path(conn, :update, board), board: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit board"
  end

  test "deletes chosen resource", %{conn: conn} do
    board = Repo.insert! %Board{}
    conn = delete conn, board_path(conn, :delete, board)
    assert redirected_to(conn) == board_path(conn, :index)
    refute Repo.get(Board, board.id)
  end
end
