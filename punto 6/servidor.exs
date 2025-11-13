defmodule NodoServidorValidador do
  @nodo_servidor :"servidor_validador@10.43.197.120"
  @nombre_proceso :servicio_validador

  def main() do
    IO.puts("SE INICIA EL SERVIDOR DE VALIDACION DE USUARIOS")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_proceso)
    procesar_mensajes()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:validador_cookie)
  end

  defp procesar_mensajes() do
    receive do
      {productor, :fin} ->
        send(productor, :fin)
        IO.puts("Servidor finalizado")

      {productor, :validar_usuarios} ->
        IO.puts("Enviando lista de usuarios al cliente...")
        usuarios = Validador.lista_usuarios()
        send(productor, {:usuarios, usuarios})
        procesar_mensajes()

      {productor, {:resultado_validaciones, validaciones}} ->
        IO.puts("\n=== RESULTADOS DE VALIDACION ===")
        Enum.each(validaciones, fn {email, result} ->
          IO.puts("#{email} -> #{inspect(result)}")
        end)
        procesar_mensajes()

      otro ->
        IO.puts("Mensaje desconocido: #{inspect(otro)}")
        procesar_mensajes()
    end
  end
end

NodoServidorValidador.main()
