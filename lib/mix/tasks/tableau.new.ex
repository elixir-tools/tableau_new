defmodule Mix.Tasks.Tableau.New do
  @help """
  mix tableau.new <app_name> [<flags>]

  Flags

  --template    Template syntax to use. Options are heex, temple, eex. (optional, defaults to eex)
  --js          JS bundler to use. Options are vanilla, bun, esbuild (optional, defaults to vanilla)
  --css         Asset framework to use. Options are vanilla, tailwind. (optional, defaults to vanilla)
  --help        Shows this help text.
  --version     Shows task version.

  Example

  mix tableau.new my_awesome_site
  mix tableau.new my_awesome_site --template temple --js bun --css tailwind
  """
  @moduledoc @help
  @shortdoc "Generate a new Tableau website"

  @generator_version Mix.Project.config()[:version]

  use Mix.Task

  def run(argv) do
    {opts, argv} =
      OptionParser.parse!(argv,
        strict: [
          js: :string,
          css: :string,
          template: :string,
          help: :boolean,
          version: :boolean
        ]
      )

    opts =
      case Keyword.validate(opts, [:css, :js, :template, help: false, version: false]) do
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
    templates = :tableau_new |> :code.priv_dir() |> Path.join("templates")

    css =
      if opts[:js] == "bun" and opts[:css] == "tailwind" do
        "tailwind-bun"
      else
        opts[:css]
      end

    assigns = [
      app: app,
      app_module: Macro.camelize(app),
      template: opts[:template],
      js: opts[:js],
      css: css
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

    Mix.Generator.create_file(Path.join(app, "_pages/.keep"), "")
    Mix.Generator.create_file(Path.join(app, "_wip/.keep"), "")

    Mix.Generator.create_file(Path.join(app, "_posts/.keep"), "")
    Mix.Generator.create_file(Path.join(app, "_draft/.keep"), "")

    Mix.Generator.create_file(Path.join(app, "extra/.keep"), "")

    for source <- Path.wildcard(Path.join(templates, "primary/**/*.{ex,exs}")) do
      copy_templates(source, templates, "primary", app, assigns)
    end

    case opts[:template] do
      "temple" ->
        for source <- Path.wildcard(Path.join(templates, "temple/**/*.{ex,exs}")) do
          copy_templates(source, templates, "temple", app, assigns)
        end

      "heex" ->
        for source <- Path.wildcard(Path.join(templates, "heex/**/*.{ex,exs}")) do
          copy_templates(source, templates, "heex", app, assigns)
        end

      template when template in ["eex", nil] ->
        for source <- Path.wildcard(Path.join(templates, "eex/**/*.{ex,exs}")) do
          copy_templates(source, templates, "eex", app, assigns)
        end

      value ->
        Mix.shell().error("""
        Unknown template value: --template=#{value}

        See help text for more information.
        """)

        System.halt(1)
    end

    case opts[:js] do
      "esbuild" ->
        for source <- Path.wildcard(Path.join(templates, "esbuild/**/*.{css,js}")) do
          copy_templates(source, templates, "esbuild", app, assigns)
        end

      "bun" ->
        for source <- Path.wildcard(Path.join(templates, "bun/**/*.{css,js,json}")) do
          copy_templates(source, templates, "bun", app, assigns)
        end

      js when js in ["vanilla", nil] ->
        for source <- Path.wildcard(Path.join(templates, "no_assets/**/*.{js}")) do
          copy_templates(source, templates, "no_assets", app, assigns)
        end

      js ->
        Mix.shell().error("""
        Unknown js value: --js=#{js}

        See help text for more information.
        """)

        System.halt(1)
    end

    case opts[:css] do
      "tailwind" ->
        for source <- Path.wildcard(Path.join(templates, "tailwind/**/*.{css,js}")) do
          copy_templates(source, templates, "tailwind", app, assigns)
        end

      css when css in ["vanilla", nil] ->
        for source <- Path.wildcard(Path.join(templates, "no_assets/**/*.{css}")) do
          copy_templates(source, templates, "no_assets", app, assigns)
        end

      css ->
        Mix.shell().error("""
        Unknown css value: --css=#{css}

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

  defp copy_templates(source, templates, app, kind, assigns) do
    target =
      source
      |> Path.relative_to(Path.join(templates, kind))
      |> String.replace("app_name", app)
      |> then(&Path.join(app, &1))

    Mix.Generator.copy_template(source, target, assigns)
  end
end
