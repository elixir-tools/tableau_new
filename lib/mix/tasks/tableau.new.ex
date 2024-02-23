defmodule Mix.Tasks.Tableau.New do
  @help """
  mix tableau.new <app_name> [<flags>]

  Flags

  --template    Template syntax to use. Options are heex, temple, eex. (required)
  --assets      Asset framework to use. Options are vanilla, tailwind. (optional, defaults to vanilla)
  --help        Shows this help text.
  --version     Shows task version.

  Example

  mix tableau.new my_awesome_site
  mix tableau.new my_awesome_site --template temple
  mix tableau.new my_awesome_site --template eex --assets tailwind
  """
  @moduledoc @help
  @shortdoc "Generate a new Tableau website"

  use Mix.Task

  def run(argv) do
    {opts, argv} =
      OptionParser.parse!(argv,
        strict: [
          assets: :string,
          template: :string,
          help: :boolean,
          version: :boolean
        ]
      )

    opts =
      case Keyword.validate(opts, [:assets, :template, help: false, version: false]) do
        {:ok, opts} ->
          opts

        {:error, unknown} ->
          Mix.shell().error("Unknown options: #{Enum.map_join(unknown, &"--#{&1}")}")
          raise "Unknown options passed to `mix tableau.new`"
      end

    if opts[:help] do
      Mix.shell().info(@help)

      System.halt(0)
    end

    if opts[:version] do
      Mix.shell().info(Mix.Project.config()[:version])

      System.halt(0)
    end

    [app | _] = argv
    Mix.Generator.create_directory(app)
    templates = Path.join(:code.priv_dir(:tableau_new), "templates")

    assigns = [
      app: app,
      app_module: Macro.camelize(app),
      template: opts[:template],
      assets: opts[:assets]
    ]

    Mix.Generator.copy_template(
      Path.join(templates, "primary/README.md"),
      Path.join(app, "README.md"),
      assigns
    )

    Mix.Generator.copy_template(
      Path.join(templates, "primary/gitignore"),
      Path.join(app, ".gitignore"),
      assigns
    )

    Mix.Generator.copy_template(
      Path.join(templates, "primary/formatter.exs"),
      Path.join(app, ".formatter.exs"),
      assigns
    )

    for source <- Path.wildcard(Path.join(templates, "primary/**/*.{ex,exs}")) do
      target =
        Path.relative_to(source, Path.join(templates, "primary"))
        |> String.replace("app_name", app)

      Mix.Generator.copy_template(source, Path.join(app, target), assigns)
    end

    cond do
      opts[:template] == "temple" ->
        for source <- Path.wildcard(Path.join(templates, "temple/**/*.{ex,exs}")) do
          target =
            Path.relative_to(source, Path.join(templates, "temple"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      opts[:template] == "heex" ->
        for source <- Path.wildcard(Path.join(templates, "heex/**/*.{ex,exs}")) do
          target =
            Path.relative_to(source, Path.join(templates, "heex"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      opts[:template] == "eex" ->
        for source <- Path.wildcard(Path.join(templates, "eex/**/*.{ex,exs}")) do
          target =
            Path.relative_to(source, Path.join(templates, "eex"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      true ->
        Mix.shell().error("Unknown template value: --template=#{opts[:template]}")
        raise "Unknown template value: --template=#{opts[:template]}"
    end

    cond do
      opts[:assets] == "tailwind" ->
        for source <- Path.wildcard(Path.join(templates, "tailwind/**/*.{css,js}")) do
          target =
            Path.relative_to(source, Path.join(templates, "tailwind"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      opts[:assets] in ["vanilla", nil] ->
        for source <- Path.wildcard(Path.join(templates, "no_assets/**/*.{css}")) do
          target =
            Path.relative_to(source, Path.join(templates, "no_assets"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      true ->
        Mix.shell().error("Unknown assets value: --assets=#{opts[:assets]}")
        raise "Unknown assets value: --assets=#{opts[:assets]}"
    end
  end
end
