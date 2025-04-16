defmodule FarneboFlora.Repo.Migrations.CreateFamiliesAndPlants do
  use Ecto.Migration

  def change do
    create table(:families) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:families, [:name])
  end
end
