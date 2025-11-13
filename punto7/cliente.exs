defmodule NodoClienteCarrito do
  @nodo_cliente :"cliente_carrito@10.43.197.151"
  @nodo_servidor :"servidor_carrito@10.43.197.120"
  @nombre_proceso :servicio_carrito

  def main() do
    IO.puts("SE INICIA EL CLIENTE DE DESCUENTOS DE CARRITO")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor de carritos.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :calcular_descuentos})
      esperar_mensajes()
    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:carrito_cookie)
  end

  defp esperar_mensajes() do
    receive do
      {:carritos, carritos} ->
        IO.puts("Recibida lista de carritos, iniciando calculo concurrente...")

        IO.puts("\n=== DESCUENTOS CONCURRENTE ===")
        {tiempo, totales} = :timer.tc(fn ->
          Carrito.descuentos_concurrente(carritos)
        end)
        IO.puts("Tiempo total (concurrente): #{div(tiempo, 1000)} ms")

        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado_totales, totales}})
        IO.puts("Calculo finalizado y totales enviados al servidor.")
        esperar_mensajes()

      :fin ->
        IO.puts("Servidor finalizo la conexion.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

NodoClienteCarrito.main()
