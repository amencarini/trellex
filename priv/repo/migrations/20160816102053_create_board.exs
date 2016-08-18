defmodule Trellex.Repo.Migrations.CreateBoard do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string

      timestamps()
    end

  end
end
