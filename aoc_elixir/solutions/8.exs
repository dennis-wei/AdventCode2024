defmodule Day8 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/8.txt"
      true -> "test_input/8.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def all_antinodes(grid, {x1, y1}, {x2, y2}, part2 \\ true) do
    bdx = x2 - x1
    bdy = y2 - y1

    {range, dx, dy} = case part2 do
      false -> {1..1, bdx, bdy}
      true ->
        gcd = Integer.gcd(bdx, bdy)
        {0..10000, Integer.floor_div(bdx, gcd), Integer.floor_div(bdy, gcd)}
    end

    Enum.reduce_while(range, MapSet.new(), fn n, acc ->
      p1 = {x1 - n * dx, y1 - n * dy}
      p2 = {x2 + n * dx, y2 + n * dy}

      valid_points = Enum.filter([p1, p2], fn p -> Map.has_key?(grid, p) end)
      case valid_points do
        [] -> {:halt, acc}
        [p] -> {:cont, MapSet.put(acc, p)}
        [p1, p2] -> {:cont, MapSet.put(acc, p1) |> MapSet.put(p2)}
      end
    end)
  end

  def get_antinodes(grid, locs, part2 \\ true) do
    Comb.combinations(locs, 2)
    |> Enum.reduce(MapSet.new(), fn [n1, n2], acc ->
      points = all_antinodes(grid, n1, n2, part2)
      MapSet.union(acc, points)
    end)
  end

  def solve(test \\ false) do
    grid = get_input(test)
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()

    nodes = Enum.filter(grid, fn {_, v} -> v != "." end)
    |> Enum.group_by(fn {_, v} -> v end, fn {k, _v} -> k end)

    part1 = Enum.map(nodes, fn {_, v} -> get_antinodes(grid, v, false) end)
    |> Enum.reduce(MapSet.new(), fn new, acc -> MapSet.union(new, acc) end)
    |> Enum.count()
    part2 = Enum.map(nodes, fn {_, v} -> get_antinodes(grid, v, true) end)
    |> Enum.reduce(MapSet.new(), fn new, acc -> MapSet.union(new, acc) end)
    |> Enum.count()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day8.solve(false)
