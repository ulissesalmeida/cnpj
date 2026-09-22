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

  describe "valid? for integers" do
    import CNPJ, only: [valid?: 1]

    for {input, expected} <- @test_table do
      @input input
      @expected expected

      test "returns #{@expected} when input is #{@input}" do
        assert valid?(@input) == @expected
      end
    end
  end

  describe "valid? for strings" do
    import CNPJ, only: [valid?: 1]

    for {input, expected} <- @test_table do
      @input to_string(input)
      @expected expected

      test "returns #{@expected} when input is #{@input}" do
        assert valid?(@input) == @expected
      end
    end

    test "returns false when with leading characters" do
      refute valid?(" 31512740000130")
    end

    test "returns false when with trailing characters" do
      refute valid?("31512740000130 ")
    end

    test "returns true for formatted numbers" do
      assert valid?("21.657.784/0001-03")
    end

    test "returns false for malformatted numbers" do
      refute valid?("21.657.784/0001->03")
    end
  end

  describe "parse!" do
    import CNPJ, only: [parse!: 1]

    test "returns CNPJ type for valid integers" do
      assert %CNPJ{} = cnpj = parse!(13_118_061_000_108)
      assert CNPJ.digits(cnpj) == {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}
    end

    test "returns CNPJ type for valid strings" do
      assert %CNPJ{} = cnpj = parse!("13118061000108")
      assert CNPJ.digits(cnpj) == {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}
    end

    test "returns CNPJ type for formatted valid strings" do
      assert %CNPJ{} = cnpj = parse!("13.118.061/0001-08")
      assert CNPJ.digits(cnpj) == {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}
    end

    test "raises an exception for invalid integers" do
      error =
        assert_raise CNPJ.ParsingError, fn ->
          parse!(13_118_062_000_108)
        end

      assert error.reason == :invalid_verifier
    end

    test "raises an exception for too long integers" do
      error =
        assert_raise CNPJ.ParsingError, fn ->
          parse!(1_232_113_118_062_000_108)
        end

      assert error.reason == :too_long
    end

    test "raises an exception for invalid strings" do
      error =
        assert_raise CNPJ.ParsingError, fn ->
          parse!("13.118.061/0001.08")
        end

      assert error.reason == :invalid_format
    end

    test "raises an exception for 0 numbers" do
      error =
        assert_raise CNPJ.ParsingError, fn ->
          parse!(0)
        end

      assert error.reason == :all_zero_digits
    end
  end

  describe "parse" do
    import CNPJ, only: [parse: 1]

    test "returns ok with CNPJ type for valid integers" do
      assert {:ok, %CNPJ{} = cnpj} = parse(13_118_061_000_108)
      assert CNPJ.digits(cnpj) == {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}
    end

    test "returns ok with CNPJ type for valid strings" do
      assert {:ok, %CNPJ{} = cnpj} = parse("13118061000108")
      assert CNPJ.digits(cnpj) == {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}
    end

    test "returns ok with CNPJ type for formatted valid strings" do
      assert {:ok, %CNPJ{} = cnpj} = parse("13.118.061/0001-08")
      assert CNPJ.digits(cnpj) == {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}
    end

    test "returns error for invalid integers" do
      {:error, error} = parse(13_118_062_000_108)

      assert error.reason == :invalid_verifier
    end

    test "returns error for too long integers" do
      {:error, error} = parse(1_232_113_118_062_000_108)

      assert error.reason == :too_long
    end

    test "returns error for invalid strings" do
      {:error, error} = parse("13.118.061/0001.08")

      assert error.reason == :invalid_format
    end

    test "returns error for 0 numbers" do
      {:error, error} = parse(0)

      assert error.reason == :all_zero_digits
    end
  end

  describe "format/1" do
    import CNPJ, only: [format: 1]

    test "returns formatted CNPJ" do
      assert 13_118_061_000_108 |> CNPJ.parse!() |> format() == "13.118.061/0001-08"
    end

    test "returns formatted CNPJ when it has a leading zero" do
      assert "04679346000119" |> CNPJ.parse!() |> format() == "04.679.346/0001-19"
    end

    test "returns formatted alphanumeric CNPJ" do
      assert "12ABC34501DE35" |> CNPJ.parse!() |> format() == "12.ABC.345/01DE-35"
    end
  end

  describe "alphanumeric CNPJs" do
    for input <- [
          "12ABC34501DE35",
          "12.ABC.345/01DE-35",
          "A1B2C3D4E5F668",
          "ZZZZZZZZZZZZ62",
          "0000000000A122",
          "AB.000.000/0001-62"
        ] do
      @input input

      test "valid? returns true for #{@input}" do
        assert CNPJ.valid?(@input)
      end
    end

    test "returns invalid_verifier for a wrong check digit" do
      {:error, error} = CNPJ.parse("12ABC34501DE36")

      assert error.reason == :invalid_verifier
    end

    test "returns invalid_format for lowercase letters" do
      {:error, error} = CNPJ.parse("12abc34501de35")

      assert error.reason == :invalid_format
    end

    test "returns invalid_format for letters in the check digits" do
      {:error, error} = CNPJ.parse("12ABC34501DEAB")

      assert error.reason == :invalid_format
    end

    test "returns invalid_format for symbols" do
      {:error, error} = CNPJ.parse("12ABC345#1DE35")

      assert error.reason == :invalid_format
    end
  end

  describe "digits/2" do
    test "returns strings for an alphanumeric CNPJ with :cnpj_2026" do
      cnpj = CNPJ.parse!("12ABC34501DE35")

      assert CNPJ.digits(cnpj, :cnpj_2026) ==
               {"1", "2", "A", "B", "C", "3", "4", "5", "0", "1", "D", "E", "3", "5"}
    end

    test "returns strings for a numeric CNPJ with :cnpj_2026" do
      cnpj = CNPJ.parse!("13118061000108")

      assert CNPJ.digits(cnpj, :cnpj_2026) ==
               {"1", "3", "1", "1", "8", "0", "6", "1", "0", "0", "0", "1", "0", "8"}
    end

    test "returns integers for a numeric CNPJ with :cnpj_pre_2026" do
      cnpj = CNPJ.parse!("13118061000108")

      assert CNPJ.digits(cnpj, :cnpj_pre_2026) == {1, 3, 1, 1, 8, 0, 6, 1, 0, 0, 0, 1, 0, 8}
    end

    test "raises for an alphanumeric CNPJ with :cnpj_pre_2026" do
      cnpj = CNPJ.parse!("12ABC34501DE35")

      assert_raise CNPJ.UnsupportedVersionError, fn -> CNPJ.digits(cnpj, :cnpj_pre_2026) end
    end

    test "digits/1 raises for an alphanumeric CNPJ" do
      cnpj = CNPJ.parse!("12ABC34501DE35")

      assert_raise CNPJ.UnsupportedVersionError, fn -> CNPJ.digits(cnpj) end
    end
  end
end
