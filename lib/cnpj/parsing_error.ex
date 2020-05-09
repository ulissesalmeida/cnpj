defmodule CNPJ.ParsingError do
  defexception reason: nil

  @type t :: %__MODULE__{
          reason: :invalid_verifier | :invalid_format | :all_zero_digits | :too_long
        }

  @spec message(CNPJ.ParsingError.t()) :: binary
  def message(%__MODULE__{reason: reason}), do: to_string(reason)
end
