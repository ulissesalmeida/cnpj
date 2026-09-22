# CNPJ

[![Hex.pm](https://img.shields.io/hexpm/v/cnpj)](https://www.hex.pm/packages/cnpj)
[![CircleCI](https://img.shields.io/circleci/build/github/ulissesalmeida/cnpj)](https://circleci.com/gh/ulissesalmeida/cnpj/tree/master)
[![Coveralls](https://img.shields.io/coveralls/github/ulissesalmeida/cnpj)](https://coveralls.io/github/ulissesalmeida/cnpj?branch=master)

CNPJ is an acronym for "Cadastro Nacional da Pessoa Jurídica," it's a identifier
number associated to companies that the Brazilian government maintains. With this
number, it is possible to check or retrieve information about a company.

This library provides a validation that checks if the number is a valid CNPJ
number. The CPF has check digit algorithm is similar to ISBN 10, you can check
the details in Portuguese [here](https://pt.wikipedia.org/wiki/Cadastro_Nacional_da_Pessoa_Jur%C3%ADdica).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cnpj` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cnpj, "~> 0.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cnpj](https://hexdocs.pm/cnpj).

## Quick Start

You can verify if a CNPJ is valid by calling the function `CNPJ.valid?/1`:

```elixir
CNPJ.valid?("13118061000108")
# => true

CNPJ.valid?("13.118.061/0001-07")
# => false

CNPJ.valid?("12.ABC.345/01DE-35")
# => true
```

## Parsing CNPJS

The `CNPJ.parse/1` and `CNPJ.parse!/1` returns you the CNPJ value wrapped in a custom type with explicit digits.

```elixir
CNPJ.parse("70947414000108")
# => {:ok, %CNPJ{digits: "70947414000108"}}

CNPJ.parse("70947414000109")
# => {:error, %CNPJ.ParsingError{reason: :invalid_verifier}}

CNPJ.parse!("70947414000108")
# => %CNPJ{digits: "70947414000108"}

CNPJ.parse!("70947414000109")
# => ** (CNPJ.ParsingError) invalid_verifier
```

## CNPJ Formatting

Create valid CNPJ and in sequence call `CNPJ.format/1`:

```elixir
iex> "70947414000108" |> CNPJ.parse!() |> CNPJ.format()
"70.947.414/0001-08"

iex> "12ABC34501DE35" |> CNPJ.parse!() |> CNPJ.format()
"12.ABC.345/01DE-35"
```

The `CNPJ.format/1` expects the CNPJ type.

## Alphanumeric CNPJs

Since July 2026 the Receita Federal also issues alphanumeric CNPJs: the first
twelve characters can be uppercase letters as well as digits, while the two
check digits stay numeric. Existing numeric CNPJs remain valid, and this
library accepts both.

The check digits are computed the same way for both formats. Each character is
worth its ASCII code minus 48, so digits keep their face value and letters go
from `A = 17` to `Z = 42`. Only uppercase letters are accepted, as the Receita
Federal specifies.

## Migrating to the new format

Integers cannot hold letters, so always pass CNPJs as strings. Integer input
still works for numeric CNPJs, but it is deprecated.

```elixir
# before
CNPJ.valid?(13_118_061_000_108)

# after
CNPJ.valid?("13118061000108")
```

`CNPJ.digits/1` is deprecated as well: it returns integers, so it raises
`CNPJ.UnsupportedVersionError` for a CNPJ with letters. Use `CNPJ.digits/2`
with the `:cnpj_2026` version, which returns strings and works with both
formats:

```elixir
# before
CNPJ.digits(cnpj)
# => {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}

# after
CNPJ.digits(cnpj, :cnpj_2026)
# => {"1", "3", "1", "1", "8", "0", "6", "1", "0", "0", "0", "1", "0", "8"}
```

If you still need integers for a numeric CNPJ, `CNPJ.digits(cnpj, :cnpj_pre_2026)`
keeps the old behavior.
