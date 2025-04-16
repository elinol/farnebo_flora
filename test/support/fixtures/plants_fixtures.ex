defmodule FarneboFlora.PlantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FarneboFlora.Plants` context.
  """

  @doc """
  Generate a family.
  """
  def family_fixture(attrs \\ %{}) do
    {:ok, family} =
      attrs
      |> Enum.into(%{
        name: "some family"
      })
      |> FarneboFlora.Plants.create_family()

    family
  end

  @doc """
  Generate a plant.
  """
  def plant_fixture(attrs \\ %{}) do
    {:ok, family} = FarneboFlora.Plants.create_family(%{name: "A family name"})

    {:ok, plant} =
      attrs
      |> Enum.into(%{
        latin_name: "some latin_name",
        local_name: "some local_name",
        location: "some location",
        name: "some name",
        family_id: family.id
      })
      |> FarneboFlora.Plants.create_plant()

    plant
  end
end
