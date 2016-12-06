defmodule Day3 do
  defdelegate to_i(s), to: String, as: :to_integer

  @doc ~S"""
  Parses instructions to determine bathroom code
  ## Examples

      iex> Day3.part1 "t2.txt"
      1

      iex> Day3.part1 "t2.txt"
      1

      iex> Day3.part1 "input.txt"
      983
  """
  def part1(input) do
    File.stream!(input, [:utf8])
      |> Stream.map(&(String.split(&1, ~r/\s+|\n/, trim: true)))
      |> Stream.map(&triangle?/1)
      |> Enum.reduce(0, &(&1+&2))
  end

  @doc ~S"""
  Parses instructions to determine bathroom code using vertical columns
  ## Examples

      iex> Day3.part2 "t3.txt"
      8

      iex> Day3.part2 "input.txt"
      1836
  """
  def part2(input) do
    File.stream!(input, [:utf8])
      |> Stream.map(&(String.split(&1, ~r/\s+|\n/, trim: true)))
      |> Stream.chunk(3)
      |> Stream.map(&rearrange/1)
      |> Stream.transform(0, &triangles_from_list/2)
      |> Enum.reduce(0, &(&1+&2))
  end

  defp rearrange([[a1, a2, a3], [b1, b2, b3], [c1, c2, c3]]) do
    [[a1, b1, c1], [a2, b2, c2], [a3, b3, c3]]
  end

  defp triangles_from_list(list, _) do
    {Enum.map(list, &triangle?/1), true}
  end

  defp triangle?(line, _acc \\ 0) do
    [a, b, c] = Enum.map(line, &to_i/1) |> Enum.sort
    if a + b > c, do: 1, else: 0
  end
end
