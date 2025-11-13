defmodule NodoClienteValidador do
  @nodo_cliente :"cliente_validador@10.43.197.151"
  @nodo_servidor :"servidor_validador@10.43.197.120"
  @nombre_proceso :servicio_validador

  def main() do
    IO.puts("SE INICIA EL CLIENTE DE VALIDACION DE USUARIOS")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      IO.puts("Conectado al servidor de validacion.")
      send({@nombre_proceso, @nodo_servidor}, {self(), :validar_usuarios})
      esperar_mensajes()
    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:validador_cookie)
  end

  defp esperar_mensajes() do
    receive do
      {:usuarios, usuarios} ->
        IO.puts("Recibida lista de usuarios, iniciando validacion concurrente...")

        IO.puts("\n=== VALIDACION CONCURRENTE ===")
        {tiempo, validaciones} = :timer.tc(fn ->
          Validador.validacion_concurrente(usuarios)
        end)
        IO.puts("Tiempo total (concurrente): #{div(tiempo, 1000)} ms")

        send({@nombre_proceso, @nodo_servidor}, {self(), {:resultado_validaciones, validaciones}})
        IO.puts("Validacion finalizada y resultados enviados al servidor.")
        esperar_mensajes()

      :fin ->
        IO.puts("Servidor finalizo la conexion.")

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

NodoClienteValidador.main()
