#!/usr/bin/env elixir
require IEx

defmodule Script do
  def next_state(_, _, nil), do: []
  def next_state(transitions, state, symbol) do
    trans = Enum.filter(transitions, fn([i, l, _]) -> i == state and l == symbol end)
    Enum.map(trans, fn([_, _, f]) -> f end)
  end

  def iteracao(symbol, acc, transitions) do
    ns = next_state(transitions, Enum.at(acc, -1), symbol)
    IO.puts(Enum.join(["Símbolo recebido: ", symbol, "\nPróximo estado: ", ns], ""))
    Task.await(Task.async(fn -> IO.gets "Pressione qualquer tecla para continuar." end), :infinity)

    acc ++ ns
  end

  def main() do
    [states,  transitions,  words] = "fda.txt" |> File.read! |> String.split("\n\n")
    transitions = transitions |> String.split("\n") |> Enum.map(fn(x) -> String.split(x, " ") end)

    [initial_state, acceptance_states] = String.split(states, "\n")
    acceptance_states = String.split(acceptance_states, " ")

    words = words |> String.split("\n") |> Enum.drop(-1)
    word = words |> Enum.at(0) |> String.split("")  |> Enum.drop(-1)
    hist = Enum.reduce(word, [initial_state], &iteracao(&1, &2, transitions))

    IEx.pry
  end
end


Script.main()
