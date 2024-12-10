defmodule Day10 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/10.txt"
      true -> "test_input/10.2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def solve(test \\ false) do
    grid = get_input(test)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn r -> Enum.map(r, &String.to_integer/1) end)
    |> Grid.make_grid()

    graph = Enum.reduce(grid, Graph.new(), fn base_node, acc ->
      {k, v} = base_node
      Grid.get_neighbors(grid, k)
      |> Enum.filter(fn {_, nv} -> nv == v + 1 end)
      |> Enum.reduce(acc, fn neighbor, iacc ->
        Graph.add_edge(iacc, base_node, neighbor)
      end)
    end)

    zero_nodes = Enum.filter(grid, fn {_, v} -> v == 0 end)
    nine_nodes = MapSet.new(Enum.filter(grid, fn {_, v} -> v == 9 end))

    part1 = Enum.reduce(zero_nodes, 0, fn node, acc ->
      num_paths = Graph.reachable(graph, [node])
      |> Enum.filter(fn r -> MapSet.member?(nine_nodes, r) end)
      |> Enum.count()
      acc + num_paths
    end)

    part2 = Enum.reduce(zero_nodes, 0, fn zero, acc ->
      acc + Enum.reduce(nine_nodes, 0, fn nine, iacc ->
        num_paths = Graph.get_paths(graph, zero, nine)
        |> Enum.count()
        iacc + num_paths
      end)
    end)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day10.solve(false)
