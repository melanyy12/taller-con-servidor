defmodule NodoServidor do
  @nodo_servidor :"servidor@10.43.197.120"
  @nombre_proceso :servicio_cadenas

  def main() do
    IO.puts("SE INICIA EL SERVIDOR")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        send(productor, :fin)

      {productor, :carrera} ->
        IO.puts("➡️  Enviando lista de autos al cliente...")
        autos = Carrera.lista_autos()
        send(productor, {:autos, autos})
        procesar_mensajes()

      {productor, {:resultado, ranking}} ->
        IO.puts("\n🏁 Resultado recibido del cliente:")
        Enum.each(ranking, fn {piloto, tiempo} ->
          IO.puts("  #{piloto} - #{tiempo} ms")
        end)
        procesar_mensajes()

      {productor, mensaje} ->
        respuesta = procesar_mensaje(mensaje)
        send(productor, respuesta)
        procesar_mensajes()
    end
  end

  defp procesar_mensaje({:mayusculas, msg}), do: String.upcase(msg)
  defp procesar_mensaje({:minusculas, msg}), do: String.downcase(msg)
  defp procesar_mensaje({funcion, msg}) when is_function(funcion, 1), do: funcion.(msg)
  defp procesar_mensaje(mensaje), do: "El mensaje \"#{mensaje}\" es desconocido."
end

NodoServidor.main()
