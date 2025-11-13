defmodule Cocina do
  # Simula la preparacion de una orden
  def preparar(%Orden{id: id, item: item, prep_ms: t}) do
    :timer.sleep(t)
    IO.puts(" Orden ##{id} - #{item} lista en #{t} ms")
    {id, item, t}
  end

  # Procesa las ordenes una por una
  def pipeline_secuencial(ordenes) do
    Enum.map(ordenes, &preparar/1)
  end

  # Procesa todas las ordenes en paralelo (concurrente)
  def pipeline_concurrente(ordenes) do
    ordenes
    |> Enum.map(fn o -> Task.async(fn -> preparar(o) end) end)
    |> Task.await_many()
  end

  # Lista de ordenes de ejemplo
  def lista_ordenes do
    [
      %Orden{id: 1, item: "Capuchino", prep_ms: 800},
      %Orden{id: 2, item: "Te verde", prep_ms: 600},
      %Orden{id: 3, item: "Latte", prep_ms: 1000},
      %Orden{id: 4, item: "Sandwich", prep_ms: 1200},
      %Orden{id: 5, item: "Jugo natural", prep_ms: 700}
    ]
  end
end
