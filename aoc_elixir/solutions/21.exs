defmodule Day21 do
  use Memoize

  def get_input(test \\ false) do
    filename = case test do
      false -> "input/21.txt"
      true -> "test_input/21.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  @valid_num_pad ["7", "8", "9", "4", "5", "6", "1", "2", "3", "0", "A"]
  |> MapSet.new()
  @valid_ctrl_pad ["<", ">", "^", "v", "A"]
  |> MapSet.new()
  @num_dirs [
    {"<", {-1, 0}},
    {"^", {0, -1}},
    {"v", {0, 1}},
    {">", {1, 0}},
  ]
  @ctrl_dirs [
    {"<", {-1, 0}},
    {"v", {0, 1}},
    {"^", {0, -1}},
    {">", {1, 0}}
  ]

  def get_paths(grid, start, type) do
    queue = [start]
    paths = %{elem(start, 1) => []}
    {valid_set, dirs} = case type do
      :num_pad -> {@valid_num_pad, @num_dirs}
      :ctrl_pad -> {@valid_ctrl_pad, @ctrl_dirs}
    end
    path_map = Enum.reduce_while(0..12, {queue, paths}, fn _n, {queue, paths} ->
      case queue do
        [] -> {:halt, paths}
        q ->
          next = hd(q)
          {{x, y}, v} = next
          path_so_far = Map.get(paths, v)
          neighbors = dirs
          |> Enum.map(fn {dir, {dx, dy}} -> {dir, {x + dx, y + dy}} end)
          |> Enum.map(fn {dir, n} ->
            nval = Map.get(grid, n)
            {dir, n, nval}
          end)
          |> Enum.filter(fn {_, _, nval} -> MapSet.member?(valid_set, nval) and !Map.has_key?(paths, nval) end)

          res = Enum.reduce(neighbors, {tl(queue), paths}, fn {dir, ncoords, nval}, {qacc, pacc} ->
            updated_queue = qacc ++ [{ncoords, nval}]
            updated_paths = Map.put(pacc, nval, path_so_far ++ [dir])
            {updated_queue, updated_paths}
          end)
          {:cont, res}
      end
    end)

    Enum.map(path_map, fn {k, path} -> {{elem(start, 1), k}, path} end)
    |> Map.new()
  end

  def get_paths(grid, type) do
    valid_set = case type do
      :num_pad -> @valid_num_pad
      :ctrl_pad -> @valid_ctrl_pad
    end
    grid
    |> Enum.filter(fn {_, v} -> MapSet.member?(valid_set, v) end)
    |> Enum.reduce(%{}, fn g_start, acc ->
      with_start = get_paths(grid, g_start, type)
      Map.merge(with_start, acc)
    end)
  end

  def insert_as(l) do
    Enum.join(l, "A")
    |> String.graphemes()
    |> then(fn l -> l ++ ["A"] end)
  end

  defmemo get_transformed_length(ctrl_paths, str_arr, depth) do
    case depth do
      0 -> Enum.count(str_arr)
      n ->
        padded = ["A" | str_arr]
        new_str = Enum.zip(padded, tl(padded))
        |> Enum.map(fn {c1, c2} -> Map.get(ctrl_paths, {c1, c2}) end)
        |> insert_as()
        get_transformed_length(ctrl_paths, new_str, n - 1)
    end
  end

  def run_nested_bots(input, num_paths, ctrl_paths, part2 \\ true) do
    num_bots = case part2 do
      false -> 2
      true -> 25
    end

    first_seq = ["A"] ++ String.graphemes(input)
    first_ctrl = Enum.zip(first_seq, tl(first_seq))
    |> Enum.map(fn {c1, c2} -> Map.get(num_paths, {c1, c2}) end)
    |> insert_as()

    get_transformed_length(ctrl_paths, first_ctrl, num_bots)
  end

  def solve(test \\ false) do
    num_pad = "789\n456\n123\n.0A"
    num_pad_paths = num_pad
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()
    |> then(&get_paths(&1, :num_pad))
    |> Map.put({"0", "7"}, ["^", "^", "^", "<"])
    |> Map.put({"0", "4"}, ["^", "^", "<"])
    |> Map.put({"A", "7"}, ["^", "^", "^", "<", "<"])
    |> Map.put({"A", "4"}, ["^", "^", "<", "<"])
    |> Map.put({"A", "1"}, ["^", "<", "<"])
    |> Map.put({"1", "A"}, [">", ">", "v"])
    |> Map.put({"4", "0"}, [">", "v", "v"])
    |> Map.put({"4", "A"}, [">", ">", "v", "v"])
    |> Map.put({"7", "0"}, [">", "v", "v", "v"])
    |> Map.put({"7", "A"}, [">", ">", "v", "v", "v"])
    |> tap(fn m ->
      m
      |> Enum.sort()
      # Enum.filter(m, fn {{c1, c2}, _r} -> c1 == "A" or c2 == "A" end)
      # |> IO.inspect(limit: :infinity)
    end)

    ctrl_pad = " ^A\n<v>"
    ctrl_pad_paths = ctrl_pad
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()
    |> then(&get_paths(&1, :ctrl_pad))
    |> Map.put({"A", "<"}, ["v", "<", "<"])
    |> Map.put({"<", "A"}, [">", ">", "^"])
    |> tap(fn m ->
      m
      |> Enum.sort()
      |> IO.inspect(limit: :infinity)
    end)

    input = get_input(test)
    part1 = Enum.map(input, fn i ->
      num = Utils.get_all_nums(i) |> hd()
      length_buttons = run_nested_bots(i, num_pad_paths, ctrl_pad_paths, false)
      {length_buttons, num} |> IO.inspect()
      num * length_buttons
    end)
    |> Enum.sum()
    IO.puts("Part 1: #{part1}")

    part2 = Enum.map(input, fn i ->
      num = Utils.get_all_nums(i) |> hd()
      length_buttons = run_nested_bots(i, num_pad_paths, ctrl_pad_paths, true)
      {length_buttons, num} |> IO.inspect()
      num * length_buttons
    end)
    |> Enum.sum()
    IO.puts("Part 2: #{part2}")
  end
end

Day21.solve()
