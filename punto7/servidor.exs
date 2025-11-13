defmodule NodoServidorCarrito do
  @nodo_servidor :"servidor_carrito@10.43.197.120"
  @nombre_proceso :servicio_carrito

  def main() do
    IO.puts("SE INICIA EL SERVIDOR DE DESCUENTOS DE CARRITO")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:carrito_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        send(productor, :fin)
        IO.puts("Servidor finalizado")

      {productor, :calcular_descuentos} ->
        IO.puts("Enviando lista de carritos al cliente...")
        carritos = Carrito.lista_carritos()
        send(productor, {:carritos, carritos})
        procesar_mensajes()

      {productor, {:resultado_totales, totales}} ->
        IO.puts("\n=== TOTALES FINALES ===")
        Enum.each(totales, fn {id, total} ->
          IO.puts("Carrito ##{id} -> $#{Float.round(total, 2)}")
        end)
        procesar_mensajes()

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        procesar_mensajes()
    end
  end
end

NodoServidorCarrito.main()
