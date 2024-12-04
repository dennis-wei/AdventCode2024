defmodule Day4 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/4.txt"
      true -> "test_input/4.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  @expected %{
    1 => "M",
    2 => "A",
    3 => "S"
  }

  @dirs [{-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}]

  def count_valid1(grid, {bx, by}) do
    Enum.count(@dirs, fn {dx, dy} ->
      Enum.all?(@expected, fn {n, c} ->
        Map.get(grid, {bx + n * dx, by + n * dy}) == c
      end)
    end)
  end

  @expected_cross MapSet.new(["S", "M"])

  def is_valid2(grid, {bx, by}) do
    ul = Map.get(grid, {bx - 1, by - 1})
    ur = Map.get(grid, {bx + 1, by - 1})
    dl = Map.get(grid, {bx - 1, by + 1})
    dr = Map.get(grid, {bx + 1, by + 1})

    c1 = MapSet.new([ul, dr])
    c2 = MapSet.new([ur, dl])
    c1 == c2 and c1 == @expected_cross
  end



  def solve(test \\ false) do
    grid = get_input(test)
    |> Enum.map(&String.graphemes/1)
    |> Grid.make_grid()

    x_cords = Enum.filter(grid, fn {_, val} -> val == "X" end)

    part1 = x_cords
    |> Enum.map(fn {xc, _} -> count_valid1(grid, xc) end)
    |> Enum.sum()

    a_cords = Enum.filter(grid, fn {_, val} -> val == "A" end)
    part2 = a_cords
    |> Enum.filter(fn {ac, _} -> is_valid2(grid, ac) end)
    |> length()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day4.solve(false)
