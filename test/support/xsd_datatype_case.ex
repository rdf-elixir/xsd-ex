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

    comparable_datatypes =
      (base_hierarchy_path(Macro.expand_once(datatype, __CALLER__)) ++
         Keyword.get(opts, :comparable_datatypes, []))
      |> Enum.map(fn datatype -> Macro.expand_once(datatype, __CALLER__) end)

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
            test "lexical of canonicalized #{unquote(datatype)} #{inspect(input, limit: 9)} is #{
                   inspect(canonicalized)
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

      test "XSD.Datatype.comparable?/2" do
        Enum.each(XSD.datatypes(), fn other_datatype ->
          if other_datatype in unquote(comparable_datatypes) or
               Enum.any?(unquote(comparable_datatypes), fn comparable_datatype ->
                 XSD.Datatype.derived_from?(other_datatype, comparable_datatype)
               end) do
            assert XSD.Datatype.comparable?(unquote(datatype), other_datatype) == true,
                   "expected #{unquote(datatype)} to be comparable to #{other_datatype}"
          else
            assert XSD.Datatype.comparable?(unquote(datatype), other_datatype) == false,
                   "expected #{unquote(datatype)} not to be comparable to #{other_datatype}"
          end
        end)
      end
    end
  end

  def dt(value) do
    {:ok, date, _} = DateTime.from_iso8601(value)
    date
  end

  defp base_hierarchy_path(datatype, super_datatypes \\ [])
  defp base_hierarchy_path(nil, super_datatypes), do: super_datatypes

  defp base_hierarchy_path(datatype, super_datatypes) do
    [datatype | base_hierarchy_path(datatype.base, super_datatypes)]
  end
end
