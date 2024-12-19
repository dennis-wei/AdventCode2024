defmodule Day19 do
  use Memoize

  def get_input(test \\ false) do
    filename = case test do
      false -> "input/19.txt"
      true -> "test_input/19.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename, "\n\n")
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  defmemo get_num_possible(target, patterns) do
    cond do
      target == "" -> 1
      true ->
        patterns
        |> Enum.filter(fn pattern -> String.starts_with?(target, pattern) end)
        |> Enum.map(fn pattern -> String.replace_prefix(target, pattern, "") end)
        |> Enum.map(fn remaining -> get_num_possible(remaining, patterns) end)
        |> Enum.sum()
    end
  end

  def solve(test \\ false) do
    [raw_patterns, raw_targets] = get_input(test)
    patterns = String.split(raw_patterns, ", ")
    targets = String.split(raw_targets, "\n")
    num_possible = Enum.map(targets, &get_num_possible(&1, patterns))
    part1 = num_possible
    |> Enum.filter(fn n -> n != 0 end)
    |> Enum.count()
    part2 = Enum.sum(num_possible)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day19.solve()
