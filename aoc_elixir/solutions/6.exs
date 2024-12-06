defmodule Day6 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/6.txt"
      true -> "test_input/6.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  @moves %{
    :up => {0, -1},
    :down => {0, 1},
    :left => {-1, 0},
    :right => {1, 0}
  }

  @turns %{
    :up => :right,
    :right => :down,
    :down => :left,
    :left => :up
  }

  def move(grid, {bx, by}, dir) do
    {dx, dy} = Map.get(@moves, dir)
    new_loc = {bx + dx, by + dy}
    case Map.get(grid, new_loc) do
      nil -> {:halt}
      "#"  -> {:cont, {bx, by}, Map.get(@turns, dir)}
      "." -> {:cont, new_loc, dir}
      "^" -> {:cont, new_loc, dir}
      c -> raise("unexpected character: " + c)
    end

  end

  def traverse(grid, start_location) do
    initial = {start_location, :up, MapSet.new([{start_location, :up}])}
    Enum.reduce_while(0..1000000, initial, fn _, {location, dir, visited} ->
      case move(grid, location, dir) do
        {:halt} -> {:halt, {:exit, Enum.map(visited, &elem(&1, 0)) |> MapSet.new()}}
        {:cont, nl, nd} ->
          cond do
            MapSet.member?(visited, {nl, nd}) -> {:halt, :loop}
            true -> {:cont, {nl, nd, MapSet.put(visited, {nl, nd})}}
          end
      end
    end)
  end

  def solve(test \\ false) do
    grid = get_input(test)
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()
    start_location = Enum.filter(grid, fn {_k, v} -> v == "^" end)
    |> hd
    |> elem(0)

    visited = traverse(grid, start_location)
    |> elem(1)

    part1 = Enum.count(visited)

    part2 = visited
    |> Enum.filter(fn v_loc -> v_loc != start_location end)
    |> Enum.map(fn v_loc -> Task.async(fn ->
      replaced = Map.put(grid, v_loc, "#")
      case traverse(replaced, start_location) do
        :loop -> true
        {:exit, _} -> false
      end
    end) end)
    |> Task.await_many(10000)
    |> Enum.filter(&Function.identity/1)
    |> Enum.count()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day6.solve(false)
