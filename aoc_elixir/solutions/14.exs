defmodule Day14 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/14.txt"
      true -> "test_input/14.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def project([bx, by, vx, vy], num_steps, {gx, gy}) do
    x = Integer.mod(bx + num_steps * vx, gx)
    y = Integer.mod(by + num_steps * vy, gy)
    {x, y}
  end

  def get_quadrants(coords, {gx, gy}) do
    Enum.reduce(coords, [0, 0, 0, 0], fn {x, y}, [q1, q2, q3, q4] ->
      y_axis = div(gx, 2)
      x_axis = div(gy, 2)
      cond do
        x < y_axis and y < x_axis -> [q1 + 1, q2, q3, q4]
        x > y_axis and y < x_axis -> [q1, q2 + 1, q3, q4]
        x < y_axis and y > x_axis -> [q1, q2, q3 + 1, q4]
        x > y_axis and y > x_axis -> [q1, q2, q3, q4 + 1]
        true -> [q1, q2, q3, q4]
      end
    end)
  end

  def print_grid(coords, {gx, gy}) do
    repr = Enum.reduce(0..gy-1, "", fn y, acc ->
      row = Enum.reduce(0..gx-1, "", fn x, iacc ->
        case MapSet.member?(coords, {x, y}) do
          true -> iacc <> "#"
          false -> iacc <> " "
        end
      end)
      acc <> row <> "\n"
    end)

    IO.puts(repr)
  end

  def solve(test \\ false) do
    input = get_input(test)
    grid_size = case test do
      true -> {11, 7}
      false -> {101, 103}
    end

    part1 = input
    |> Enum.map(&project(&1, 100, grid_size))
    |> then(&get_quadrants(&1, grid_size))
    |> Enum.product()

    part2 = Enum.reduce_while(1..10000, nil, fn iter, _acc ->
      coords = Enum.map(input, &project(&1, iter, grid_size))
      as_set = MapSet.new(coords)
      cond do
        Enum.count(as_set) == Enum.count(input) ->
          print_grid(as_set, grid_size)
          {:halt, iter}
        true -> {:cont, nil}
      end
    end)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day14.solve()
