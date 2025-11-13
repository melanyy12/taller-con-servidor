defmodule Cookie do
  def main() do
    :crypto.strong_rand_bytes(@longitud_llave)
    |> Base.encode64()
    |> IO.puts()

  end
end
Cookie.main()
