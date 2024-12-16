defmodule Day15 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/15.txt"
      true -> "test_input/15.2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename, "\n\n")
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def make_grid(raw_grid) do
    raw_grid
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()
  end

  @char_diffs %{
    "^" => {0, -1},
    ">" => {1, 0},
    "<" => {-1, 0},
    "v" => {0, 1},
  }

  def get_op1(grid, {bx, by}, {dx, dy}) do
    Enum.reduce_while(1..1000, nil, fn n, _acc ->
      proj_loc = {bx + n * dx, by + n * dy}
      grid_item = Map.get(grid, proj_loc)
      cond do
        n == 1 and grid_item == "." -> {:halt, {:move, proj_loc}}
        grid_item == "." -> {:halt, {:push, proj_loc, {bx + dx, by + dy}}}
        grid_item == "#" -> {:halt, {:noop}}
        true -> {:cont, nil}
      end
    end)
  end

  def iter1(grid, bot_loc, c) do
   diff = Map.get(@char_diffs, c)
   case get_op1(grid, bot_loc, diff) do
     {:move, new_bot_loc} ->
      new_grid = grid
      |> Map.put(new_bot_loc, "@")
      |> Map.put(bot_loc, ".")
      {new_grid, new_bot_loc}
     {:push, swap_loc, new_bot_loc} ->
      new_grid = grid
      |> Map.put(swap_loc, "O")
      |> Map.put(new_bot_loc, "@")
      |> Map.put(bot_loc, ".")
      {new_grid, new_bot_loc}
     {:noop} -> {grid, bot_loc}
   end
  end

  def replace_chars(s) do
    s
    |> String.replace("#", "##")
    |> String.replace("O", "[]")
    |> String.replace(".", "..")
    |> String.replace("@", "@.")
  end

  def get_op2(grid, {dx, dy}, prior_checks, to_move) do
    checks = Enum.map(prior_checks, fn {bx, by} ->
      coords = {bx + dx, by + dy}
      val = Map.get(grid, coords)
      {coords, val}
    end)
    check_coords = Enum.map(checks, fn {k, _v} -> k end)
    cond do
      Enum.all?(checks, fn {_, c} -> c == "." end) -> {:move, to_move}
      Enum.any?(checks, fn {_, c} -> c == "#" end) -> {:noop}
      dy == 0 -> get_op2(grid, {dx, dy}, check_coords, checks ++ to_move)
      dx == 0 ->
        check_coords_set = MapSet.new(check_coords)
        with_ends = checks
        |> Enum.filter(fn {_c, v} -> v == "[" or v == "]" end)
        |> Enum.flat_map(fn {{cx, cy}, v} ->
          cond do
            v == "[" and !MapSet.member?(check_coords_set, {cx + 1, cy}) -> [{{cx, cy}, "["}, {{cx + 1, cy}, "]"}]
            v == "]" and !MapSet.member?(check_coords_set, {cx - 1, cy}) -> [{{cx, cy}, "]"}, {{cx - 1, cy}, "["}]
            true -> [{{cx, cy}, v}]
          end
        end)
        with_ends_coords = Enum.map(with_ends, fn {k, _v} -> k end)
        get_op2(grid, {dx, dy}, with_ends_coords, with_ends ++ to_move)
    end
  end

  def iter2(grid, {bx, by}, c) do
   {dx, dy} = Map.get(@char_diffs, c)
   op = get_op2(grid, {dx, dy}, [{bx, by}], [{{bx, by}, "@"}])
   case op do
     {:noop} -> {grid, {bx, by}}
     {:move, to_move} ->
      updated_grid = Enum.reduce(to_move, grid, fn {{mx, my}, v}, grid ->
        moved_box = {mx + dx, my + dy}
        grid
        |> Map.put(moved_box, v)
        |> Map.put({mx, my}, ".")
      end)
      {updated_grid, {bx + dx, by + dy}}
   end

  end

  def solve(test \\ false) do
    [raw_grid, raw_inputs] = get_input(test)
    inputs = raw_inputs
    |> String.replace("\n", "")
    |> then(&String.graphemes/1)

    grid1 = make_grid(raw_grid)
    bot_start1 = Enum.filter(grid1, fn {_k, v} -> v == "@" end)
    |> Enum.map(&elem(&1, 0))
    |> hd
    part1_resolved_grid = Enum.reduce(inputs, {grid1, bot_start1}, fn c, {grid, bot_loc} -> iter1(grid, bot_loc, c) end)
    |> elem(0)
    part1 = part1_resolved_grid
    |> Enum.filter(fn {_k, v} -> v == "O" end)
    |> Enum.map(fn {{x, y}, _v} -> x + 100 * y end)
    |> Enum.sum()

    grid2 = raw_grid
    |> then(&replace_chars/1)
    |> make_grid()
    bot_start2 = Enum.filter(grid2, fn {_k, v} -> v == "@" end)
    |> Enum.map(&elem(&1, 0))
    |> hd
    part2_resolved_grid = Enum.reduce(inputs, {grid2, bot_start2}, fn c, {grid, bot_loc} -> iter2(grid, bot_loc, c) end)
    |> elem(0)
    part2 = part2_resolved_grid
    |> Enum.filter(fn {_k, v} -> v == "[" end)
    |> Enum.map(fn {{x, y}, _v} -> x + 100 * y end)
    |> Enum.sum()

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day15.solve()
