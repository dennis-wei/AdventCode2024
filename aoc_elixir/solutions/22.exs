defmodule Day22 do
  import Bitwise
  use Memoize

  def get_input(test \\ false) do
    filename = case test do
      false -> "input/22.txt"
      true -> "test_input/22.3.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
     .ints_in_lines(filename)
  end

  @base 16777216

  defmemo iter(n) do
    s1 = rem(bxor(n * 64, n), @base)
    s2 = rem(bxor(div(s1, 32), s1), @base)
    rem(bxor(s2 * 2048, s2), @base)
  end

  def iter_run(start, num_iters) do
    Enum.reduce(1..num_iters, {start, []}, fn _n, {acc, diffs} ->
      res = iter(acc)
      diff = rem(res, 10) - rem(acc, 10)
      {res, [{rem(res, 10), diff} | diffs]}
    end)
  end

  def get_seq_map(diffs) do
    Enum.reduce(diffs, {%{}, []}, fn {price, diff}, {acc, last4} ->
      updated_last4 = Enum.take(last4, -3) ++ [diff]
      cond do
        Enum.count(updated_last4) < 4 -> {acc, updated_last4}
        Map.has_key?(acc, updated_last4) -> {acc, updated_last4}
        true -> {Map.put(acc, updated_last4, price), updated_last4}
      end
    end)
    |> elem(0)
  end

  def solve(test \\ false) do
    base_nums = get_input(test)
    |> Enum.map(&hd/1)

    {part1, diffs} = Enum.reduce(base_nums, {0, []}, fn n, {p1_acc, seq_acc} ->
      {secret, diffs} = iter_run(n, 2000)
      {p1_acc + secret, [Enum.reverse(diffs) | seq_acc]}
    end)

    seq_maps = Enum.map(diffs, fn diff_list -> get_seq_map(diff_list) end)
    merged = Enum.reduce(seq_maps, %{}, fn m, acc ->
      Map.merge(m, acc, fn _k, v1, v2 -> v1 + v2 end)
    end)
    part2 = merged
    |> Map.values()
    |> Enum.max()

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day22.solve()
