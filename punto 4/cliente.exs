defmodule NodoClienteLimpieza do
  @nodo_cliente :"cliente_limpieza@10.43.197.151"
  @nodo_servidor :"servidor_limpieza@10.43.197.120"
  @nombre_proceso :servicio_limpieza

  def main() do
    IO.puts("SE INICIA EL CLIENTE DE LIMPIEZA DE RESENAS")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor de limpieza.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :limpiar_resenas})
      esperar_mensajes()
    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:limpieza_cookie)
  end

  defp esperar_mensajes() do
    receive do
      {:resenas, resenas} ->
        IO.puts("Recibida lista de resenas, iniciando limpieza concurrente...")

        IO.puts("\n=== LIMPIEZA CONCURRENTE ===")
        {tiempo, resumenes} = :timer.tc(fn ->
          Limpieza.limpieza_concurrente(resenas)
        end)
        IO.puts("Tiempo total (concurrente): #{div(tiempo, 1000)} ms")

        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado_resumenes, resumenes}})
        IO.puts("Limpieza finalizada y resumenes enviados al servidor.")
        esperar_mensajes()

      :fin ->
        IO.puts("Servidor finalizo la conexion.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

NodoClienteLimpieza.main()
