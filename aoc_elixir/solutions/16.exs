defmodule Day16 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/16.txt"
      true -> "test_input/16.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  @dirs [:left, :right, :up, :down]

  @rotate_costs %{
    :right => [{:up, 1000}, {:down, 1000}, {:left, 2000}],
    :left => [{:up, 1000}, {:down, 1000}, {:right, 2000}],
    :up => [{:left, 1000}, {:right, 1000}, {:down, 2000}],
    :down => [{:left, 1000}, {:right, 1000}, {:up, 2000}]
  }

  @dir_diffs %{
    :up => {0, -1},
    :down => {0, 1},
    :left => {-1, 0},
    :right => {1, 0}
  }

  def make_graph(grid) do
    Enum.reduce(grid, Graph.new(type: :directed), fn {k, v}, acc ->
      {x, y} = k
      cond do
        v == "#" -> acc
        true ->
          with_rotates = Enum.reduce(@dirs, acc, fn dir, iacc1 ->
            Map.get(@rotate_costs, dir)
            |> Enum.reduce(iacc1, fn {new_dir, cost}, iacc2 ->
              Graph.add_edge(iacc2, {k, dir}, {k, new_dir}, weight: cost)
            end)
          end)
          Enum.reduce(@dir_diffs, with_rotates, fn {dir, {dx, dy}}, iacc ->
            new_loc = {x + dx, y + dy}
            case Map.get(grid, new_loc) do
              "." -> Graph.add_edge(iacc, {k, dir}, {new_loc, dir})
              "S" -> Graph.add_edge(iacc, {k, dir}, {new_loc, dir})
              "E" -> Graph.add_edge(iacc, {k, dir}, {new_loc, dir})
              _ -> iacc
            end
          end)
      end
    end)
  end

  def multi_dijkstra(graph, source, target) do
    prio_queue = PriorityQueue.new()
    |> PriorityQueue.push(source, 0)
    dists = Enum.map(Graph.vertices(graph), fn v -> {v, :inf} end)
    |> Map.new()
    |> Map.put(source, 0)

    {p1, tree} = Enum.reduce_while(0..1000000, {prio_queue, dists, Graph.new()}, fn _, {prio_queue, dists, tree} ->
      {lowest, rem_queue} = PriorityQueue.pop(prio_queue)
      case lowest do
        :empty -> {:halt, {Map.get(dists, target), tree}}
        {:value, node} ->
          dist_so_far = Map.get(dists, node)
          neighbors = Graph.out_edges(graph, node)
          nacc = Enum.reduce(neighbors, {rem_queue, dists, tree}, fn edge, {queue, dists, tree} ->
            v1 = edge.v1
            v2 = edge.v2
            weight = edge.weight

            new_dist = dist_so_far + weight
            prior_dist = Map.get(dists, v2)
            cond do
              new_dist < prior_dist -> {PriorityQueue.push(queue, v2, new_dist), Map.put(dists, v2, new_dist), Graph.add_edge(tree, v1, v2)}
              new_dist == prior_dist -> {queue, dists, Graph.add_edge(tree, v1, v2)}
              true -> {queue, dists, tree}
            end
          end)
          {:cont, nacc}
      end
    end)

    p2 = Graph.get_paths(tree, source, target)
    |> Enum.reduce(MapSet.new(), fn path, acc ->
      Enum.reduce(path, acc, fn {c, _dir}, iacc ->
        MapSet.put(iacc, c)
      end)
    end)
    |> Enum.count()

    {p1, p2}
  end

  def solve(test \\ false) do
    grid = get_input(test)
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()

    end_dir = case test do
      true -> :up
      false -> :right
    end

    start_coord = Enum.filter(grid, fn {_k, v} -> v == "S" end)
    |> hd()
    |> elem(0)
    end_coord = Enum.filter(grid, fn {_k, v} -> v == "E" end)
    |> hd()
    |> elem(0)
    graph = make_graph(grid)
    {part1, part2} = multi_dijkstra(graph, {start_coord, :right}, {end_coord, end_dir})

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day16.solve()
