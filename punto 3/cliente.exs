defmodule NodoClienteCocina do
  @nodo_cliente :"cliente_cocina@10.43.197.151"
  @nodo_servidor :"servidor_cocina@10.43.197.120"
  @nombre_proceso :servicio_cocina

  def main() do
    IO.puts("SE INICIA EL CLIENTE DE COCINA")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor de cocina.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :preparar_ordenes})
      esperar_mensajes()
    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:cocina_cookie)
  end

  defp esperar_mensajes() do
    receive do
      {:ordenes, ordenes} ->
        IO.puts("Recibida lista de ordenes, iniciando preparacion concurrente...")

        IO.puts("\n=== PIPELINE CONCURRENTE ===")
        {tiempo, tickets} = :timer.tc(fn ->
          Cocina.pipeline_concurrente(ordenes)
        end)
        IO.puts("Tiempo total (concurrente): #{div(tiempo, 1000)} ms")

        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado_tickets, tickets}})
        IO.puts("Preparacion finalizada y tickets enviados al servidor.")
        esperar_mensajes()

      :fin ->
        IO.puts("Servidor finalizo la conexion.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

NodoClienteCocina.main()
