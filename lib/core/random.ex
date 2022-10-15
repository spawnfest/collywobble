defmodule Core.Random do
  @doc "Generate a random URL safe string with N characters"
  @spec string(integer()) :: binary()
  def string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
