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

  def paths([], graph, []), do: paths(nodes(graph, :s, []), graph, [])
  def paths([], _, list), do: list
  def paths([root | tail], graph, list) do
    relations = Enum.map(find_connections([root], graph, []),
                          fn(conn) -> {root, conn} end)
    paths( tail, graph, list ++ relations)
  end

  def main(_) do
    a = Enum.drop ("graph.txt" |> File.read! |> String.split("\n")), -1
    a = Enum.reduce(a, [], fn(line, acc) ->
      [head, tail] = String.split(line, " ")
      acc ++ [{head, tail}]
    end)
    IO.inspect (paths([], a, []) ++
      Enum.map(nodes(a, :b, []), fn(node)->
        {node, node}
      end))
    #IEx.pry
  end
end

Script.main(System.argv)
