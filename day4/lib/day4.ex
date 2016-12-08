defmodule Day4 do
  defdelegate to_i(s), to: String, as: :to_integer

  @roomPattern ~r/^(?<code>.+)-(?<sector>\d+)\[(?<checksum>.+)\]$/

  @doc ~S"""
    iex> Day4.process "t1.txt"
    1857

    iex> Day4.process "input.txt"
    185371
  """
  def process(file) do
    File.stream!(file, [:utf8])
      |> Stream.map(&prepLine/1)
      |> Stream.map(&checksum/1)
      |> Enum.reduce(0, fn({_, n}, acc) -> acc + n end)
  end

  defp checksum(%{ "code" => code, "sector" => sector, "checksum" => checksum }) do
    counts = count(code) |> Enum.sort(&compare/2) |> first_five([])
    if counts === checksum, do: {:valid, to_i(sector)}, else: {:invlaid, 0}
  end

  def first_five(_, cs) when length(cs) == 5, do: Enum.join(cs)
  def first_five([{letter, count} | rest], cs), do: first_five(rest, cs ++ [letter])

  @doc ~S"""
      iex> Day4.decode "t2.txt"
      :ok

      iex> Day4.decode "input.txt"
      {:ok, "984", "northpoleCobjectCstorage"}
  """
  def decode(file, phrase \\ ~r/northpole/) do
    File.stream!(file, [:utf8])
      |> Stream.map(&prepLine/1)
      |> Stream.filter_map(&filter/1, &shift/1)
      |> Enum.find(fn({:ok, sector, name}) -> String.match?(name, phrase) end)
  end

  defp filter(line) do
    case checksum(line) do
      {:valid, nsec} -> true
      _ -> false
    end
  end

  defp shift(%{ "code" => code, "sector" => sector, "checksum" => checksum }) do
    offset = rem to_i(sector), 26
    phrase = to_charlist(code) |> Enum.map(fn (n) -> if n + offset > 122, do: n + offset - 26, else: n + offset end)
    {:ok, sector, to_string phrase}
  end

  @doc ~S"""
      iex> Day4.compare({"a", 2}, {"b", 2})
      true

      iex> Day4.compare({"b", 2}, {"a", 2})
      false

      iex> Day4.compare({"b", 3}, {"c", 4})
      false

      iex> Day4.compare({"d", 5}, {"a", 4})
      true
  """
  def compare({l1, c1}, {l2, c2}) when c1 == c2, do: l2 > l1
  def compare({_, c1}, {_, c2}), do: c1 > c2

  @doc ~S"""
      iex> Day4.prepLine "totally-real-room-200[decoy]"
      %{"code" => "totally-real-room", "checksum" => "decoy", "sector" => "200"}
  """
  def prepLine(str), do: Regex.named_captures @roomPattern, str

  @doc ~S"""
    iex> Day4.count "qzmt-zixmtkozy-ivhz"
    %{"h" => 1, "i" => 2, "k" => 1, "m" => 2, "o" => 1, "q" => 1, "t" => 2, "v" => 1, "x" => 1, "y" => 1, "z" => 4}

    iex> Day4.count "abc---"
    %{"a" => 1, "b" => 1, "c" => 1}

    iex> Day4.count "totally-real-room"
    %{"a" => 2, "e" => 1, "l" => 3, "m" => 1, "o" => 3, "r" => 2, "t" => 2, "y" => 1}
  """
  def count(str \\ "", map \\ %{})
  def count("", map), do: map
  def count("-" <> rest, map), do: count(rest, map)
  def count(<<letter::binary-size(1),rest::binary>>, map = %{}) do
    {_, m} = Map.get_and_update(map, letter, fn (c) -> if c, do: {c, c+1}, else: {c, 1} end)
    count(rest, m)
  end
end
