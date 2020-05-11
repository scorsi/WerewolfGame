%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Consistency.TabsOrSpaces},
        {Credo.Check.Design.AliasUsage, priority: :low},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, parens: true},
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Warning.LazyLogging, false},
      ]
    }
  ]
}
