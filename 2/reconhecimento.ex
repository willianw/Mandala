#!/usr/bin/env elixir
require IEx

defmodule Script do
  def starts_with(node, edge) do
    case edge do
      {^node, _} -> true
      _          -> false
    end
  end

  def get_stt({istart, _}), do: istart
  def get_end({_, iend}), do: iend

  def find_edges(root, graph) do
    edges = Enum.filter(graph, fn(edge) -> Script.starts_with(root, edge) end)
    Enum.map(edges, fn(edge) -> Script.get_end(edge) end)
  end

  def find_connections([], _, list), do: list
  def find_connections([root | tail], graph, list) do
    edges = find_edges(root, graph)
    new_edges = Enum.uniq(tail ++ edges) -- list
    new_list = Enum.uniq(list ++ edges)
    find_connections(new_edges, graph, new_list)
  end

  def nodes([], _, list), do: list
  def nodes([{from, to} | tail], kind, list) do
    item = case kind do
      :s  -> {from, nil}
      :e  -> {to, nil}
      _   -> {from, to}
    end
    {istart, iend} = item
    newlist = list
    if not Enum.member?(list, istart) do
      newlist = list ++ [istart]
    end
    if not (is_nil(iend) or Enum.member?(newlist, iend)) do
      newlist = newlist ++ [iend]
    end
    nodes(tail, kind, newlist)
  end

  def next(grammar, symbol) do
    f = Enum.filter(grammar, fn({from, _}) ->  from == symbol end)
    Enum.map(f, fn({_, rest}) -> rest end)
  end

  def evolve(grammar, word), do: evolve(grammar, [], word)
  def evolve(_, _, []), do: []
  def evolve(grammar, before, [char | rest]) do
    list = Enum.map(next(grammar, char), fn(new) -> before ++ new ++ rest end)
    list ++ evolve(grammar, before++[char], rest)
  end

  def verify(grammar, n), do: [["S"]] ++ verify(grammar, [], [["S"]], n)
  def verify(_, _, [], _), do: []
  def verify(grammar, visited, [word | rest], n) do
    phase = Enum.filter(evolve(grammar, word), fn(w) -> length(w) <= n+1 end)
    phase ++ verify(grammar, visited ++ word, rest ++ phase, n)
  end

  def main(_) do
    [word | grammar] = Enum.reverse(Enum.drop("grammar.txt" |> File.read! |> String.split("\n"), -1))
    grammar = Enum.reduce(grammar, [], fn(line, acc) ->
      [head, tail] = String.split(line, " -> ")
      acc ++ [{head, String.graphemes(tail)}]
    end)
    n = String.length(word)
    words = Enum.map(verify(grammar, n), fn(list) -> Enum.join(List.delete(list, " ")) end)
    IO.puts("Palavras de tamanho até N geradas pela gramática:")
    IO.inspect(words)
    if Enum.member?(words, word) do
      IO.puts("A palavra é gerada pela gramática")
    else
      IO.puts("A palavra não é gerada pela gramática")
    end
    IEx.pry
  end
end

Script.main(System.argv)
