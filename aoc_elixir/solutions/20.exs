defmodule Day20 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/20.txt"
      true -> "test_input/20.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  @valid_spaces MapSet.new(["S", "E", "."])

  @dirs [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  def get_dists(grid, graph_start) do
    dists = %{graph_start => 0}
    Enum.reduce_while(0..Enum.count(grid), {[graph_start], dists}, fn _n, {queue, dists} ->
      case queue do
        [] -> {:halt, dists}
        q ->
          {bx, by} = hd(q)
          dist_so_far = Map.get(dists, {bx, by})
          neighbors = @dirs
          |> Enum.map(fn {dx, dy} -> {bx + dx, by + dy} end)
          |> Enum.filter(fn n -> MapSet.member?(@valid_spaces, Map.get(grid, n)) end)
          |> Enum.filter(fn n -> !Map.has_key?(dists, n) end)

          updated_dists = Enum.reduce(neighbors, dists, fn n, dists -> Map.put(dists, n, dist_so_far + 1) end)
          {:cont, {tl(queue) ++ neighbors, updated_dists}}
      end
    end)
  end

  def get_cheats(dists, {taxicab_limit, shave}) do
    Enum.flat_map(Map.keys(dists), fn {x, y} ->
      res = Map.keys(dists)
      |> Enum.filter(fn {nx, ny} -> abs(nx - x) + abs(ny - y) <= taxicab_limit end)
      |> Enum.filter(fn {nx, ny} ->
        jump_dist = abs(nx - x) + abs(ny - y)
        Map.get(dists, {nx, ny}) - Map.get(dists, {x, y}) - jump_dist >= shave
      end)
      |> Enum.map(fn sn -> {{x, y}, sn} end)
      res
    end)
  end

  def solve(test \\ false) do
    grid = get_input(test)
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()
    graph_start = Enum.filter(grid, fn {_k, v} -> v == "S" end)
    |> hd()
    |> elem(0)
    dists = get_dists(grid, graph_start)

    shave_pt1 = case test do
      true -> 20
      false -> 100
    end
    part1 = get_cheats(dists, {2, shave_pt1})
    |> Enum.count()

    shave_pt2 = case test do
      true -> 74
      false -> 100
    end
    part2 = get_cheats(dists, {20, shave_pt2})
    |> Enum.count()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day20.solve()
