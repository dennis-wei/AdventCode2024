defmodule Day7 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/7.txt"
      true -> "test_input/7.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def concat(n1, n2) do
    String.to_integer(Integer.to_string(n1) <> Integer.to_string(n2))
  end

  def recurse(target, ops, acc, op, remaining) do
    [n | r] = remaining
    nacc = apply(op, [acc, n])
    cond do
      length(r) == 0 and nacc == target -> true
      length(r) == 0 -> false
      nacc > target -> false
      true -> Enum.any?(ops, fn next_op -> recurse(target, ops, nacc, next_op, r) end)
    end
  end

  def driver(target, ops, nums) do
    [first | rest] = nums
    Enum.any?(ops, fn op -> recurse(target, ops, first, op, rest) end)
  end

  def solve(test \\ false) do
    input = get_input(test)

    part1 = input
    |> Enum.filter(fn [target | nums] -> driver(target, [&+/2, &*/2], nums) end)
    |> Enum.map(fn [target | _] -> target end)
    |> Enum.sum()

    part2 = input
    |> Enum.filter(fn [target | nums] -> driver(target, [&+/2, &*/2, &concat/2], nums) end)
    |> Enum.map(fn [target | _] -> target end)
    |> Enum.sum()

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day7.solve()
