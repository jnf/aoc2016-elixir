defmodule D5 do
  @size 10000
  @workers 25

  @doc ~S"""
      # iex> D5.solve "abc"
      # "18f47a30"

      iex> D5.solve "uqwqemis"
      "1a3099aa"
  """
  def solve(str \\ "", start \\ 0, results \\ [])
  def solve(_, _, results) when length(results) >= 8 do
    Enum.sort(results) |> Enum.reduce("", fn({_n,v},a) -> a<>v end) |> binary_part(0, 8)
  end
  def solve(str, start, results) do
    new_results = batch(str, start)
    next_start = @workers * @size + start
    solve(str, next_start, new_results ++ results)
  end

  defp batch(str, start) do
    0..@workers - 1
      |> Enum.map(fn(i) -> Task.async(fn -> hash(str, start + (i * @size)) end) end)
      |> Enum.map(&Task.await/1)
      |> List.flatten
  end

  defp hash(str, start) do
    Enum.reduce start..start+@size, [], fn (n, acc) ->
      <<a, b, c>> = binary_part :crypto.hash(:md5, str <> to_string(n)), 0, 3
      if a == 0 and b == 0 and c <= 15 do
        {_, val} = Base.encode16(<<c>>, case: :lower) |> String.next_codepoint
        [{n, val} | acc]
      else
        acc
      end
    end
  end
end
