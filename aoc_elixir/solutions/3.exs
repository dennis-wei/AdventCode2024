defmodule Day3 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/3.txt"
      true -> "test_input/3.txt"
    end
    Input
      .raw(filename)
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def solve(test \\ false) do
    input = get_input(test)
    pattern = ~r/mul\(([0-9]{1,3}),([0-9]{1,3})\)|do\(\)|don't\(\)/
    ops = Regex.scan(pattern, input)
    |> Enum.map(fn args ->
      case args do
        ["do()"] -> :do
        ["don't()"] -> :dont
        [_, l, r] -> String.to_integer(l) * String.to_integer(r)
      end
    end)
    part1 = ops
    |> Enum.filter(fn op -> !is_atom(op) end)
    |> Enum.sum
    part2 = ops
    |> Enum.reduce({true, 0}, fn op, {is_on, acc} ->
      case op do
        :do -> {true, acc}
        :dont -> {false, acc}
        n when is_integer(n) and is_on -> {true, acc + n}
        n when is_integer(n) and not(is_on) -> {false, acc}
      end
    end)
    |> elem(1)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day3.solve()
