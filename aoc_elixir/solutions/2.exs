defmodule Day2 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/2.txt"
      true -> "test_input/2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def is_safe(line) do
    diffs = Enum.zip(line, tl(line))
    |> Enum.map(fn {n1, n2} -> n2 - n1 end)
    is_first_positive = hd(diffs) |> then(fn n -> n > 0 end)
    Enum.all?(diffs, fn n -> 1 <= abs(n) and abs(n) <= 3 and n > 0 == is_first_positive end)
  end

  def is_safe2(line) do
    cond do
      is_safe(line) -> true
      true -> Enum.any?(0..length(line)-1, fn n ->
        {_, remaining} = List.pop_at(line, n)
        is_safe(remaining)
      end)
    end
  end

  def solve(test \\ false) do
    input = get_input(test)

    part1 = input
    |> Enum.filter(&is_safe/1)
    |> length()
    part2 = input
    |> Enum.filter(&is_safe2/1)
    |> length()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day2.solve(false)
