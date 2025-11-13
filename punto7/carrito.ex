defmodule Carrito do
  # Aplica las reglas de descuento a un carrito
  def total_con_descuentos(%{id: id, items: items, cupon: cupon}) do
    :timer.sleep(Enum.random(5..15))

    subtotal = Enum.reduce(items, 0.0, fn %{precio: p}, acc -> acc + p end)

    total =
      subtotal
      |> aplicar_cupon(cupon)
      |> aplicar_categoria(items)
      |> aplicar_2x1(items)

    IO.puts(" Carrito ##{id} -> total con descuentos: $#{Float.round(total, 2)}")
    {id, total}
  end

  # Regla 1: cupon general (10% descuento si existe)
  defp aplicar_cupon(total, nil), do: total
  defp aplicar_cupon(total, _cupon), do: total * 0.9

  # Regla 2: descuento 5% si hay productos de categoria "electronica"
  defp aplicar_categoria(total, items) do
    if Enum.any?(items, &(&1.categoria == "electronica")), do: total * 0.95, else: total
  end

  # Regla 3: 2x1 en categoria "ropa"
  defp aplicar_2x1(total, items) do
    ropa = Enum.filter(items, &(&1.categoria == "ropa"))
    cantidad_ropa = Enum.count(ropa)
    if cantidad_ropa >= 2 do
      descuento_ropa = div(cantidad_ropa, 2) * (Enum.at(ropa, 0, %{precio: 0}).precio)
      total - descuento_ropa
    else
      total
    end
  end

  # Lista de carritos de ejemplo
  def lista_carritos do
    [
      %{id: 1, cupon: "SAVE10", items: [%{precio: 50, categoria: "ropa"}, %{precio: 80, categoria: "ropa"}]},
      %{id: 2, cupon: nil, items: [%{precio: 300, categoria: "electronica"}, %{precio: 150, categoria: "hogar"}]},
      %{id: 3, cupon: "DESCUENTO", items: [%{precio: 40, categoria: "alimentos"}, %{precio: 60, categoria: "ropa"}]},
      %{id: 4, cupon: nil, items: [%{precio: 500, categoria: "electronica"}]},
      %{id: 5, cupon: "VIP", items: [%{precio: 100, categoria: "ropa"}, %{precio: 120, categoria: "ropa"}]}
    ]
  end

  # Procesamiento concurrente
  def descuentos_concurrente(carritos) do
    carritos
    |> Enum.map(&Task.async(fn -> total_con_descuentos(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
