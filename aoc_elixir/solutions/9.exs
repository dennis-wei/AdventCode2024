defmodule Day9 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/9.txt"
      true -> "test_input/9.txt"
    end
    Input
    .raw(filename)
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end



  def parse_input(int_list) do
    int_list
    |> Enum.chunk_every(2)
    |> Stream.with_index()
    |> Enum.map(fn {pairs, id} ->
      case pairs do
        [n1, n2] ->
          case n2 do
            0 -> [{:disk, {id, n1}}]
            n2 -> [{:disk, {id, n1}}, {:free, n2}]
          end
        [n] -> [{:disk, {id, n}}]
      end
    end)
    |> Enum.to_list()
    |> List.flatten()
end

def to_p1_repr(base_list) do
  as_list = base_list
    |> Enum.reduce([], fn {op, t}, acc ->
      case op do
        :disk ->
          {id, n} = t
          acc ++ List.duplicate(id, n)
        :free -> acc ++ List.duplicate(".", t)
      end
    end)

    as_map = as_list
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {c, idx}, acc -> Map.put(acc, idx, c) end)

    {as_map, length(as_list)}
  end

  def part1(parsed) do
    {m, len} = to_p1_repr(parsed)
    swapped = Enum.reduce_while(0..1000000, {0, len-1, %{}, 0}, fn _, {lidx, ridx, acc, acc_idx} ->
      left = Map.get(m, lidx)
      right = Map.get(m, ridx)
      cond do
        lidx >= ridx -> {:halt, Map.put(acc, lidx, Map.get(m, lidx))}
        left != "." -> {:cont, {lidx + 1, ridx, Map.put(acc, acc_idx, left), acc_idx + 1}}
        right == "." -> {:cont, {lidx, ridx - 1, acc, acc_idx}}
        left == "." and is_integer(right) -> {:cont, {lidx + 1, ridx - 1, Map.put(acc, acc_idx, right), acc_idx + 1}}
      end
    end)

    as_repr = Enum.reduce(0..len, [], fn n, acc ->
      case Map.get(swapped, n, ".") do
        "." -> acc
        n -> [n | acc]
      end
    end)
    |> Enum.reverse()

    as_repr
    |> Stream.with_index()
    |> Enum.reduce(0, fn {n, idx}, acc -> acc + n * idx end)
  end

  def to_p2_repr(base_list) do
    with_original_indices = Enum.reduce(base_list, {[], 0}, fn elem, {acc, idx_so_far} ->
      case elem do
        {:free, n} -> {[{:free, n, idx_so_far} | acc], idx_so_far + n}
        {:disk, {id, n}} -> {[{:disk, id, n, idx_so_far} | acc], idx_so_far + n}
      end
    end)
    |> elem(0)

    only_disk = Enum.filter(with_original_indices, fn e -> elem(e, 0) == :disk end)
    {Enum.reverse(with_original_indices), only_disk}
  end


  def part2(parsed) do
    {base_repr, reversed_disks} = to_p2_repr(parsed)
    filled = reversed_disks
    |> Enum.reduce(base_repr, fn {_, id, size, idx}, acc ->
      found = acc
      |> Enum.with_index()
      |> Enum.find(acc, fn {s, _nidx} ->
        elem(s, 0) == :free and elem(s, 1) >= size and elem(s, 2) < idx
      end)

      case found do
        {{_, n, free_idx}, slot_idx} ->
          new_nodes = cond do
            size < n -> [{:disk, id, size, free_idx}, {:free, n - size, free_idx + size}]
            true -> [{:disk, id, size, free_idx}]
          end

          with_new_nodes = Enum.slice(acc, 0..slot_idx-1) ++ new_nodes ++ Enum.slice(acc, slot_idx+1..100000)

          replace_idx = Enum.find_index(with_new_nodes, fn t -> t == {:disk, id, size, idx} end)
          free_replace = {:free, size, idx}
          List.replace_at(with_new_nodes, replace_idx, free_replace)
        _ -> acc
      end
    end)

    filled
    |> Enum.filter(fn t -> elem(t, 0) == :disk end)
    |> Enum.reduce(0, fn {_, id, size, start_idx}, acc ->
      acc + Enum.reduce(start_idx..start_idx + size - 1, 0, fn idx, iacc ->
        iacc + idx * id
      end)
    end)

  end

  def solve(test \\ false) do
    input = get_input(test)
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)

    parsed = parse_input(input)

    part1 = part1(parsed)
    part2 = part2(parsed)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day9.solve()
