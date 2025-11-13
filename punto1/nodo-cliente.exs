defmodule NodoCliente do
  @nodo_cliente :"cliente@10.43.197.151"
  @nodo_servidor :"servidor@10.43.197.120"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("SE INICIA EL CLIENTE")
    iniciar_nodo(@nodo_cliente)
    if Node.connect(@nodo_servidor) do
      IO.puts("✅ Conectado al servidor.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :carrera})
      esperar_mensajes()
    else
      IO.puts("❌ No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp esperar_mensajes() do
    receive do
      {:autos, autos} ->
        IO.puts("🏎️  Recibida lista de autos, iniciando simulación...")
        ranking = Carrera.carrera_concurrente(autos)
        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado, ranking}})
        IO.puts("🏁 Carrera finalizada y resultados enviados.")
        esperar_mensajes()

      :fin ->
        IO.puts("🚪 Servidor finalizó la conexión.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

NodoCliente.main()
