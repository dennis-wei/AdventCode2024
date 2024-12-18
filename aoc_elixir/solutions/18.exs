defmodule Day18 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/18.txt"
      true -> "test_input/18.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def init_grid(size) do
    Enum.reduce(0..size-1, %{}, fn x, acc ->
      Enum.reduce(0..size-1, acc, fn y, iacc -> Map.put(iacc, {x, y}, ".") end)
    end)
  end

  def make_graph(grid) do
    Enum.reduce(grid, Graph.new(), fn {k, _v}, acc ->
      neighbors = Grid.get_neighbors(grid, k)
      neighbors
      |> Enum.filter(fn {_k, v} -> v == "." end)
      |> Enum.reduce(acc, fn {n, _v}, acc -> Graph.add_edge(acc, k, n) end)
    end)
  end

  def path_exists(input, base_grid, grid_size, n) do
    slice = Enum.slice(input, 0..n-1)
    grid = Enum.reduce(slice, base_grid, fn [a, b], acc -> Map.put(acc, {a, b}, "#") end)
    graph = make_graph(grid)
    Graph.dijkstra(graph, {0, 0}, {grid_size-1, grid_size-1}) != nil
  end

  def bin_search(left, right, test) do
    cond do
      left == right -> left
      left + 1 == right -> left
      true ->
        med = div(right + left, 2)
        case apply(test, [med]) do
          true -> bin_search(med, right, test)
          false -> bin_search(left, med, test)
        end
    end
  end

  def solve(test \\ false) do
    input = get_input(test)

    {grid_size, p1_limit} = case test do
      true -> {7, 12}
      false -> {71, 1024}
    end

    first_1024 = Enum.slice(input, 0..p1_limit-1)
    base_grid = init_grid(grid_size)
    grid = Enum.reduce(first_1024, base_grid, fn [a, b], acc -> Map.put(acc, {a, b}, "#") end)
    graph = make_graph(grid)
    part1 = Graph.dijkstra(graph, {0, 0}, {grid_size-1, grid_size-1})
    |> Enum.count()
    |> then(fn n -> n - 1 end)

    part2 = bin_search(p1_limit+1, length(input), fn n -> path_exists(input, base_grid, grid_size, n) end)
    |> then(fn n -> Enum.at(input, n) end)
    |> then(fn [a, b] -> "#{a},#{b}" end)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day18.solve()
