defmodule Day23 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/23.txt"
      true -> "test_input/23.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def solve(test \\ false) do
    graph = get_input(test)
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(Graph.new(type: :undirected), fn [c1, c2], acc ->
      Graph.add_edge(acc, c1, c2)
    end)

    cliques = Graph.cliques(graph)
    part1 = cliques
    |> Enum.filter(&Enum.count(&1) >= 3)
    |> Enum.flat_map(&Comb.combinations(&1, 3))
    |> Enum.filter(&Enum.any?(&1, fn c -> String.starts_with?(c, "t") end))
    |> Enum.map(&Enum.sort/1)
    |> MapSet.new()
    |> Enum.count()

    part2 = cliques
    |> Enum.max_by(&Enum.count/1)
    |> Enum.sort()
    |> Enum.join(",")

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day23.solve()
