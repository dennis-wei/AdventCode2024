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
  @num_dirs [
    {"<", {-1, 0}},
    {"^", {0, -1}},
    {"v", {0, 1}},
    {">", {1, 0}},
  ]

  @ctrl_paths [
    {{"<", "<"}, []},
    {{"<", ">"}, [">", ">"]},
    {{"<", "A"}, [">", ">", "^"]},
    {{"<", "^"}, [">", "^"]},
    {{"<", "v"}, [">"]},
    {{">", "<"}, ["<", "<"]},
    {{">", ">"}, []},
    {{">", "A"}, ["^"]},
    {{">", "^"}, ["<", "^"]},
    {{">", "v"}, ["<"]},
    {{"A", "<"}, ["v", "<", "<"]},
    {{"A", ">"}, ["v"]},
    {{"A", "A"}, []},
    {{"A", "^"}, ["<"]},
    {{"A", "v"}, ["<", "v"]},
    {{"^", "<"}, ["v", "<"]},
    {{"^", ">"}, ["v", ">"]},
    {{"^", "A"}, [">"]},
    {{"^", "^"}, []},
    {{"^", "v"}, ["v"]},
    {{"v", "<"}, ["<"]},
    {{"v", ">"}, [">"]},
    {{"v", "A"}, ["^", ">"]},
    {{"v", "^"}, ["^"]},
    {{"v", "v"}, []}
  ]
  |> Enum.map(fn {k, v} -> {k, v ++ ["A"]} end)
  |> Map.new()

  def get_paths(grid, start) do
    queue = [start]
    paths = %{elem(start, 1) => []}
    path_map = Enum.reduce_while(0..12, {queue, paths}, fn _n, {queue, paths} ->
      case queue do
        [] -> {:halt, paths}
        q ->
          next = hd(q)
          {{x, y}, v} = next
          path_so_far = Map.get(paths, v)
          neighbors = @num_dirs
          |> Enum.map(fn {dir, {dx, dy}} -> {dir, {x + dx, y + dy}} end)
          |> Enum.map(fn {dir, n} ->
            nval = Map.get(grid, n)
            {dir, n, nval}
          end)
          |> Enum.filter(fn {_, _, nval} -> MapSet.member?(@valid_num_pad, nval) and !Map.has_key?(paths, nval) end)

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

  def get_paths(grid) do
    grid
    |> Enum.filter(fn {_, v} -> MapSet.member?(@valid_num_pad, v) end)
    |> Enum.reduce(%{}, fn g_start, acc ->
      with_start = get_paths(grid, g_start)
      Map.merge(with_start, acc)
    end)
  end

  defmemo get_transformed_length(str_arr, depth) do
    case depth do
      0 -> Enum.count(str_arr)
      n ->
        padded = ["A" | str_arr]
        Enum.zip(padded, tl(padded))
        |> Enum.map(fn {c1, c2} -> Map.get(@ctrl_paths, {c1, c2}) end)
        |> Enum.map(fn arr -> get_transformed_length(arr, n-1) end)
        |> Enum.sum()
    end
  end

  def run_nested_bots(input, num_paths, part2 \\ true) do
    num_bots = case part2 do
      false -> 2
      true -> 25
    end

    first_seq = ["A"] ++ String.graphemes(input)
    first_ctrl = Enum.zip(first_seq, tl(first_seq))
    |> Enum.flat_map(fn {c1, c2} -> Map.get(num_paths, {c1, c2}) ++ ["A"] end)

    get_transformed_length(first_ctrl, num_bots)
  end

  def solve(test \\ false) do
    num_pad = "789\n456\n123\n.0A"
    num_pad_paths = num_pad
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()
    |> get_paths()
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

    input = get_input(test)
    part1 = Enum.map(input, fn i ->
      num = Utils.get_all_nums(i) |> hd()
      length_buttons = run_nested_bots(i, num_pad_paths, false)
      num * length_buttons
    end)
    |> Enum.sum()
    IO.puts("Part 1: #{part1}")

    part2 = Enum.map(input, fn i ->
      num = Utils.get_all_nums(i) |> hd()
      length_buttons = run_nested_bots(i, num_pad_paths, true)
      num * length_buttons
    end)
    |> Enum.sum()
    IO.puts("Part 2: #{part2}")
  end
end

Day21.solve()
