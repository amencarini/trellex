defmodule Trellex.Card do
  use Trellex.Web, :model

  @derive {Poison.Encoder, only: [:id, :name, :description]}

  schema "cards" do
    field :name, :string
    field :description, :string
    belongs_to :list, Trellex.List

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end
end
