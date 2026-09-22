defmodule CNPJ.UnsupportedVersionError do
  @moduledoc """
  Raised when a CNPJ with letters is read with the pre-2026, digits-only API.
  """

  defexception message: "CNPJ has letters; use CNPJ.digits(cnpj, :cnpj_2026) instead"
end
