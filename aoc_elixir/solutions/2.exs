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
    zipped = Enum.zip(line, tl(line))
    diffs = Enum.map(zipped, fn {n1, n2} -> n2 - n1 end)
    gap_diffs = Enum.all?(diffs, fn n -> 1 <= abs(n) and abs(n) <= 3 end)
    is_first_positive = hd(diffs) |> then(fn n -> n > 0 end)
    inc_diffs = Enum.all?(diffs, fn n -> n > 0 == is_first_positive end)
    gap_diffs and inc_diffs
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
    |> Enum.filter(fn i -> is_safe(i) end)
    |> length()
    part2 = input
    |> Enum.filter(fn i -> is_safe2(i) end)
    |> length()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day2.solve(false)
