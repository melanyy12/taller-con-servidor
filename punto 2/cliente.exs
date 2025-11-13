defmodule ClienteEjercicio2 do
  @moduledoc """
  Cliente distribuido para el ejercicio 2.
  Recibe productos del servidor y los procesa concurrentemente.
  """

  @nodo_cliente :"cliente@10.43.197.151"
  @nodo_servidor :"servidor@10.43.197.120"
  @nombre_proceso :servicio_precios

  def main() do
    IO.puts(" CLIENTE - Ejercicio 2: Precios con IVA")
    iniciar_nodo(@nodo_cliente)

    if Node.connect(@nodo_servidor) do
      IO.puts(" Conectado al servidor\n")
      solicitar_procesamiento()
      esperar_mensajes()
    else
      IO.puts(" No se pudo conectar con el servidor.")
    end
  end

  defp iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp solicitar_procesamiento() do
    IO.puts(" Solicitando productos al servidor...")
    send({@nombre_proceso, @nodo_servidor}, {self(), :solicitar_productos})
  end

  defp esperar_mensajes() do
    receive do
      {:productos, productos} ->
        IO.puts(" Recibidos #{length(productos)} productos")
        IO.puts(" Procesando concurrentemente...\n")

        {tiempo, resultados} = :timer.tc(fn ->
          Precios.precios_concurrente(productos)
        end)

        tiempo_ms = div(tiempo, 1000)
        IO.puts("\n Procesamiento completado en #{tiempo_ms} ms")

        # Enviar resultados al servidor
        send({@nombre_proceso, @nodo_servidor},
             {self(), {:resultado, resultados, tiempo_ms}})

        IO.puts(" Resultados enviados al servidor")
        esperar_mensajes()

      :fin ->
        IO.puts(" Servidor finalizó la conexión.")
        System.halt(0)

      otro ->
        IO.puts("  Mensaje desconocido: #{inspect(otro)}")
        esperar_mensajes()
    end
  end
end

# === ARCHIVO: test_local_ejercicio2.exs ===
defmodule TestLocalEjercicio2 do
  @moduledoc """
  Script para probar el ejercicio 2 localmente sin distribución.
  """

  def main() do
    IO.puts("╔══════════════════════════════════════════╗")
    IO.puts("║  TEST LOCAL - EJERCICIO 2: PRECIOS IVA  ║")
    IO.puts("╚══════════════════════════════════════════╝\n")

    Precios.iniciar()

    IO.puts("\n Test completado")
  end
end
