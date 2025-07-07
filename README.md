# mix tableau.new

Mix task to generate a new [Tableau](https://github.com/elixir-tools/tableau) website.

## Installation

```elixir
mix archive.install hex tableau_new
```

## --help

```
mix tableau.new <app_name> [<flags>]

Flags

--template    Template syntax to use. Options are heex, temple, eex. (optional, defaults to eex)
--js          JS bundler to use. Options are vanilla, bun, esbuild (optional, defaults to vanilla)
--css         CSS framework to use. Options are vanilla, tailwind. (optional, defaults to vanilla)
--help        Shows this help text.
--version     Shows task version.

Example

mix tableau.new my_awesome_site --template temple
mix tableau.new my_awesome_site --template eex --css tailwind
```
