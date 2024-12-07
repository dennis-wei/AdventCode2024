defmodule Day7 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/7.txt"
      true -> "test_input/7.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def concat(n1, n2) do
    String.to_integer(Integer.to_string(n1) <> Integer.to_string(n2))
  end

  def get_possibilities(n_ops, part2 \\ false) do
    ops = case part2 do
      false -> [&+/2, &*/2]
      true -> [&+/2, &*/2, &concat/2]
    end
    Enum.reduce(2..n_ops, Enum.map(ops, fn op -> [op] end), fn _, acc ->
      Comb.cartesian_product(acc, ops)
      |> Enum.map(&List.flatten/1)
    end)
  end

  def is_valid(target, nums, ops) do
    [initial | remaining] = nums
    res = Enum.zip(remaining, ops)
    |> Enum.reduce_while(initial, fn {new_n, op}, acc ->
      res = apply(op, [acc, new_n])
      cond do
        res > target -> {:halt, false}
        true -> {:cont, res}
      end
    end)
    target == res
  end

  def is_possible(line, precom_possibilities) do
    [target | nums] = line
    num_ops = length(nums)
    possibilities = Map.get(precom_possibilities, num_ops)
    Enum.any?(possibilities, fn possibility -> is_valid(target, nums, possibility) end)
  end

  def solve(test \\ false) do
    input = get_input(test)
    max_ops = input
    |> Enum.map(&length/1)
    |> Enum.max()
    |> then(fn n -> n - 1 end)

    precomputed_combos1 = Enum.reduce(2..max_ops, %{}, fn n, acc -> Map.put(acc, n, get_possibilities(n)) end)
    part1 = Enum.map(input, fn i -> Task.async(fn -> {hd(i), is_possible(i, precomputed_combos1)} end) end)
    |> Task.await_many(30000)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()

    precomputed_combos2 = Enum.reduce(2..max_ops, %{}, fn n, acc -> Map.put(acc, n, get_possibilities(n, true)) end)
    part2 = Enum.map(input, fn i -> Task.async(fn -> {hd(i), is_possible(i, precomputed_combos2)} end) end)
    |> Task.await_many(30000)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day7.solve(false)
