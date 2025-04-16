defmodule FarneboFlora.PlantsTest do
  use FarneboFlora.DataCase
  import FarneboFlora.PlantsFixtures

  alias FarneboFlora.Plants
  alias FarneboFlora.Plants.Family
  alias FarneboFlora.Plants.Plant

  describe "categories" do
    test "list all families" do
      family = family_fixture()
      assert Plants.list_families() == [family]
    end

    test "create family" do
      valid_attrs = %{name: "some family"}

      assert {:ok, %Family{} = family} = Plants.create_family(valid_attrs)
      assert family.name == "some family"
    end
  end

  describe "plants" do
    @invalid_attrs %{name: nil, location: nil, latin_name: nil, local_name: nil}

    test "list_plants/0 returns all plants" do
      plant = plant_fixture()
      assert Plants.list_plants() == [plant]
    end

    test "get_plant!/1 returns the plant with given id" do
      plant = plant_fixture()
      assert Plants.get_plant!(plant.id) == plant
    end

    test "create_plant/1 with valid data creates a plant" do
      family = family_fixture()

      valid_attrs = %{
        name: "some name",
        location: "some location",
        latin_name: "some latin_name",
        local_name: "some local_name",
        family_id: family.id
      }

      assert {:ok, %Plant{} = plant} = Plants.create_plant(valid_attrs)
      assert plant.name == "some name"
      assert plant.location == "some location"
      assert plant.latin_name == "some latin_name"
      assert plant.local_name == "some local_name"
    end

    test "create_plant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Plants.create_plant(@invalid_attrs)
    end

    test "update_plant/2 with valid data updates the plant" do
      plant = plant_fixture()

      update_attrs = %{
        name: "some updated name",
        location: "some updated location",
        latin_name: "some updated latin_name",
        local_name: "some updated local_name"
      }

      assert {:ok, %Plant{} = plant} = Plants.update_plant(plant, update_attrs)
      assert plant.name == "some updated name"
      assert plant.location == "some updated location"
      assert plant.latin_name == "some updated latin_name"
      assert plant.local_name == "some updated local_name"
    end

    test "update_plant/2 with invalid data returns error changeset" do
      plant = plant_fixture()
      assert {:error, %Ecto.Changeset{}} = Plants.update_plant(plant, @invalid_attrs)
      assert plant == Plants.get_plant!(plant.id)
    end

    test "delete_plant/1 deletes the plant" do
      plant = plant_fixture()
      assert {:ok, %Plant{}} = Plants.delete_plant(plant)
      assert_raise Ecto.NoResultsError, fn -> Plants.get_plant!(plant.id) end
    end

    test "change_plant/1 returns a plant changeset" do
      plant = plant_fixture()
      assert %Ecto.Changeset{} = Plants.change_plant(plant)
    end
  end
end
