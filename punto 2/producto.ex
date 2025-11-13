defmodule Producto do
  @moduledoc """
  Estructura que representa un producto con sus atributos básicos.
  """
  defstruct [:nombre, :stock, :precio_sin_iva, :iva]

  @doc """
  Crea un nuevo producto.

  ## Ejemplos

      iex> Producto.nuevo("Arroz", 30, 2000, 0.19)
      %Producto{nombre: "Arroz", stock: 30, precio_sin_iva: 2000, iva: 0.19}
  """
  def nuevo(nombre, stock, precio_sin_iva, iva) do
    %Producto{
      nombre: nombre,
      stock: stock,
      precio_sin_iva: precio_sin_iva,
      iva: iva
    }
  end
end
