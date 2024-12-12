defmodule Day12 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/12.txt"
      true -> "test_input/12.3.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def get_perimeter(grid, {c, section}) do
    Enum.reduce(section, 0, fn p, acc ->
      sides = Grid.get_neighbors_padded(grid, p, ".")
      |> Enum.filter(fn {_nk, nv} -> nv != c end)
      |> Enum.count()
      acc + sides
    end)
  end

  @left {-1, 0}
  @up {0, -1}
  @right {1, 0}
  @down {0, 1}
  @upleft {-1, -1}
  @upright {1, -1}
  @downleft {-1, 1}
  @downright {1, 1}
  @corner_checks [{@left, @up, @upleft}, {@up, @right, @upright}, {@right, @down, @downright}, {@down, @left, @downleft}]

  def get_sides(grid, {c, section}) do
    Enum.reduce(section, 0, fn {x, y}, acc ->
      Enum.reduce(@corner_checks, acc, fn {{c1x, c1y}, {c2x, c2y}, {c3x, c3y}}, iacc ->
        c1_val = Map.get(grid, {x + c1x, y + c1y})
        c2_val = Map.get(grid, {x + c2x, y + c2y})
        c3_val = Map.get(grid, {x + c3x, y + c3y})
        cond do
          c1_val != c and c2_val != c -> iacc + 1
          c1_val == c and c2_val == c and c3_val != c -> iacc + 1
          true -> iacc
        end
      end)
    end)
  end

  def solve(test \\ false) do
    grid = get_input(test)
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()

    graph = Enum.reduce(grid, Graph.new(type: :undirected), fn {k, v}, acc ->
      Enum.reduce(Grid.get_neighbors(grid, k), acc, fn {nk, nv}, iacc ->
        cond do
          v == nv -> Graph.add_edge(iacc, k, nk)
          true -> iacc
        end
      end)
    end)

    sections = Graph.components(graph)
    |> Enum.map(fn coords ->
      char = Map.get(grid, hd(coords))
      {char, coords}
    end)

    component_coords = Enum.reduce(sections, MapSet.new(), fn {_, v}, acc -> MapSet.union(acc, MapSet.new(v)) end)
    single_coords = Enum.filter(grid, fn {k, _} -> !MapSet.member?(component_coords, k) end)
    single_scores = 4 * length(single_coords)

    {pt1_comp, pt2_comp} = Enum.reduce(sections, {0, 0}, fn section, {acc1, acc2} ->
      {_c, coords} = section
      area = Enum.count(coords)
      perimeter = get_perimeter(grid, section)
      sides = get_sides(grid, section)
      {acc1 + (area * perimeter), acc2 + (area * sides)}
    end)
    part1 = pt1_comp + single_scores
    part2 = pt2_comp + single_scores
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day12.solve()
