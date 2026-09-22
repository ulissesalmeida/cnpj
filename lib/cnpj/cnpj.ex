defmodule CNPJ do
  @moduledoc """
  CNPJ provides you functions to work with CNPJs.

  Since July 2026 the Receita Federal also issues alphanumeric CNPJs, where the
  first twelve characters can be uppercase letters (`A-Z`) as well as digits.
  The two check digits stay numeric. Both formats are supported, and numeric
  CNPJs remain valid.
  """

  alias CNPJ.{ParsingError, UnsupportedVersionError}

  defguardp is_positive_integer(number) when is_integer(number) and number > 0

  @length 14
  @zeros String.duplicate("0", @length)

  @v1_weights [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
  @v2_weights [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

  defstruct [:digits]

  @typedoc """
  The CNPJ type. It is composed of fourteen characters: twelve digits or
  uppercase letters (`0-9`, `A-Z`) followed by two check digits (`0-9`).
  """
  @opaque t :: %CNPJ{digits: String.t()}

  @doc """
  Returns a tuple with the fourteen digits of the given numeric `cnpj`.

  Deprecated: use `digits/2` instead, which supports both formats. This
  function raises `CNPJ.UnsupportedVersionError` if the CNPJ has letters.

  ## Examples

      iex> 70947414000108 |> CNPJ.parse!() |> CNPJ.digits()
      {7, 0, 9, 4, 7, 4, 1, 4, 0, 0, 0, 1, 0, 8}
  """
  @spec digits(t) :: tuple
  def digits(%CNPJ{} = cnpj), do: digits(cnpj, :cnpj_pre_2026)

  @doc """
  Returns a tuple with the fourteen characters of the given `cnpj`.

  The `version` picks the type of the elements:

    * `:cnpj_2026` - strings, so it works with any CNPJ, letters included.
    * `:cnpj_pre_2026` - integers, as `digits/1` returns. Raises
      `CNPJ.UnsupportedVersionError` if the CNPJ has letters.

  ## Examples

      iex> "12.ABC.345/01DE-35" |> CNPJ.parse!() |> CNPJ.digits(:cnpj_2026)
      {"1", "2", "A", "B", "C", "3", "4", "5", "0", "1", "D", "E", "3", "5"}

      iex> "70947414000108" |> CNPJ.parse!() |> CNPJ.digits(:cnpj_pre_2026)
      {7, 0, 9, 4, 7, 4, 1, 4, 0, 0, 0, 1, 0, 8}
  """
  @spec digits(t, :cnpj_2026 | :cnpj_pre_2026) :: tuple
  def digits(%CNPJ{digits: digits}, :cnpj_2026) do
    digits |> String.codepoints() |> List.to_tuple()
  end

  def digits(%CNPJ{digits: digits}, :cnpj_pre_2026) do
    if numeric?(digits) do
      digits |> to_values() |> List.to_tuple()
    else
      raise UnsupportedVersionError
    end
  end

  @doc """
  Formats a `cnpj` to friendly readable text.

  ## Examples

      iex> 70947414000108 |> CNPJ.parse!() |> CNPJ.format()
      "70.947.414/0001-08"

      iex> "12ABC34501DE35" |> CNPJ.parse!() |> CNPJ.format()
      "12.ABC.345/01DE-35"
  """
  @spec format(CNPJ.t()) :: String.t()
  def format(%CNPJ{digits: digits}) do
    <<first::bytes-size(2), second::bytes-size(3), third::bytes-size(3), fourth::bytes-size(4),
      verifiers::bytes-size(2)>> = digits

    IO.iodata_to_binary([first, ".", second, ".", third, "/", fourth, "-", verifiers])
  end

  @doc """
  Returns a `cnpj` when the given `number` is valid. Otherwise raises
  `CNPJ.ParsingError` error.

  Passing `number` as an integer is deprecated, since an integer cannot hold
  the letters of an alphanumeric CNPJ. Pass a string instead.

  ## Examples

      iex> CNPJ.parse!("30794968000106")
      %CNPJ{digits: "30794968000106"}

      iex> CNPJ.parse!("70.947.414/0001-08")
      %CNPJ{digits: "70947414000108"}

      iex> CNPJ.parse!("12.ABC.345/01DE-35")
      %CNPJ{digits: "12ABC34501DE35"}

      iex> CNPJ.parse!(30794968000106)
      %CNPJ{digits: "30794968000106"}

      iex> CNPJ.parse!(82)
      ** (CNPJ.ParsingError) invalid_verifier
  """
  @spec parse!(integer() | String.t()) :: CNPJ.t() | no_return()
  def parse!(number) do
    case parse(number) do
      {:ok, cnpj} -> cnpj
      {:error, error} -> raise error
    end
  end

  @doc """
  Returns an `:ok` tuple with a `cnpj` when the given `number` is valid.
  Otherwise returns an `:error` tuple with the error reason.

  Passing `number` as an integer is deprecated, since an integer cannot hold
  the letters of an alphanumeric CNPJ. Pass a string instead.

  ## Examples

      iex> CNPJ.parse("30794968000106")
      {:ok, %CNPJ{digits: "30794968000106"}}

      iex> CNPJ.parse("70.947.414/0001-08")
      {:ok, %CNPJ{digits: "70947414000108"}}

      iex> CNPJ.parse("12.ABC.345/01DE-35")
      {:ok, %CNPJ{digits: "12ABC34501DE35"}}

      iex> CNPJ.parse(30794968000106)
      {:ok, %CNPJ{digits: "30794968000106"}}

      iex> CNPJ.parse(82)
      {:error, %CNPJ.ParsingError{reason: :invalid_verifier}}
  """
  @spec parse(integer() | String.t()) :: {:ok, CNPJ.t()} | {:error, ParsingError.t()}
  def parse(
        <<first_digits::bytes-size(2), ".", second_digits::bytes-size(3), ".",
          third_digits::bytes-size(3), "/", fourth_digits::bytes-size(4), "-",
          last_digits::bytes-size(2)>>
      ) do
    parse(first_digits <> second_digits <> third_digits <> fourth_digits <> last_digits)
  end

  def parse(number) when is_binary(number), do: parse_digits(number)

  def parse(number) when is_positive_integer(number) do
    number |> Integer.to_string() |> parse_digits()
  end

  def parse(0), do: {:error, %ParsingError{reason: :all_zero_digits}}

  def parse(number) when is_integer(number) do
    {:error, %ParsingError{reason: :invalid_format}}
  end

  defp parse_digits(""), do: {:error, %ParsingError{reason: :invalid_format}}

  defp parse_digits(digits) do
    padded = String.pad_leading(digits, @length, "0")

    cond do
      not alphanumeric?(digits) -> {:error, %ParsingError{reason: :invalid_format}}
      byte_size(digits) > @length -> {:error, %ParsingError{reason: :too_long}}
      not numeric?(check_digits(padded)) -> {:error, %ParsingError{reason: :invalid_format}}
      padded == @zeros -> {:error, %ParsingError{reason: :all_zero_digits}}
      true -> verify(padded)
    end
  end

  defp alphanumeric?(digits) do
    digits |> String.to_charlist() |> Enum.all?(&(&1 in ?0..?9 or &1 in ?A..?Z))
  end

  defp numeric?(digits) do
    digits |> String.to_charlist() |> Enum.all?(&(&1 in ?0..?9))
  end

  defp check_digits(digits), do: binary_part(digits, @length - 2, 2)

  defp verify(digits) do
    values = to_values(digits)

    v1 = verifier(values, @v1_weights)
    v2 = verifier(values, @v2_weights)

    [input_v1, input_v2] = Enum.take(values, -2)

    if v1 == input_v1 and v2 == input_v2 do
      {:ok, %CNPJ{digits: digits}}
    else
      {:error, %ParsingError{reason: :invalid_verifier}}
    end
  end

  # ASCII code minus 48, per the Receita Federal: 0-9 keep their value, A-Z become 17-42.
  defp to_values(digits) do
    digits |> String.to_charlist() |> Enum.map(&(&1 - ?0))
  end

  defp verifier(values, weights) do
    acc =
      weights
      |> Enum.zip(values)
      |> Enum.reduce(0, fn {weight, value}, acc ->
        acc + weight * value
      end)

    verififer = 11 - rem(acc, 11)
    if verififer >= 10, do: 0, else: verififer
  end

  @doc """
  Returns `true` if given `number` is a valid CNPJ, otherwise `false`.

  Passing `number` as an integer is deprecated, since an integer cannot hold
  the letters of an alphanumeric CNPJ. Pass a string instead.

  ## Examples

      iex> CNPJ.valid?("87")
      false

      iex> CNPJ.valid?("30794968000106")
      true

      iex> CNPJ.valid?("70.947.414/0001-08")
      true

      iex> CNPJ.valid?("12.ABC.345/01DE-35")
      true

      iex> CNPJ.valid?(30794968000106)
      true

      iex> CNPJ.valid?(87)
      false
  """
  @spec valid?(integer() | String.t()) :: boolean
  def valid?(number) do
    case parse(number) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
