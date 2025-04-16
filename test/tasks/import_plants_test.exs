defmodule FarneboFlora.Tasks.ImportPlantsTest do
  alias FarneboFlora.Plants
  use FarneboFlora.DataCase, async: true

  setup do
    # Create a temporary file with test data
    path = Path.join(System.tmp_dir(), "plant_import_test.csv")

    test_data = """
    Familjen Korgblommiga.
    Vägtistel, Cirsiun Vulgare: a. vägkanter, beten.
    Kärrtistel, C. palustre: a, vâta marker.
    Bradborste e. Borsttistel, C. heterophyllum:a. fuktig mark.

    Familjen Vattenklöver.
    Vattenklöver, Menyanthes trifolata: a. kärr o stränder.
    Vintergröna, Vince minor:ma. ofta odlad, krypbuske, Granön
    """

    File.write!(path, test_data)

    on_exit(fn -> File.rm(path) end)

    {:ok, %{path: path}}
  end

  test "imports plants from CSV file", %{path: path} do
    # Run the mix task with the test file
    assert :ok = Mix.Tasks.ImportPlants.run([path])

    families = Plants.list_families()
    assert length(families) == 2

    plants = Plants.list_plants()
    assert length(plants) == 5

    plants = Plants.list_all_plants_in_frequency_class("a")
    assert length(plants) == 4
  end
end
