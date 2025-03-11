defmodule Mix.Tasks.Tableau.New do
  @help """
  mix tableau.new <app_name> [<flags>]

  Flags

  --template    Template syntax to use. Options are heex, temple, eex. (required)
  --assets      Asset framework to use. Options are vanilla, tailwind. (optional, defaults to vanilla)
  --help        Shows this help text.
  --version     Shows task version.

  Example

  mix tableau.new my_awesome_site --template temple
  mix tableau.new my_awesome_site --template eex --assets tailwind
  """
  @moduledoc @help
  @shortdoc "Generate a new Tableau website"

  @generator_version Mix.Project.config()[:version]

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
          System.halt(1)
      end

    if opts[:help] do
      Mix.shell().info(@help)

      System.halt(0)
    end

    if opts[:version] do
      Mix.shell().info(@generator_version)

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

    case opts[:template] do
      "temple" ->
        for source <- Path.wildcard(Path.join(templates, "temple/**/*.{ex,exs}")) do
          target =
            Path.relative_to(source, Path.join(templates, "temple"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      "heex" ->
        for source <- Path.wildcard(Path.join(templates, "heex/**/*.{ex,exs}")) do
          target =
            Path.relative_to(source, Path.join(templates, "heex"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      "eex" ->
        for source <- Path.wildcard(Path.join(templates, "eex/**/*.{ex,exs}")) do
          target =
            Path.relative_to(source, Path.join(templates, "eex"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      nil ->
        Mix.shell().error("""
        The --template option is required.

        See help text for more information.
        """)

        System.halt(1)

      _ ->
        Mix.shell().error("Unknown template value: --template=#{opts[:template]}")
        System.halt(1)
    end

    case opts[:assets] do
      "tailwind" ->
        for source <- Path.wildcard(Path.join(templates, "tailwind/**/*.{css,js}")) do
          target =
            Path.relative_to(source, Path.join(templates, "tailwind"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      assets when assets in ["vanilla", nil] ->
        for source <- Path.wildcard(Path.join(templates, "no_assets/**/*.{css}")) do
          target =
            Path.relative_to(source, Path.join(templates, "no_assets"))
            |> String.replace("app_name", app)

          Mix.Generator.copy_template(source, Path.join(app, target), assigns)
        end

      _ ->
        Mix.shell().error("""
        Unknown assets value: --assets=#{opts[:assets]}

        See help text for more information.
        """)

        System.halt(1)
    end

    Mix.shell().info("""
    Congratulations on your new site!

    Run the following to get started.

    cd #{app}
    mix deps.get

    # generate your first post
    mix #{app}.gen.post "My first post"

    # start the dev server
    mix tableau.server
    """)
  end
end
