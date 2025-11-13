defmodule Limpieza do
  @stopwords ~w(el la los las de del y a en un una por para con que es fue muy lo al se me mi)

  # Quita tildes sin danar palabras
  defp quitar_tildes(texto) do
    texto
    |> String.replace("á", "a")
    |> String.replace("é", "e")
    |> String.replace("í", "i")
    |> String.replace("ó", "o")
    |> String.replace("ú", "u")
    |> String.replace("Á", "A")
    |> String.replace("É", "E")
    |> String.replace("Í", "I")
    |> String.replace("Ó", "O")
    |> String.replace("Ú", "U")
  end

  def limpiar(%{id: id, texto: texto}) do
    :timer.sleep(Enum.random(5..15))

    limpio =
      texto
      |> String.downcase()
      |> quitar_tildes()
      |> String.replace(~r/[^a-z0-9\s]/, "")
      |> String.split()
      |> Enum.reject(&(&1 in @stopwords))
      |> Enum.join(" ")

    IO.puts(" Review ##{id} limpia: #{limpio}...")

    %{id: id, resumen: limpio}
  end

  # Lista de resenas de ejemplo
  def lista_resenas do
    [
      %{id: 1, texto: "el Cafe esta excelente, pero servicio lentisimo!"},
      %{id: 2, texto: "Me encanto el ambiente, musica agradable."},
      %{id: 3, texto: "Demasiado caro para lo que ofrecen. No volveria."},
      %{id: 4, texto: "Lugar bonito pero comida regular."},
      %{id: 5, texto: "Excelente atencion, volvere con mis amigos."}
    ]
  end

  # Procesamiento concurrente
  def limpieza_concurrente(resenas) do
    resenas
    |> Enum.map(&Task.async(fn -> limpiar(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
