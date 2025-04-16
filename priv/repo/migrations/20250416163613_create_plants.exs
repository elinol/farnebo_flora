defmodule FarneboFlora.Repo.Migrations.CreatePlants do
  use Ecto.Migration

  def change do
    create table(:plants) do
      add :name, :string, null: false
      add :latin_name, :string, null: false
      add :local_name, :string
      add :frequency_class, :string
      add :location, :string
      add :seen_in_eighties, :boolean, default: true, null: false
      add :seen_now, :boolean, default: false, null: false

      add :family_id, references(:families, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:plants, [:name])
    create index(:plants, [:family_id])
  end
end
