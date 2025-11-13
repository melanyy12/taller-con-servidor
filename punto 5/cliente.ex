defmodule NodoClienteReportes do
  @nodo_cliente :"cliente_reportes@10.43.197.151"
  @nodo_servidor :"servidor_reportes@10.43.197.120"
  @nombre_proceso :servicio_reportes

  def main() do
    IO.puts("SE INICIA EL CLIENTE DE REPORTES")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor de reportes.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :generar_reportes})
      esperar_mensajes()
    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:reportes_cookie)
  end

  defp esperar_mensajes() do
    receive do
      {:sucursales, sucursales} ->
        IO.puts("Recibida lista de sucursales, iniciando generacion concurrente...")

        IO.puts("\n=== GENERACION CONCURRENTE ===")
        {tiempo, reportes} = :timer.tc(fn ->
          Reporte.reportes_concurrente(sucursales)
        end)
        IO.puts("Tiempo total (concurrente): #{div(tiempo, 1000)} ms")

        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado_reportes, reportes}})
        IO.puts("Generacion finalizada y reportes enviados al servidor.")
        esperar_mensajes()

      :fin ->
        IO.puts("Servidor finalizo la conexion.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

NodoClienteReportes.main()
