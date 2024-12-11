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

  def solve(test \\ false) do
    start = get_input(test) |> hd
    part1 = iter(start, 25)
    |> Enum.sum()
    part2 = iter(start, 75)
    |> Enum.sum()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day11.solve(false)
