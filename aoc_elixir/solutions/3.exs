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

  @mul_pattern ~r/mul\(([0-9]{1,3}),([0-9]{1,3})\)/
  @dos_pattern ~r/don't\(\).*?(do\(\)|$)/

  def run(str) do
    Regex.scan(@mul_pattern, str)
    |> Enum.map(fn [_, l, r] -> String.to_integer(l) * String.to_integer(r) end)
    |> Enum.sum()
  end

  def solve(test \\ false) do
    input = get_input(test)

    part1 = run(input)

    cleaned = Regex.replace(@dos_pattern, input, "")
    part2 = run(cleaned)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day3.solve()
