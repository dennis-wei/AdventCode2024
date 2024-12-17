defmodule State do
  @enforce_keys [:a]
  defstruct [:a, b: 0, c: 0, ip: 0, output: []]
end

defmodule Day17 do
  import Bitwise

  def get_input(test \\ false) do
    filename = case test do
      false -> "input/17.txt"
      true -> "test_input/17.2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      .ints_in_lines(filename)
  end

  def combo_operand(state, operand) do
    case operand do
      4 -> state.a
      5 -> state.b
      6 -> state.c
      7 -> raise "encountered 7"
      n when n <= 3 -> n
      _n -> raise "unexpected operand"
    end
  end

  def get_diff(state, opcode, operand) do
    case opcode do
      0 ->
        divisor = 2 ** combo_operand(state, operand)
        res = div(state.a, divisor)
        {:set, :a, res}
      1 -> {:set, :b, bxor(state.b, operand)}
      2 -> {:set, :b, Integer.mod(combo_operand(state, operand), 8)}
      3 ->
        case state.a do
          0 -> {:set, :a, 0}
          _n -> {:jmp, operand}
        end
      4 -> {:set, :b, bxor(state.b, state.c)}
      5 -> {:out, Integer.mod(combo_operand(state, operand), 8)}
      6 ->
        divisor = 2 ** combo_operand(state, operand)
        res = div(state.a, divisor)
        {:set, :b, res}
      7 ->
        divisor = 2 ** combo_operand(state, operand)
        res = div(state.a, divisor)
        {:set, :c, res}
      _n -> raise "unexpected opcode"
    end
  end

  def part1(a_start, program) do
    start_state = %State{a: a_start}
    Enum.reduce_while(0..1000000, start_state, fn _, state ->
      cond do
        state.ip >= length(program) - 1 -> {:halt, state.output}
        true ->
          [opcode, operand] = Enum.slice(program, state.ip..state.ip+1)
          new_state = case get_diff(state, opcode, operand) do
            {:set, register, val} ->
              state
              |> Map.put(register, val)
              |> Map.put(:ip, state.ip + 2)
            {:jmp, new_ip} -> %{state | ip: new_ip}
            {:out, val} ->
              state
              |> Map.update!(:output, fn existing_output -> existing_output ++ [val] end)
              |> Map.put(:ip, state.ip + 2)
          end
          {:cont, new_state}
      end
    end)
  end

  def from_octet_array(array) do
    Enum.reduce(array, 0, fn n, acc -> 8 * acc + n end)
  end

  def part2(program) do
    reverse_slices = Enum.reduce(length(program)-1..0, [], fn n, acc -> [Enum.slice(program, n..length(program)-1) | acc] end)
    |> Enum.reverse()
    final = Enum.reduce(reverse_slices, [[]], fn target, possibilities ->
      new_possibilities = Enum.flat_map(possibilities, fn bp ->
        Enum.map(0..7, fn n -> bp ++ [n] end)
      end)

      Enum.filter(new_possibilities, fn p -> part1(from_octet_array(p), program) == target end)
    end)

    Enum.map(final, fn p -> from_octet_array(p) end)
    |> Enum.min()
  end

  def solve(test \\ false) do
    [[a], _, _, _, program] = get_input(test)

    part1 = part1(a, program)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(",")
    part2 = part2(program)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day17.solve()
