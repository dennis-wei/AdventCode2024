defmodule Day24 do
  def get_input(test \\ false, fixed \\ false) do
    filename = cond do
      test -> "test_input/24.3.txt"
      fixed -> "input/24.fixed.txt"
      true -> "input/24.txt"
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

  def part1(test) do
    [raw_start_gates, gate_ops] = get_input(test)
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

   gate_vals
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "z") end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.reduce(0, fn {_k, v}, acc -> acc * 2 + v end)
  end

  def part2(test \\ false, fixed \\ false, write \\ false) do
    case fixed do
      false -> IO.puts("===BASE===")
      true -> IO.puts("===FIXED===")
    end
    [_raw_start_gates, gate_ops] = get_input(test, fixed)
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
    |> Enum.filter(fn v ->
      in_edge = Graph.in_neighbors(vgraph, v)
      |> hd()

      case in_edge do
        {_, _, _, "AND", _} -> IO.puts("Bad in: #{v}")
        {_, _, _, "OR", _} -> IO.puts("Bad in: #{v}")
        _ -> nil
      end
    end)

    # All xin and yin should output to one XOR and one AND
    Graph.vertices(vgraph)
    |> Enum.filter(fn v -> !is_tuple(v) end)
    |> Enum.filter(fn v -> String.starts_with?(v, "y") or String.starts_with?(v, "x") end)
    |> Enum.filter(fn v ->
      out_edges = Graph.out_neighbors(vgraph, v)

      cond do
        Enum.count(out_edges) != 2 -> IO.puts("Bad out: #{v}")
        !Enum.all?(out_edges, fn e -> is_tuple(e) end) -> IO.puts("Bad out: #{v}")
        !(Enum.map(out_edges, fn e -> elem(e, 3) end) |> MapSet.new() == MapSet.new(["AND", "XOR"])) -> IO.puts("Bad out: #{v}")
        true -> nil
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

    Enum.sort(["REDACTED"])
    |> Enum.join(",")

  end

  def solve(test, fixed \\ false, write \\ false) do
    part1 = part1(test)
    part2 = part2(test, fixed, write)

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day24.solve(false, true, false)
