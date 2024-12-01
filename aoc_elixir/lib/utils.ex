defmodule Utils do
  def get_all_nums(s) do
    Regex.scan(~r/-?\d+/, s)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
  end

  def get_alpha_num(s) do
    String.split(s, ~r/\W+/)
      |> Enum.filter(fn x -> x != "" end)
  end

  def lcm(lst) do
    Enum.reduce(lst, hd(lst), fn n1, n2 -> div(n1 * n2, Integer.gcd(n1, n2)) end)
  end
end
