defmodule Reporte do
  # Simula generacion de reporte para una sucursal
  def generar(%{id: id, ventas_diarias: ventas}) do
    :timer.sleep(Enum.random(50..120))

    total = Enum.sum(Enum.map(ventas, fn {_item, v} -> v end))
    promedio = Float.round(total / length(ventas), 2)
    top_items = ventas |> Enum.sort_by(fn {_item, v} -> -v end) |> Enum.take(3)

    IO.puts(" Reporte listo Sucursal #{id}: total #{total}, promedio #{promedio}")

    %{
      id: id,
      total: total,
      promedio: promedio,
      top_items: top_items
    }
  end

  # Lista de sucursales de ejemplo
  def lista_sucursales do
    [
      %{id: 1, ventas_diarias: [{"Cafe", 1200}, {"Pan", 800}, {"Leche", 950}, {"Galletas", 600}]},
      %{id: 2, ventas_diarias: [{"Arepa", 1000}, {"Jugo", 900}, {"Cereal", 750}, {"Yogurt", 650}]},
      %{id: 3, ventas_diarias: [{"Sandwich", 1300}, {"Cafe", 1100}, {"Te", 700}, {"Agua", 500}]},
      %{id: 4, ventas_diarias: [{"Pan", 950}, {"Leche", 890}, {"Huevos", 970}, {"Queso", 1200}]},
      %{id: 5, ventas_diarias: [{"Pizza", 2100}, {"Refresco", 1200}, {"Postre", 800}, {"Agua", 300}]}
    ]
  end

  # Procesamiento concurrente
  def reportes_concurrente(sucursales) do
    sucursales
    |> Enum.map(&Task.async(fn -> generar(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
