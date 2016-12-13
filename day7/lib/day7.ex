defmodule Day7 do
  @doc ~S"""
      iex> Day7.has_ssl_support "input.txt"
      258

      iex> Day7.has_ssl_support "t1.txt"
      3
  """
  def has_ssl_support(file) do
    File.stream!(file, [:utf8])
      |> Stream.map(&(divide(&1)))
      |> Stream.map(fn({pos, babs}) -> {Enum.flat_map(pos, &abas_from/1), babs} end)
      |> Stream.filter(&any_ssl?/1)
      |> Enum.count
  end

  @doc ~S"""
    iex> Day7.ssl? %{"x" => "a", "y" => "b"}, ["bab"]
    true

    iex> Day7.ssl? %{"x" => "x", "y" => "y"}, ["xyx"]
    false

    iex> Day7.ssl? %{"x" => "z", "y" => "b"}, ["aaa", "zaz", "adsbzb"]
    true
  """
  def ssl?(aba, babs) do
    %{"x" => x, "y" => y} = aba
    Enum.any? babs, &(String.contains? &1, y <> x <> y)
  end

  @doc ~S"""
    iex> Day7.abas_from "zazbz"
    [%{"x" => "z", "y" => "b"}, %{"x" => "z", "y" => "a"}]

    iex> Day7.abas_from "aaaba"
    [%{"x" => "a", "y" => "b"}]
  """
  def abas_from(str \\ "", captures \\ [])
  def abas_from("", captures), do: Enum.uniq captures
  def abas_from(str, captures) do
    capture = Regex.named_captures ~r/(?<x>.)(?<y>.)\1/, str
    {_, next} = String.next_codepoint str
    if matched_different?(capture), do: abas_from(next, [capture | captures]), else: abas_from(next, captures)
  end

  @doc ~S"""
      iex> Day7.has_tls_support "input.txt"
      105
  """
  def has_tls_support(file) do
    File.stream!(file, [:utf8])
      |> Stream.map(&tls?/1)
      |> Stream.filter(&(&1))
      |> Enum.count
  end

  @doc ~S"""
      iex> Day7.tls? "abba[mnop]qrst"
      true

      iex> Day7.tls? "abcd[bddb]xyyx"
      false

      iex> Day7.tls? "aaaa[qwer]tyui"
      false

      iex> Day7.tls? "ioxxoj[asdfgh]zxcvbn"
      true
  """
  def tls?(str) do
    {pos, neg} = divide(str)
    Enum.any?(pos, &abba?/1) and Enum.all?(neg, &not_abba?/1)
  end

  defp any_ssl?({maps, babs}) do
    Enum.any? maps, &(ssl?(&1, babs))
  end

  defp not_abba?(str), do: !abba?(str)
  defp abba?(str) do
    matched_different? Regex.named_captures(~r/(?<x>.)(?<y>.)\2\1/, str)
  end

  defp divide(str) do
    String.split(str, ~r/\[|\]/)
      |> Enum.with_index
      |> Enum.reduce({[],[]}, fn({v, i}, {pos,neg}) ->
        if rem(i,2) == 0, do: {[v | pos], neg}, else:  {pos, [v | neg]}
      end)
  end

  defp matched_different?(%{"x" => x, "y" => y}), do: x !== y
  defp matched_different?(_), do: false
end
