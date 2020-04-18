defmodule CNPJ do
  @moduledoc """
  CNPJ provides you functions to work with CNPJs.
  """

  @v1_weights [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  @v2_weights [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

  @doc """
  Returns `true` if given `number` is a valid CNPJ, otherwise `false`.

  ## Examples

      iex> CNPJ.valid?(87)
      false

      iex> CNPJ.valid?(30794968000106)
      true
  """
  @spec valid?(pos_integer) :: boolean
  def valid?(number) when is_integer(number) and number > 0 do
    digits = number |> Integer.digits()
    to_add = 14 - length(digits)

    if to_add >= 0 do
      safe_digits = add_padding(digits, to_add)

      v1 = verifier(safe_digits, @v1_weights)
      v2 = verifier(safe_digits, @v2_weights)

      [input_v1, input_v2] = Enum.take(safe_digits, -2)

      v1 == input_v1 and v2 == input_v2
    else
      false
    end
  end

  def valid?(0), do: false

  defp add_padding(digits, 0 = _to_add), do: digits
  defp add_padding(digits, to_add), do: add_padding([0 | digits], to_add - 1)

  defp verifier(digits, weights) do
    acc =
      weights
      |> Enum.zip(digits)
      |> Enum.reduce(0, fn {weight, digit}, acc ->
        acc + weight * digit
      end)

    verififer = 11 - rem(acc, 11)
    if verififer >= 10, do: 0, else: verififer
  end
end
