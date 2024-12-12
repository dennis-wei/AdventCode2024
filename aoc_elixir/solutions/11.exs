defmodule Day11 do
  use Memoize

  def get_input(test \\ false) do
    filename = case test do
      false -> "input/11.txt"
      true -> "test_input/11.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  defmemo handle_num(n, iters) do
    as_string = Integer.to_string(n)
    str_len = String.length(as_string)
    fl_div = Integer.floor_div(str_len, 2)

    cond do
      iters == 0 -> 1
      n == 0 -> handle_num(1, iters - 1)
      rem(str_len, 2) == 0 ->
        left = handle_num(String.to_integer(String.slice(as_string, 0..fl_div-1)), iters - 1)
        right = handle_num(String.to_integer(String.slice(as_string, fl_div..str_len)), iters - 1)
        left + right
      true -> handle_num(n * 2024, iters - 1)
    end
  end

  def iter(nums, iters) do
    Enum.map(nums, fn n -> handle_num(n, iters) end)
  end

  def handle_num(n) do
    as_string = Integer.to_string(n)
    str_len = String.length(as_string)
    fl_div = Integer.floor_div(str_len, 2)

    cond do
      n == 0 -> [1]
      rem(str_len, 2) == 0 ->
        left = String.to_integer(String.slice(as_string, 0..fl_div-1))
        right = String.to_integer(String.slice(as_string, fl_div..str_len))
        [left, right]
      true -> [n * 2024]
    end
  end

  def run_with_map(map) do
    Enum.reduce(map, %{}, fn {k, v}, acc ->
      handle_num(k)
      |> Enum.reduce(acc, fn res, acc ->
        Map.update(acc, res, v, fn pcnt -> pcnt + v end)
      end)
    end)
  end

  def iter_map(nums, iters) do
    cnts = Enum.reduce(nums, %{}, fn n, acc -> Map.update(acc, n, 1, fn c -> c + 1 end) end)
    Enum.reduce(1..iters, cnts, fn _, acc -> run_with_map(acc) end)
    |> Map.values()
  end

  def solve(test \\ false) do
    start = get_input(test) |> hd
    part1 = iter_map(start, 25)
    |> Enum.sum()
    part2 = iter_map(start, 75)
    |> Enum.sum()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day11.solve(false)
