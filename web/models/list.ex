defmodule Trellex.List do
  use Trellex.Web, :model

  @derive {Poison.Encoder, only: [:id, :name]}

  schema "lists" do
    field :name, :string
    belongs_to :board, Trellex.Board

    has_many :cards, Trellex.Card

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
