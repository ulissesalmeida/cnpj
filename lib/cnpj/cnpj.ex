defmodule CNPJ do
  @moduledoc """
  CNPJ provides you functions to work with CNPJs.
  """

  alias CNPJ.ParsingError

  defguardp is_positive_integer(number) when is_integer(number) and number > 0

  @v1_weights [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  @v2_weights [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

  defstruct [:digits]

  @typedoc """
  The CNPJ type. It' composed of fourteen digits(0-9]).
  """
  @opaque t :: %CNPJ{
            digits:
              {pos_integer(), pos_integer(), pos_integer(), pos_integer(), pos_integer(),
               pos_integer(), pos_integer(), pos_integer(), pos_integer(), pos_integer(),
               pos_integer(), pos_integer(), pos_integer(), pos_integer()}
          }

  @doc """
  Returns a tuple with the eleven digits of the given cnpj.

  ## Examples

    iex> 70947414000108 |> CNPJ.parse!() |> CNPJ.digits()
    {7, 0, 9, 4, 7, 4, 1, 4, 0, 0, 0, 1, 0, 8}
  """
  @spec digits(t) :: tuple
  def digits(%CNPJ{digits: digits}), do: digits

  @doc """
  Returns a `cnpj` when the given `number` is valid. Otherwise raises
  `CNPJ.ParsingError` error.

  ## Examples

      iex> CNPJ.parse!(30794968000106)
      %CNPJ{digits: {3, 0, 7, 9, 4, 9, 6, 8, 0, 0, 0, 1, 0, 6}}

      iex> CNPJ.parse!("30794968000106")
      %CNPJ{digits: {3, 0, 7, 9, 4, 9, 6, 8, 0, 0, 0, 1, 0, 6}}

      iex> CNPJ.parse!("70.947.414/0001-08")
      %CNPJ{digits: {7, 0, 9, 4, 7, 4, 1, 4, 0, 0, 0, 1, 0, 8}}

      iex> CNPJ.parse!(82)
      ** (CNPJ.ParsingError) invalid_verifier
  """
  @spec parse!(pos_integer() | String.t()) :: CNPJ.t() | no_return()
  def parse!(number) do
    case parse(number) do
      {:ok, cnpj} -> cnpj
      {:error, error} -> raise error
    end
  end

  @doc """
  Returns an `:ok` tuple with a `cnpj` when the given `number` is valid.
  Otherwise returns an `:error` tuple with the error reason.

  ## Examples

      iex> CNPJ.parse(30794968000106)
      {:ok, %CNPJ{digits: {3, 0, 7, 9, 4, 9, 6, 8, 0, 0, 0, 1, 0, 6}}}

      iex> CNPJ.parse("30794968000106")
      {:ok, %CNPJ{digits: {3, 0, 7, 9, 4, 9, 6, 8, 0, 0, 0, 1, 0, 6}}}

      iex> CNPJ.parse("70.947.414/0001-08")
      {:ok, %CNPJ{digits: {7, 0, 9, 4, 7, 4, 1, 4, 0, 0, 0, 1, 0, 8}}}

      iex> CNPJ.parse(82)
      {:error, %CNPJ.ParsingError{reason: :invalid_verifier}}
  """
  @spec parse(pos_integer() | String.t()) ::
          {:ok, CNPJ.t()} | {:error, ParsingError.t()}
  def parse(
        <<first_digits::bytes-size(2), ".", second_digits::bytes-size(3), ".",
          third_digits::bytes-size(3), "/", fourth_digits::bytes-size(4), "-",
          last_digits::bytes-size(2)>>
      ) do
    parse(first_digits <> second_digits <> third_digits <> fourth_digits <> last_digits)
  end

  def parse(number) when is_binary(number) do
    case Integer.parse(number) do
      {integer, ""} -> parse(integer)
      _ -> {:error, %ParsingError{reason: :invalid_format}}
    end
  end

  def parse(number) when is_positive_integer(number) do
    digits = number |> Integer.digits()
    to_add = 14 - length(digits)

    if to_add >= 0 do
      verify(digits, to_add)
    else
      {:error, %ParsingError{reason: :too_long}}
    end
  end

  def parse(0), do: {:error, %ParsingError{reason: :all_zero_digits}}

  defp verify(digits, to_add) do
    safe_digits = add_padding(digits, to_add)

    v1 = verifier(safe_digits, @v1_weights)
    v2 = verifier(safe_digits, @v2_weights)

    [input_v1, input_v2] = Enum.take(safe_digits, -2)

    if v1 == input_v1 and v2 == input_v2 do
      {:ok, %CNPJ{digits: List.to_tuple(digits)}}
    else
      {:error, %ParsingError{reason: :invalid_verifier}}
    end
  end

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

  @doc """
  Returns `true` if given `number` is a valid CNPJ, otherwise `false`.

  ## Examples

      iex> CNPJ.valid?(87)
      false

      iex> CNPJ.valid?(30794968000106)
      true

      iex> CNPJ.valid?("87")
      false

      iex> CNPJ.valid?("30794968000106")
      true

      iex> CNPJ.valid?("70.947.414/0001-08")
      true
  """
  @spec valid?(pos_integer | String.t()) :: boolean
  def valid?(number) do
    case parse(number) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
