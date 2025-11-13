defmodule NodoServidorLimpieza do
  @nodo_servidor :"servidor_limpieza@10.43.197.120"
  @nombre_proceso :servicio_limpieza

  def main() do
    IO.puts("SE INICIA EL SERVIDOR DE LIMPIEZA DE RESENAS")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:limpieza_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        send(productor, :fin)
        IO.puts("Servidor finalizado")

      {productor, :limpiar_resenas} ->
        IO.puts("Enviando lista de resenas al cliente...")
        resenas = Limpieza.lista_resenas()
        send(productor, {:resenas, resenas})
        procesar_mensajes()

      {productor, {:resultado_resumenes, resumenes}} ->
        IO.puts("\n=== RESUMENES GENERADOS ===")
        Enum.each(resumenes, fn %{id: id, resumen: resumen} ->
          IO.puts("Review ##{id}: #{resumen}")
        end)
        procesar_mensajes()

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        procesar_mensajes()
    end
  end
end

NodoServidorLimpieza.main()
