defmodule FarneboFlora.Plants.FrequencyClass do
  @moduledoc """
  Custom Ecto type for plant frequency classes.
  Valid values are:
  - ta: tämligen allmän (fairly common)
  - a: allmän (common)
  - ma: mindre allmän (less common)
  - r: rar (rare)
  - s: sällsynt (very rare)
  - x: utdöd (extinct)
  """

  use Ecto.Type

  def type, do: :frequency_class

  def cast(value) when is_binary(value) do
    case value do
      "ta" -> {:ok, :ta}
      "a" -> {:ok, :a}
      "ma" -> {:ok, :ma}
      "r" -> {:ok, :r}
      "s" -> {:ok, :s}
      "x" -> {:ok, :x}
      _ -> :error
    end
  end

  def cast(_), do: :error

  def load(value) when is_binary(value) do
    cast(value)
  end

  def dump(value) when is_atom(value) do
    case value do
      :ta -> {:ok, "ta"}
      :a -> {:ok, "a"}
      :ma -> {:ok, "ma"}
      :r -> {:ok, "r"}
      :s -> {:ok, "s"}
      :x -> {:ok, "x"}
      _ -> :error
    end
  end

  def dump(_), do: :error
end
