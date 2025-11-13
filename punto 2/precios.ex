# precios.ex
defmodule Precios do
  @moduledoc """
  Módulo para calcular precios finales de productos aplicando IVA.
  Soporta procesamiento secuencial y concurrente.
  """

  @doc """
  Calcula el precio final de un producto (precio base + IVA).
  """
  def precio_final(%Producto{nombre: n, precio_sin_iva: ps, iva: iva}) do
    # Simula trabajo computacional
    :timer.sleep(10)

    precio = ps * (1 + iva)
    IO.puts("#{n} → #{Float.round(precio, 2)} COP")
    {n, precio}
  end

  @doc """
  Procesa lista de productos de forma SECUENCIAL.
  """
  def precios_secuencial(productos) do
    Enum.map(productos, &precio_final/1)
  end

  @doc """
  Procesa lista de productos de forma CONCURRENTE.
  """
  def precios_concurrente(productos) do
    productos
    |> Enum.map(fn p -> Task.async(fn -> precio_final(p) end) end)
    |> Task.await_many()
  end

  @doc """
  Genera una lista de productos de ejemplo.
  """
  def lista_productos do
    [
      %Producto{nombre: "Arroz", stock: 30, precio_sin_iva: 2000, iva: 0.19},
      %Producto{nombre: "Leche", stock: 20, precio_sin_iva: 3000, iva: 0.05},
      %Producto{nombre: "Pan", stock: 50, precio_sin_iva: 1000, iva: 0.10},
      %Producto{nombre: "Huevos", stock: 40, precio_sin_iva: 500, iva: 0.19},
      %Producto{nombre: "Aceite", stock: 15, precio_sin_iva: 4500, iva: 0.19},
      %Producto{nombre: "Azúcar", stock: 25, precio_sin_iva: 1800, iva: 0.05}
    ]
  end

  @doc """
  Función principal que ejecuta ambas versiones.
  """
  def iniciar do
    productos = lista_productos()

    # Versión SECUENCIAL
    IO.puts("\n=== PROCESO SECUENCIAL ===")
    {t1, lista1} = :timer.tc(fn -> precios_secuencial(productos) end)
    IO.puts("Tiempo total: #{div(t1, 1000)} ms")

    # Versión CONCURRENTE
    IO.puts("\n=== PROCESO CONCURRENTE ===")
    {t2, lista2} = :timer.tc(fn -> precios_concurrente(productos) end)
    IO.puts("Tiempo total: #{div(t2, 1000)} ms")

    # Resultados
    IO.puts("\n=== RESULTADOS SECUENCIAL ===")
    Enum.each(lista1, fn {n, p} ->
      IO.puts("  #{n}: #{Float.round(p, 2)} COP")
    end)

    IO.puts("\n=== RESULTADOS CONCURRENTE ===")
    Enum.each(lista2, fn {n, p} ->
      IO.puts("  #{n}: #{Float.round(p, 2)} COP")
    end)

    # Análisis
    speedup = Float.round(t1 / t2, 2)
    IO.puts("\n Speedup = #{speedup}x")
    IO.puts("Mejora: #{Float.round((speedup - 1) * 100, 1)}% más rápido")
  end
end

# Llamar directamente
Precios.iniciar()
