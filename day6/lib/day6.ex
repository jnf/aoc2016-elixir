defmodule Day6 do
  @doc ~S"""
      iex> Day6.solve "t1.txt"
      "easter\n"

      iex> Day6.solve "input.txt"
      "gebzfnbt\n"

      iex> Day6.solve "t1.txt", &Enum.min_by/2
      "advent\n"

      iex> Day6.solve "input.txt", &Enum.min_by/2
      "fykjtwyn\n"
  """
  def solve(file, finder \\ &Enum.max_by/2) do
    parse(file)
      |> Enum.map(&(find_with(Tuple.to_list(&1), finder)))
      |> Enum.map_join(fn({k, _c}) -> to_string <<k>> end)
  end

  defp parse(file) do
    File.stream!(file, [:utf8])
      |> Stream.map(&to_charlist/1)
      |> Enum.to_list
      |> List.zip
  end

  defp find_with(list, fun) do
    make_count(list) |> fun.(fn({_key, count}) -> count end)
  end

  defp make_count(list) do
    Enum.reduce(list, %{}, fn(ele, acc) ->
      {_, acc} = Map.get_and_update acc, ele, &({&1, (&1 || 0) + 1})
      acc
    end)
  end
end
