defmodule D5 do
  @size 10000
  @workers 25

  @doc ~S"""
      # iex> D5.build2 "abc"
      # "05ace8e3"

      iex> D5.build2 "uqwqemis"
      "694190cd"
  """
  def build2(str, start \\ 0, code \\ "--------")
  def build2(str, start, code) do
    new_code = batch2(str, start, code)
    if String.contains?(new_code, "-") do
      next_start = @workers * @size + start
      build2(str, next_start, new_code)
    else
      new_code
    end

  end

  defp batch2(str, start, code) do
    0..@workers - 1
      |> Enum.map(fn(i) -> Task.async(fn -> hash2(str, start + (i * @size)) end) end)
      |> Enum.map(&Task.await/1)
      |> List.flatten
      |> Enum.reduce(code, fn({pos, val}, code) -> update_code(code, pos, val) end)
  end

  defp hash2(str, start) do
    Enum.reduce start..start+@size, [], fn (n, acc) ->
      <<a, b, pos, d>> = binary_part :crypto.hash(:md5, str <> to_string(n)), 0, 4

      if a == 0 and b == 0 and pos <= 7 do
        {val, _} = Base.encode16(<<d>>, case: :lower) |> String.next_codepoint
        [{pos, val} | acc]
      else
        acc
      end
    end
  end

  defp update_code(code, pos, val) do
    if String.at(code, pos) == "-", do: replace(code, pos, val), else: code
  end

  defp replace(code, pos, val) do
    tail = 7 - pos
    <<a::binary-size(pos), _b::binary-size(1), c::binary-size(tail)>> = code
    a <> val <> c
  end

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

