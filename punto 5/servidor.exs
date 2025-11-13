defmodule NodoServidorReportes do
  @nodo_servidor :"servidor_reportes@10.43.197.120"
  @nombre_proceso :servicio_reportes

  def main() do
    IO.puts("SE INICIA EL SERVIDOR DE REPORTES")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:reportes_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        send(productor, :fin)
        IO.puts("Servidor finalizado")

      {productor, :generar_reportes} ->
        IO.puts("Enviando lista de sucursales al cliente...")
        sucursales = Reporte.lista_sucursales()
        send(productor, {:sucursales, sucursales})
        procesar_mensajes()

      {productor, {:resultado_reportes, reportes}} ->
        IO.puts("\n=== RESUMENES POR SUCURSAL ===")
        Enum.each(reportes, fn %{id: id, total: total, promedio: prom, top_items: top} ->
          top_nombres = Enum.map(top, fn {item, _v} -> item end) |> Enum.join(", ")
          IO.puts("Sucursal #{id}: Total #{total}, Promedio #{prom}, Top: #{top_nombres}")
        end)
        procesar_mensajes()

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        procesar_mensajes()
    end
  end
end

NodoServidorReportes.main()
