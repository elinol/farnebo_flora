defmodule Mix.Tasks.ImportPlants do
  alias FarneboFlora.Plants.Family
  alias FarneboFlora.Plants.Plant
  alias FarneboFlora.Repo
  use Mix.Task

  @shortdoc "Imports plants from a csv file"

  @impl Mix.Task
  def run(args) do
    case args do
      [file_path] ->
        # Check if file exists
        if File.exists?(file_path) do
          Mix.shell().info("Importing plants from #{file_path}...")
          # Start your application to access Repo
          {:ok, _} = Application.ensure_all_started(:farnebo_flora)

          # Process the CSV file
          file_path
          |> File.read!()
          |> parse_plant_file()
          |> import_plants()
          |> IO.inspect()

          Mix.shell().info("Import completed successfully!")
        else
          Mix.shell().error("File not found: #{file_path}")
          exit({:shutdown, 1})
        end

      [] ->
        Mix.shell().error("Missing file path. Usage: mix import_plants path/to/file.csv")
        exit({:shutdown, 1})

      _other ->
        Mix.shell().error("Too many arguments. Usage: mix import_plants path/to/file.csv")
        exit({:shutdown, 1})
    end
  end

  defp parse_plant_file(content) do
    # Split content by empty lines to separate family sections
    sections =
      content
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(String.length(&1) > 0))

    # Process each family section
    Enum.map(sections, &parse_family_section/1)
  end

  defp parse_family_section(section) do
    # Split the section into lines
    lines = String.split(section, "\n", trim: true)

    # First line is the family name (remove "Familjen " prefix)
    [family_line | plant_lines] = lines

    family_name =
      family_line
      |> String.trim()
      |> String.replace(~r/^Familjen\s+/, "")
      |> String.replace(".", "")

    # Parse each plant line
    plants =
      Enum.map(plant_lines, fn line ->
        parse_plant_line(line, family_name)
      end)

    %{family: family_name, plants: plants}
  end

  defp parse_plant_line(line, family_name) do
    # Parse plant details from line
    # Format: Name, Latin name: frequency, location.
    line = String.trim(line)

    # Extract name and the rest
    [name_part, details_part] =
      case String.split(line, ",", parts: 2) do
        # Handle case with no comma
        [name] -> [name, ""]
        parts -> parts
      end

    # Get local name if any
    {name, local_name} =
      case String.split(name_part, "e.", parts: 2) do
        [name] -> {String.trim(name), nil}
        [name, local_name] -> {String.trim(name), String.trim(local_name)}
      end

    # Extract Latin name and the remainder
    # TODO: Get full latin name from previous plant if first part is shortened
    {latin_name, freq_location} =
      case String.split(details_part, ":", parts: 2) do
        # Handle case with no colon
        [latin] -> {String.trim(latin), ""}
        [latin, rest] -> {String.trim(latin), String.trim(rest)}
      end

    # Extract frequency and location
    # Find the position of the first comma and period
    first_comma_pos =
      case :binary.match(freq_location, ",") do
        :nomatch -> nil
        {pos, _} -> pos
      end

    first_period_pos =
      case :binary.match(freq_location, ".") do
        :nomatch -> nil
        {pos, _} -> pos
      end

    # Determine the delimiter position based on which comes first
    delimiter_pos =
      cond do
        first_comma_pos != nil and first_period_pos != nil ->
          Enum.min([first_comma_pos, first_period_pos])

        first_comma_pos != nil ->
          first_comma_pos

        first_period_pos != nil ->
          first_period_pos

        true ->
          nil
      end

    # Split based on the first delimiter found
    {frequency, location} =
      if delimiter_pos == nil do
        {String.trim(freq_location), ""}
      else
        {f, l} = String.split_at(freq_location, delimiter_pos)

        {String.trim(f), String.trim(String.slice(l, 1..-1//1))}
      end

    # Clean up fields
    frequency = frequency |> String.replace(".", "")
    location = location |> String.replace(".", "")

    %{
      name: name,
      latin_name: latin_name,
      local_name: local_name,
      family: family_name,
      frequency: frequency,
      location: location
    }
  end

  defp import_plants(parsed_data) do
    Repo.transaction(fn ->
      Enum.each(parsed_data, fn %{family: family_name, plants: plants} ->
        # Find or create the family
        family =
          case Repo.get_by(Family, name: family_name) do
            nil ->
              {:ok, family} = %Family{name: family_name} |> Repo.insert()
              family

            existing ->
              existing
          end

        # Create plants
        Enum.each(plants, fn plant_data ->
          %Plant{}
          |> Plant.changeset(%{
            name: plant_data.name,
            family_id: family.id,
            latin_name: plant_data.latin_name,
            frequency_class: plant_data.frequency,
            location: plant_data.location
          })
          |> Repo.insert!()
        end)
      end)
    end)
  end
end
