defmodule Input do
  @moduledoc """
  Documentation for AocElixir.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AocElixir.hello
      :world

  """
  def read_file(filename) do
    {:ok, input} = File.read(filename)
    input
  end

  def raw(filename) do
    read_file(filename)
  end

  def lines(filename, sep \\ "\n", trim \\ true) do
    read_file(filename)
      |> then(fn s -> cond do
        trim -> String.trim(s)
        true -> s
      end end)
      |> String.split(sep)
  end

  def line_tokens(filename, sep1 \\ " ", sep2 \\ "\n", trim \\ true) do
    lines(filename, sep2, trim)
      |> Enum.map(fn r -> String.split(r, sep1) end)
  end

  def ints_in_lines(filename, sep \\ "\n", trim \\ true) do
    lines(filename, sep, trim)
      |> Enum.map(fn r -> Utils.get_all_nums(r) end)
  end

  def ints(filename) do
    lines(filename)
      |> Enum.map(&String.to_integer/1)
  end

  def line_of_ints(filename) do
    lines(filename, ",")
    |> Enum.map(&String.to_integer/1)
  end
end
