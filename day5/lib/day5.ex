defmodule Day5 do
  defdelegate to_i(s), to: String, as: :to_integer

  @doc ~S"""
      # iex> Day5.build "abc"
      # "18f47a30"

      # iex> Day5.build "uqwqemis"
      # "1a3099aa"
  """
  def build(str, num \\ 0, code \\"")
  def build(_, _, code) when byte_size(code) == 8, do: code
  def build(str, num, code) do
    <<a, b, c>> = binary_part :crypto.hash(:md5, str <> to_string(num)), 0, 3

    {_, val} = cond do
      a + b == 0 and c <= 15 -> Base.encode16(<<c>>, case: :lower) |> String.next_codepoint
      true -> {:err, ""}
    end

    build(str, num + 1, code <> val)
  end

  @doc ~S"""
      # iex> Day5.build2 "abc"
      # "05ace8e3"

      iex> Day5.build2 "uqwqemis"
      {:ok, 26326686, "694190cd"}
  """
  def build2(str, num \\ 0, code \\ "--------")
  def build2(str, num, code) do
    <<a, b, pos, d>> = binary_part :crypto.hash(:md5, str <> to_string(num)), 0, 4

    {val, _} = cond do
      a + b == 0 and pos <= 7 -> Base.encode16(<<d>>, case: :lower) |> String.next_codepoint
      true -> {:err, ""}
    end

    if String.contains?(code, "-") do
      build2(str, num + 1, update_code(code, pos, val))
    else
      {:ok, num, code}
    end
  end

  defp update_code(code, _, :err), do: code
  defp update_code(code, pos, val) do
    if String.at(code, pos) == "-", do: replace(code, pos, val), else: code
  end

  defp replace(code, pos, val) do
    tail = 7 - pos
    <<a::binary-size(pos), _b::binary-size(1), c::binary-size(tail)>> = code
    a <> val <> c
  end
end
