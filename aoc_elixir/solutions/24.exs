defmodule Day24 do
  def get_input(test \\ false) do
    filename = case test do
      true -> "test_input/24.3.txt"
      false -> "input/24.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename, "\n\n")
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def get_start_vals(gates) do
    gates
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [gate, val] -> {String.replace(gate, ":", ""), String.to_integer(val)} end)
    |> Map.new()
  end

  def get_gate_graphs(gate_ops) do
    gate_ops
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce({Graph.new(type: :directed), Graph.new(type: :directed), Map.new()}, fn [in1, op, in2, _, out], {ograph, vgraph, oacc} ->
      updated_ograph = ograph
      |> Graph.add_edge(in1, out)
      |> Graph.add_edge(in2, out)

      vgraph_vertex = {:gate, in1, in2, op, out}

      updated_vgraph = vgraph
      |> Graph.add_edge(in1, vgraph_vertex)
      |> Graph.add_edge(in2, vgraph_vertex)
      |> Graph.add_edge(vgraph_vertex, out)
      |> Graph.label_vertex(vgraph_vertex, op)

      updated_ops = Map.put(oacc, {in1, in2, out}, op)

      {updated_ograph, updated_vgraph, updated_ops}
    end)
  end

  def to_dec(bitarr) do
    Enum.reverse(bitarr)
    |> Enum.reduce(0, fn n, acc -> 2 * acc + n end)
  end

  def get_from_map_prefix(val_map, prefix) do
    Enum.filter(val_map, fn {k, _v} -> String.starts_with?(k, prefix) end)
    |> Enum.sort_by(fn {k, _v} -> Utils.get_all_nums(k) |> hd() end)
    |> Enum.map(&elem(&1, 1))
    |> to_dec()
  end

  def part1(raw_start_gates, gate_ops) do
    starting_vals = get_start_vals(raw_start_gates)
    {ograph, _vgraph, ops} = get_gate_graphs(gate_ops)

    gate_vals = Graph.topsort(ograph)
    |> Enum.reduce(starting_vals, fn gate, acc ->
      val = case Map.get(acc, gate) do
        nil ->
          [in1_k, in2_k] = Graph.in_neighbors(ograph, gate)
          in1 = Map.get(acc, in1_k)
          in2 = Map.get(acc, in2_k)
          op = case Map.get(ops, {in1_k, in2_k, gate}) do
            nil -> Map.get(ops, {in2_k, in1_k, gate})
            v -> v
          end
          case op do
            "AND" -> Bitwise.band(in1, in2)
            "OR" -> Bitwise.bor(in1, in2)
            "XOR" -> Bitwise.bxor(in1, in2)
            nil -> raise("Bad gate: #{in1_k}, #{in2_k}, #{gate}")
          end
        v -> v
      end
      Map.put(acc, gate, val)
    end)

   res = gate_vals
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "z") end)
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
    |> to_dec()

    {res, gate_vals}
  end

  def swap(str, s1, s2) do
    str
    |> String.replace("-> #{s1}", "-> tmp")
    |> String.replace("-> #{s2}", "-> #{s1}")
    |> String.replace("-> tmp", "-> #{s2}")
  end

  def swap_ops(initial_gate_ops, swaps) do
    swaps
    |> Enum.reduce(initial_gate_ops, fn [o1, o2], acc -> swap(acc, o1, o2) end)
  end

  def part2(raw_start_gates, init_gate_ops, fixed \\ false, write \\ false) do
    swaps = Input.line_tokens("out/swaps.txt", ",")
    case fixed do
      false -> IO.puts("===BASE===")
      true -> IO.puts("===FIXED===")
    end
    gate_ops = case fixed do
      true -> swap_ops(init_gate_ops, swaps)
      false -> init_gate_ops
    end
    {_ograph, vgraph, _ops} = get_gate_graphs(gate_ops)

    if write do
      filename = case fixed do
        false -> "out/graph.dot"
        true -> "out/graph.fixed.dot"
      end
      vgraph
      |> Graph.to_dot()
      |> then(fn res ->
        case res do
          {:ok, dot} -> case File.write(filename, dot) do
            :ok -> IO.puts("Wrote dot file")
            {:error, term} -> raise("Failed to write: #{term}")
          end
          {:error, _} -> raise("Failed to get dot")
        end
      end)
    end

    # All zouts that aren't the final carry should be the result of an XOR
    Graph.vertices(vgraph)
    |> Enum.filter(fn v -> !is_tuple(v) end)
    |> Enum.filter(fn v -> String.starts_with?(v, "z") end)
    |> Enum.filter(fn v -> v != "z45" end)
    |> Enum.filter(fn v ->
      in_edge = Graph.in_neighbors(vgraph, v)
      |> hd()

      case in_edge do
        {_, _, _, "AND", _} -> IO.puts("Bad in: #{v}")
        {_, _, _, "OR", _} -> IO.puts("Bad in: #{v}")
        _ -> nil
      end
    end)

    # All ORs should be the proxy result of two ands and out to the carry variable
    Graph.vertices(vgraph)
    |> Enum.filter(fn v -> is_tuple(v) end)
    |> Enum.filter(fn v -> elem(v, 3) == "OR" end)
    |> Enum.filter(fn v ->
      in_edges = Graph.in_neighbors(vgraph, v)
      out_edges = Graph.out_neighbors(vgraph, v)
      in_in_edges = Enum.flat_map(in_edges, fn e -> Graph.in_neighbors(vgraph, e) end)
      |> Enum.filter(fn t -> elem(t, 3) == "AND" end)

      cond do
        Enum.count(in_edges) != 2 -> IO.puts("Bad OR: #{v}")
        Enum.count(out_edges) != 1 -> IO.puts("Bad OR: #{v}")
        Enum.count(in_in_edges) != 2 -> IO.inspect(v, label: "Bad OR")
        true -> nil
      end
    end)

    {_, gate_vals} = part1(raw_start_gates, gate_ops)
    x = get_from_map_prefix(gate_vals, "x")
    |> IO.inspect(label: :x)
    y = get_from_map_prefix(gate_vals, "y")
    |> IO.inspect(label: :y)
    actual = get_from_map_prefix(gate_vals, "z")
    IO.puts("  actual: #{actual} | #{Integer.to_string(actual, 2)}")

    expected = x + y
    IO.puts("expected: #{expected} | #{Integer.to_string(expected, 2)}")

    res = List.flatten(swaps)
    |> Enum.sort()
    |> Enum.join(",")

    cond do
      !fixed -> nil
      actual == expected -> res
      true -> raise("Incorrect swaps")
    end
  end

  def solve(test, fixed \\ false, write \\ false) do
    [raw_start_gates, raw_gate_ops] = get_input(test)
    {part1, _} = part1(raw_start_gates, raw_gate_ops)
    part2 = part2(raw_start_gates, raw_gate_ops, fixed, write)

    IO.puts("===")
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day24.solve(false, true, false)
