defmodule Day13 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/13.txt"
      true -> "test_input/13.2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename, "\n\n")
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def get_solution([[ax, ay], [bx, by], [btx, bty]], part2 \\ false) do
    [tx, ty] = case part2 do
      false -> [btx, bty]
      true -> [btx + 10000000000000, bty + 10000000000000]
    end

    a = div(tx * by - ty * bx, ax * by - ay * bx)
    b = div(ty * ax - tx * ay, ax * by - ay * bx)

    a_rem = rem(tx * by - ty * bx, ax * by - ay * bx)
    b_rem = rem(ty * ax - tx * ay, ax * by - ay * bx)

    cond do
      a_rem == 0 and b_rem == 0 -> {a, b}
      true -> nil
    end
  end

  def solve(test \\ false) do
    inputs = get_input(test)
    |> Enum.chunk_every(4)
    |> Enum.map(&Enum.slice(&1, 0..2))

    part1 = Enum.map(inputs, &get_solution/1)
    |> Enum.filter(fn s -> s != nil end)
    |> Enum.filter(fn {a, b} -> a >= 0 and b >=0  end)
    |> Enum.filter(fn {a, b} -> a <= 100 and b <= 100 end)
    |> Enum.map(fn {a, b} -> 3 * a + b end)
    |> Enum.sum()

    part2 = Enum.map(inputs, &get_solution(&1, true))
    |> Enum.filter(fn s -> s != nil end)
    |> Enum.filter(fn {a, b} -> a >= 0 and b >=0  end)
    |> Enum.map(fn {a, b} -> 3 * a + b end)
    |> Enum.sum()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day13.solve(false)
