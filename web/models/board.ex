defmodule Trellex.Board do
  use Trellex.Web, :model

  @derive {Poison.Encoder, only: [:name, :lists]}

  schema "boards" do
    field :name, :string

    has_many :lists, Trellex.List

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

# defimpl Poison.Encoder, for: Trellex.Board do
#   def encode(%{name: name, age: age}, options) do
#     Poison.Encoder.BitString.encode("#{name} (#{age})", options)
#   end
# end
