defmodule Grid do
  # by default, {column, row} ala graphics
  def to_map(glist, invert \\ false) do
    Map.new(glist, fn ent ->
      {n, r, c} = ent
      cond do
        invert -> {{r, c}, n}
        true -> {{c, r}, n}
      end
    end)
  end

  def make_grid(rows, invert \\ false) do
    as_list = rows
      |> Enum.map(&Enum.with_index/1)
      |> then(&Enum.with_index/1)
      |> Enum.flat_map(fn {row, ridx} -> Enum.map(row, fn e -> Tuple.insert_at(e, 1, ridx) end) end)

    to_map(as_list, invert)
  end

  def make_grid_with_size(rows, invert \\ false) do
    as_list = rows
      |> Enum.map(&Enum.with_index/1)
      |> then(&Enum.with_index/1)
      |> Enum.flat_map(fn {row, ridx} -> Enum.map(row, fn e -> Tuple.insert_at(e, 1, ridx) end) end)

    size = cond do
      invert -> {Enum.count(hd(rows)), Enum.count(rows)}
      true -> {Enum.count(rows), Enum.count(hd(rows))}
    end
    {to_map(as_list, invert), size}
  end

  @neighbors [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  @neighbors_diag [{0, 1}, {0, -1}, {1, 0}, {-1, 0}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
  def neighbors(diagonal \\ false) do
    case diagonal do
      false -> @neighbors
      true -> @neighbors_diag
    end
  end

  def get_neighbors(grid, {x, y}, diagonal \\ false) do
    Enum.reduce(neighbors(diagonal), %{}, fn ({dx, dy}, acc) ->
      adj = {x + dx, y + dy}
      case Map.get(grid, adj) do
        nil -> acc
        n -> Map.put(acc, adj, n)
      end
    end)
  end

  def get_neighbors_padded(grid, {x, y}, default, diagonal \\ false) do
    Enum.reduce(neighbors(diagonal), %{}, fn ({dx, dy}, acc) ->
      adj = {x + dx, y + dy}
      case Map.get(grid, adj) do
        nil -> Map.put(acc, adj, default)
        n -> Map.put(acc, adj, n)
      end
    end)
  end

  def invert(grid) do
    Enum.map(grid, fn {{x, y}, v} -> {{y, x}, v} end)
    |> Map.new()
  end

  def print_grid(inv_grid, replacements \\ %{}, sep \\ "", invert \\ false) do
    grid = case invert do
      true -> inv_grid
      false -> invert(inv_grid)
    end

    sorted = Enum.sort(Map.to_list(grid), fn ({{r1, c1}, _v1}, {{r2, c2}, _v2}) ->
      cond do
        r1 < r2 -> true
        r2 < r1 -> false
        c1 < c2 -> true
        c2 < c1 -> false
        true -> true
      end
    end)

    {{r, _c}, _v} = hd(sorted)
    {_p, acc} = Enum.reduce(sorted, {r, ""}, fn ({{nr, _nc}, nv}, {pr, acc}) ->
      to_print = Map.get(replacements, nv, nv)
      cond do
        nr == pr ->
          {nr, "#{acc}#{sep}#{to_print}"}
        true ->
          IO.puts(acc)
          {nr, "#{to_print}"}
      end
    end)
    IO.puts(acc)
    IO.puts("\n")
  end
end
