defmodule FarneboFlora.Plants.Family do
  use Ecto.Schema
  import Ecto.Changeset

  schema "families" do
    field :name, :string

    has_many :plants, FarneboFlora.Plants.Plant

    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
