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
    {:cnpj, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cnpj](https://hexdocs.pm/cnpj).

## Quick Start

You can verify if a CNPJ is valid by calling the function `CNPJ.valid?/1`:

```elixir
CNPJ.valid?(13_118_061_000_108)
# => true

CNPJ.valid?(13_118_061_000_107)
# => false
```
