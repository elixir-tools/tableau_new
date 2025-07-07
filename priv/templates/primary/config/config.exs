import Config

config :tableau, :reloader,
  patterns: [
    ~r"^lib/.*.ex",
    ~r"^(_posts|_pages)/.*.md",<%= if @css == "tailwind" or @js == "esbuild" do %>
    ~r"^assets/.*.(css|js)"<% else %>~r"^extra/.*.(css|js)"<% end %>
  ]

config :web_dev_utils, :reload_log, true
# uncomment this if you use something like ngrok
# config :web_dev_utils, :reload_url, "'wss://' + location.host + '/ws'"

<%= if @template == "temple" do %>
config :temple,
  engine: EEx.SmartEngine,
  attributes: {Temple, :attributes}
<% end %><%= if @js == "esbuild" do %>
config :esbuild,
  version: "0.25.5",
  default: [
    args: ~w(js/site.js --bundle --target=es2016 --outdir=../_site/js),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
<% end %><%= if @css == "tailwind" do %>
config :tailwind,
  version: "4.1.0",
  default: [
    args: ~w(
    --input=assets/css/site.css
    --output=_site/css/site.css
    )
  ]
<% end %><%= if @js == "bun" do %>
config :bun,
  version: "1.2.4",
  install: [
    args: ~w(install)
  ],
  default: [
    args: ~w(
    build 
    assets/js/site.js  
    --outdir=_site/js
    )
  ]<% end %><%= if @css == "tailwind-bun" do %>,
  css: [
    args: ~w(
    run tailwindcss
    --input=assets/css/site.css
    --output=_site/css/site.css
    )
  ]<% end %>
config :tableau, :assets, [<%= if @css == "tailwind" do %>
  tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]},<% end %><%= if @js == "esbuild" do %>
  esbuild: {Esbuild, :install_and_run, [:default, ~w(--watch)]},<% end %><%= if @js == "bun" do %>
  bun: {Bun, :install_and_run, [:default, ~w(--watch)]},<% end %><%= if @css == "tailwind-bun" do %>
  tailwind: {Bun, :install_and_run, [:css, ~w(--watch)]},<% end %>
]

config :tableau, :config,
  url: "http://localhost:4999",
  markdown: [
    mdex: [
      extension: [
        table: true,
        header_ids: "",
        tasklist: true,
        strikethrough: true,
        autolink: true,
        alerts: true,
        footnotes: true
      ],
      render: [unsafe: true],
      syntax_highlight: [formatter: {:html_inline, theme: "neovim_dark"}]
    ]
  ]

config :tableau, Tableau.PageExtension, enabled: true
config :tableau, Tableau.PostExtension, enabled: true
config :tableau, Tableau.DataExtension, enabled: true
config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: <%= inspect(to_string(@app)) %>,
  description: "My beautiful website"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"

