defmodule Validador do
  # Valida un usuario individualmente
  def validar(%{email: email, edad: edad, nombre: nombre}) do
    :timer.sleep(Enum.random(3..10))

    errores =
      []
      |> maybe_add(String.contains?(email, "@"), :email_invalido)
      |> maybe_add(edad >= 0, :edad_invalida)
      |> maybe_add(String.trim(nombre) != "", :nombre_vacio)

    resultado =
      if errores == [], do: :ok, else: {:error, errores}

    IO.puts(" Validado #{email}: #{inspect(resultado)}")

    {email, resultado}
  end

  # Funcion auxiliar: agrega error si la condicion es falsa
  defp maybe_add(list, true, _error), do: list
  defp maybe_add(list, false, error), do: [error | list]

  # Lista de usuarios de ejemplo
  def lista_usuarios do
    [
      %{email: "ana@example.com", edad: 25, nombre: "Ana"},
      %{email: "pedroexample.com", edad: 19, nombre: "Pedro"},
      %{email: "luis@example.com", edad: -5, nombre: "Luis"},
      %{email: "sofia@example.com", edad: 30, nombre: ""},
      %{email: "carla@example.com", edad: 22, nombre: "Carla"}
    ]
  end

  # Procesamiento concurrente
  def validacion_concurrente(usuarios) do
    usuarios
    |> Enum.map(&Task.async(fn -> validar(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
