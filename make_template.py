import sys

day = sys.argv[1]
elixir_template = f"""

defmodule Day{day} do
  def get_input(test \\\\ false) do
    filename = case test do
      false -> "input/{day}.txt"
      true -> "test_input/{day}.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def solve(test \\\\ false) do
    input = get_input(test)
    part1 = nil
    part2 = nil
    IO.puts("Part 1: #{{part1}}")
    IO.puts("Part 2: #{{part2}}")
  end
end

Day{day}.solve()""".strip()

with open(f"aoc_elixir/solutions/{day}.exs", 'w') as f:
    f.write(elixir_template)