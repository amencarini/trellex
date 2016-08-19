defmodule Trellex.Card do
  use Trellex.Web, :model

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

defimpl Poison.Encoder, for: Trellex.Card do
  def encode(model, opts) do
    %{
      id: model.id,
      name: model.name,
      description: model.description,
      listId: model.list_id
    }
    |> Poison.Encoder.encode(opts)
  end
end