defmodule Day5 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/5.txt"
      true -> "test_input/5.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename, "\n\n")
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def is_valid(pages, rules) do
    as_map = Enum.with_index(pages)
    |> Enum.reduce(%{}, fn {p, idx}, acc -> Map.put(acc, p, idx) end)
    Enum.all?(rules, fn [l, r] ->
      lidx = Map.get(as_map, l)
      ridx = Map.get(as_map, r)
      cond do
        lidx == nil or ridx == nil -> true
        true -> lidx < ridx
      end
    end)
  end

  def get_rules_graph(rules) do
    Enum.reduce(rules, Graph.new(), fn [l, r], g ->
      Graph.add_edge(g, l, r)
    end)
    |> Graph.topsort()
    |> case do
      false -> raise("Cyclical rules dependencies")
      l -> l
    end
  end

  def sort_pages(pages, rules) do
    pages_set = MapSet.new(pages)
    filtered_rules = rules
    |> Enum.filter(fn [l, r] -> MapSet.member?(pages_set, l) and MapSet.member?(pages_set, r) end)
    get_rules_graph(filtered_rules)
  end

  def get_mid(l) do
    midx = l
    |> length()
    |> div(2)
    Enum.at(l, midx)
  end

  def solve(test \\ false) do
    [raw_rules, raw_pages] = get_input(test)
    |> Enum.map(&String.split(&1, "\n"))

    rules = raw_rules
    |> Enum.map(&Utils.get_all_nums/1)

    pages = raw_pages
    |> Enum.map(&Utils.get_all_nums/1)

    part1 = pages
    |> Enum.filter(fn p -> is_valid(p, rules) end)
    |> Enum.map(&get_mid/1)
    |> Enum.sum()

    incorrect = pages
    |> Enum.filter(fn p -> !is_valid(p, rules) end)
    part2 = incorrect
    |> Enum.map(fn p -> sort_pages(p, rules) end)
    |> Enum.map(&get_mid/1)
    |> Enum.sum()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day5.solve(false)
