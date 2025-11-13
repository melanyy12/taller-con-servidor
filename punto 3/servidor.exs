defmodule NodoServidorCocina do
  @nodo_servidor :"servidor_cocina@10.43.197.120"
  @nombre_proceso :servicio_cocina

  def main() do
    IO.puts("SE INICIA EL SERVIDOR DE COCINA")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:cocina_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        send(productor, :fin)
        IO.puts("Servidor finalizado")

      {productor, :preparar_ordenes} ->
        IO.puts("Enviando lista de ordenes al cliente...")
        ordenes = Cocina.lista_ordenes()
        send(productor, {:ordenes, ordenes})
        procesar_mensajes()

      {productor, {:resultado_tickets, tickets}} ->
        IO.puts("\nTickets generados recibidos del cliente:")
        Enum.each(tickets, fn {id, item, _t} ->
          IO.puts("  Ticket ##{id} - #{item}")
        end)
        procesar_mensajes()

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        procesar_mensajes()
    end
  end
end

NodoServidorCocina.main()
