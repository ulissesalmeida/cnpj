defmodule CNPJ.Support.Helpers do
  @moduledoc false

  def fourteen_digits(digit) do
    0..13
    |> Enum.reduce(0, fn i, sum -> sum + :math.pow(10, i) * digit end)
    |> trunc()
  end
end

defmodule CNPJTest do
  use ExUnit.Case
  doctest CNPJ

  import CNPJ.Support.Helpers

  describe "valid?" do
    import CNPJ, only: [valid?: 1]

    @test_table [
                  {13_118_061_000_108, true},
                  {13_118_061_000_107, false},
                  {31_512_740_000_130, true},
                  {4_679_346_000_119, true},
                  {93_818_035_000_113, true},
                  {83_854_657_000_143, true},
                  {93_035_749_000_155, true},
                  {8_995_861_000_169, true},
                  {13_118_061_000_019, true},
                  {89_958_610_001_695_645_656_464_564_569, false},
                  {0, false}
                ] ++ Enum.map(1..9, &{fourteen_digits(&1), false})

    for {input, expected} <- @test_table do
      @input input
      @expected expected

      test "returns #{@expected} when input is #{@input}" do
        assert valid?(@input) == @expected
      end
    end
  end
end
