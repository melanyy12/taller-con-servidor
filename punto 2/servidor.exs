defmodule ServidorEjercicio2 do
  @moduledoc """
  Servidor distribuido para el ejercicio 2.
  Coordina el procesamiento de precios entre cliente y servidor.
  """

  @nodo_servidor :"servidor@10.43.197.120"
  @nombre_proceso :servicio_precios

  def main() do
    IO.puts(" SERVIDOR - Ejercicio 2: Precios con IVA")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    IO.puts(" Servidor listo en #{@nodo_servidor}")
    IO.puts("Esperando conexiones...\n")
    procesar_mensajes()
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        IO.puts("Cerrando servidor...")
        send(productor, :fin)

      {productor, :solicitar_productos} ->
        IO.puts(" Cliente solicita productos...")
        productos = Precios.lista_productos()
        send(productor, {:productos, productos})
        IO.puts(" Enviados #{length(productos)} productos")
        procesar_mensajes()

      {productor, {:resultado, resultados, tiempo}} ->
        IO.puts("\n RESULTADOS RECIBIDOS:")
        IO.puts("  Tiempo procesamiento: #{tiempo} ms")
        Enum.each(resultados, fn {nombre, precio} ->
          IO.puts("  #{nombre}: $#{Float.round(precio, 2)}")
        end)
        IO.puts("")
        procesar_mensajes()

      mensaje ->
        IO.puts("  Mensaje desconocido: #{inspect(mensaje)}")
        procesar_mensajes()
    end
  end
end
