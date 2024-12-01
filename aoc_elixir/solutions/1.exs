defmodule Day1 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/1.txt"
      true -> "test_input/1.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def solve(test \\ false) do
    input = get_input(test)
    {left, right} = input
    |> Enum.map(fn [l, _, _, r] -> [Integer.parse(l) |> elem(0), Integer.parse(r) |> elem(0)] end)
    |> Enum.reduce({[], []}, fn [l, r], {lacc, racc} -> {[l | lacc], [r | racc]} end)
    |> then(fn {l, r} -> {Enum.sort(l), Enum.sort(r)} end)
    |> IO.inspect
    part1 = Enum.zip_reduce(left, right, 0, fn l, r, acc -> acc + abs(l - r) end)

    right_counts = Enum.reduce(right, %{}, fn elem, acc -> Map.update(acc, elem, 1, fn n -> n + 1 end) end)
    part2 = Enum.reduce(left, 0, fn elem, acc -> acc + Map.get(right_counts, elem, 0) * elem end)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day1.solve()
