defmodule XSD.Datatype.Test.Case do
  use ExUnit.CaseTemplate

  using(opts) do
    datatype = Keyword.fetch!(opts, :datatype)
    datatype_name = Keyword.fetch!(opts, :name)

    datatype_iri =
      Keyword.get(opts, :iri, XSD.Datatype.Primitive.default_namespace() <> datatype_name)

    valid = Keyword.get(opts, :valid)
    invalid = Keyword.get(opts, :invalid)
    primitive = Keyword.get(opts, :primitive)
    base = unless primitive, do: Keyword.fetch!(opts, :base)
    base_primitive = unless primitive, do: Keyword.fetch!(opts, :base_primitive)
    applicable_facets = Keyword.get(opts, :applicable_facets, [])
    facets = Keyword.get(opts, :facets)

    quote do
      alias XSD.Datatype
      alias unquote(datatype)
      import unquote(__MODULE__)

      doctest unquote(datatype)

      @moduletag datatype: unquote(datatype)

      if unquote(valid) do
        @valid unquote(valid)
        @invalid unquote(invalid)

        test "registration" do
          assert unquote(datatype) in XSD.datatypes()
          assert XSD.datatype_by_name(unquote(datatype_name)) == unquote(datatype)
          assert XSD.datatype_by_iri(unquote(datatype_iri)) == unquote(datatype)
        end

        test "primitive/0" do
          assert unquote(datatype).primitive?() == unquote(!!primitive)
        end

        test "base/0" do
          if unquote(primitive) do
            assert unquote(datatype).base == nil
          else
            assert unquote(datatype).base == unquote(base)
          end
        end

        test "base_primitive/0" do
          if unquote(primitive) do
            assert unquote(datatype).base_primitive == unquote(datatype)
          else
            assert unquote(datatype).base_primitive == unquote(base_primitive)
          end
        end

        test "derived_from?/1" do
          assert unquote(datatype).derived_from?(unquote(datatype)) == true

          unless unquote(primitive) do
            assert unquote(datatype).derived_from?(unquote(base)) == true
            assert unquote(datatype).derived_from?(unquote(base_primitive)) == true
          end
        end

        test "applicable_facets/0" do
          assert MapSet.new(unquote(datatype).applicable_facets()) ==
                   MapSet.new(unquote(applicable_facets))
        end

        if unquote(facets) do
          test "facets" do
            Enum.each(unquote(facets), fn {facet, value} ->
              assert apply(unquote(datatype), facet, []) == value
            end)
          end
        end

        describe "general new" do
          Enum.each(@valid, fn {input, {value, lexical, _}} ->
            expected = %unquote(datatype){value: value, uncanonical_lexical: lexical}

            @tag example: %{input: input, output: expected}
            test "valid: #{unquote(datatype)}.new(#{inspect(input)})", %{example: example} do
              assert unquote(datatype).new(example.input) == example.output
            end
          end)

          Enum.each(@invalid, fn value ->
            expected = %unquote(datatype){
              uncanonical_lexical: unquote(datatype).init_invalid_lexical(value, [])
            }

            @tag example: %{input: value, output: expected}
            test "invalid: #{unquote(datatype)}.new(#{inspect(value)})",
                 %{example: example} do
              assert unquote(datatype).new(example.input) == example.output
            end
          end)

          test "canonicalize option" do
            Enum.each(@valid, fn {input, _} ->
              assert unquote(datatype).new(input, canonicalize: true) ==
                       unquote(datatype).new(input) |> unquote(datatype).canonical()
            end)

            Enum.each(@invalid, fn input ->
              assert unquote(datatype).new(input, canonicalize: true) ==
                       unquote(datatype).new(input) |> unquote(datatype).canonical()
            end)
          end
        end

        describe "general new!" do
          test "with valid values, it behaves the same as new" do
            Enum.each(@valid, fn {input, _} ->
              assert unquote(datatype).new!(input) == unquote(datatype).new(input)

              assert unquote(datatype).new!(input) ==
                       unquote(datatype).new(input)

              assert unquote(datatype).new!(input, canonicalize: true) ==
                       unquote(datatype).new(input, canonicalize: true)
            end)
          end

          test "with invalid values, it raises an error" do
            Enum.each(@invalid, fn value ->
              assert_raise ArgumentError, fn -> unquote(datatype).new!(value) end

              assert_raise ArgumentError, fn ->
                unquote(datatype).new!(value, canonicalize: true)
              end
            end)
          end
        end

        describe "general lexical" do
          Enum.each(@valid, fn {input, {_, lexical, canonicalized}} ->
            lexical = lexical || canonicalized
            @tag example: %{input: input, lexical: lexical}
            test "of valid #{unquote(datatype)}.new(#{inspect(input)})",
                 %{example: example} do
              assert unquote(datatype).new(example.input) |> unquote(datatype).lexical() ==
                       example.lexical
            end
          end)

          Enum.each(@invalid, fn value ->
            lexical = unquote(datatype).init_invalid_lexical(value, [])
            @tag example: %{input: value, lexical: lexical}
            test "of invalid #{unquote(datatype)}.new(#{inspect(value)}) == #{inspect(lexical)}",
                 %{example: example} do
              assert unquote(datatype).new(example.input) |> unquote(datatype).lexical() ==
                       example.lexical
            end
          end)
        end

        describe "general canonicalization" do
          Enum.each(@valid, fn {input, {value, _, _}} ->
            expected = %unquote(datatype){value: value}
            @tag example: %{input: input, output: expected}
            test "#{unquote(datatype)} #{inspect(input)}", %{example: example} do
              assert unquote(datatype).new(example.input) |> unquote(datatype).canonical() ==
                       example.output
            end
          end)

          Enum.each(@valid, fn {input, {_, _, canonicalized}} ->
            @tag example: %{input: input, canonicalized: canonicalized}
            test "lexical of canonicalized #{unquote(datatype)} #{inspect(input, limit: 4)} is #{
                   inspect(canonicalized, limit: 4)
                 }",
                 %{example: example} do
              assert unquote(datatype).new(example.input)
                     |> unquote(datatype).canonical()
                     |> unquote(datatype).lexical() ==
                       example.canonicalized
            end
          end)

          test "does not change the XSD datatype value when it is invalid" do
            Enum.each(@invalid, fn value ->
              assert unquote(datatype).new(value) |> unquote(datatype).canonical() ==
                       unquote(datatype).new(value)
            end)
          end
        end

        describe "general validation" do
          Enum.each(Map.keys(@valid), fn value ->
            @tag value: value
            test "#{inspect(value)} as a #{unquote(datatype)} is valid", %{value: value} do
              assert unquote(datatype).valid?(unquote(datatype).new(value))
            end
          end)

          Enum.each(@invalid, fn value ->
            @tag value: value
            test "#{inspect(value)} as a #{unquote(datatype)} is invalid", %{value: value} do
              refute unquote(datatype).valid?(unquote(datatype).new(value))
            end
          end)
        end
      end

      test "XSD.Datatype.matches?/3" do
        Enum.each(@valid, fn {input, {_, lexical, canonicalized}} ->
          lexical = lexical || canonicalized
          assert unquote(datatype).new(input) |> unquote(datatype).matches?(lexical, "q") == true
        end)
      end

      test "String.Chars protocol implementation" do
        Enum.each(@valid, fn {input, _} ->
          assert unquote(datatype).new(input) |> to_string() ==
                   unquote(datatype).new(input) |> unquote(datatype).lexical()
        end)
      end
    end
  end

  def dt(value) do
    {:ok, date, _} = DateTime.from_iso8601(value)
    date
  end
end
