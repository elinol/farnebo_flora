defmodule FarneboFlora.Plants.Plant do
  use Ecto.Schema
  import Ecto.Changeset

  alias FarneboFlora.Plants.FrequencyClass

  schema "plants" do
    field :name, :string
    field :latin_name, :string
    field :local_name, :string
    field :frequency_class, FrequencyClass
    field :location, :string
    field :seen_in_eighties, :boolean, default: true
    field :seen_now, :boolean, default: false

    belongs_to :family, FarneboFlora.Plants.Family

    timestamps(type: :utc_datetime)
  end

  @required [:name, :latin_name, :family_id]
  @wanted @required ++ [:local_name, :location, :frequency_class, :seen_in_eighties, :seen_now]

  @doc false
  def changeset(plant, attrs) do
    plant
    |> cast(attrs, @wanted)
    |> validate_required(@required)
    |> foreign_key_constraint(:family_id)
  end
end
