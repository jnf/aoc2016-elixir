defmodule Day1 do
  defdelegate to_i(s), to: String, as: :to_integer

  @doc ~S"""
  Parses the given set of directions and a tuple containing the x/y coordinate
  of the first location visited more than once and its manhatten distance from
  the starting point (0, 0). The tuple is in the format of {:ok, x, y, distance}.
  ## Examples

      iex> Day1.repeat_distance "R8, R4, R4, R8"
      {:ok, 4.0, 0.0, 4.0}

  """
  def repeat_distance(str \\ "") do
    String.split(str, ", ") |> find_intersection
  end

  defp find_intersection([], _f, segments), do: {:error, segments}
  defp find_intersection([move | rest]) do
    {facing, point} = make_segment(move)
    find_intersection(rest, facing, [point])
  end
  defp find_intersection([move | rest], facing, segments = [prev | others]) do
    {new_facing, segment} = make_segment(move, facing, prev)
    {a1, b1, c1} = line_for segment

    does_intersect = Enum.find others, false, fn(pseg) ->
      {a2, b2, c2} = line_for pseg
      det = a1 * b2 - a2 * b1

      if det == 0 do
        false
      else
        # the lines intersect, but do the segments?
        x = (b2 * c1 - b1 * c2) / det
        y = (a1 * c2 - a2 * c1) / det
        
        {x1, y1, x2, y2} = segment
        {x3, y3, x4, y4} = pseg
        on1 = between(min(x1, x2), max(x1, x2), x)
        on2 = between(min(y1, y2), max(y1, y2), y)
        on3 = between(min(x3, x4), max(x3, x4), x)
        on4 = between(min(y3, y4), max(y3, y4), y)

        on1 && on2 && on3 && on4
      end
    end

    if does_intersect do
      {x, y} = where(segment, does_intersect)
      {:ok, x, y, manhatten_distance({:ok, x, y})}
    else
      find_intersection(rest, new_facing, [segment | segments])
    end
  end

  defp where(seg, pseg) do
    {a1, b1, c1} = line_for seg
    {a2, b2, c2} = line_for pseg
    det = a1 * b2 - a2 * b1

    x = (b2 * c1 - b1 * c2) / det
    y = (a1 * c2 - a2 * c1) / det

    {x, y}    
  end

  defp make_segment("R" <> num), do: {"E", {0, 0, 0 + to_i(num), 0}}
  defp make_segment("L" <> num), do: {"W", {0, 0, 0 - to_i(num), 0}}
  defp make_segment("R" <> num, facing, {_, _, x1, y1}) do
    case facing do
      "N" -> {"E", {x1, y1, x1 + to_i(num), y1}}
      "S" -> {"W", {x1, y1, x1 - to_i(num), y1}}
      "E" -> {"S", {x1, y1, x1, y1 - to_i(num)}}
      "W" -> {"N", {x1, y1, x1, y1 + to_i(num)}}
    end
  end
  defp make_segment("L" <> num, facing, {_, _, x1, y1}) do
    case facing do
      "N" -> {"W", {x1, y1, x1 - to_i(num), y1}}
      "S" -> {"E", {x1, y1, x1 + to_i(num), y1}}
      "E" -> {"N", {x1, y1, x1, y1 + to_i(num)}}
      "W" -> {"S", {x1, y1, x1, y1 - to_i(num)}}
    end
  end

  defp line_for({x1, y1, x2, y2}) do
    a = y2 - y1
    b = x1 - x2
    c = a * x1 + b * y1

    {a, b, c}
  end

  @doc ~S"""
  Parses the given set of directions into their manhantten distance.

  ## Examples

      iex> Day1.travel "R2, L3"
      5

      iex> Day1.travel "R2, R2, R2"
      2

      iex> Day1.travel "R5, L5, R5, R3"
      12

  """
  def travel(str \\ "") do
    String.split(str, ", ")
      |> Enum.reduce({'N', 0, 0}, &move/2)
      |> manhatten_distance
  end

  defp move("R" <> d, {'N', x, y}), do: {'E', x + to_i(d), y}
  defp move("L" <> d, {'S', x, y}), do: {'E', x + to_i(d), y}
  defp move("R" <> d, {'S', x, y}), do: {'W', x - to_i(d), y}
  defp move("L" <> d, {'N', x, y}), do: {'W', x - to_i(d), y}
  defp move("R" <> d, {'W', x, y}), do: {'N', x, y + to_i(d)}
  defp move("L" <> d, {'E', x, y}), do: {'N', x, y + to_i(d)}
  defp move("R" <> d, {'E', x, y}), do: {'S', x, y - to_i(d)}
  defp move("L" <> d, {'W', x, y}), do: {'S', x, y - to_i(d)}

  defp manhatten_distance({_, x, y}), do: abs(x) + abs(y)
  defp between(min, max, n), do: min <= n and n <= max
end
