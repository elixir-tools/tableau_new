[
  import_deps: [<%= if @template == "temple" do %>:temple<% end %>],
  plugins: [<%= if @template == "heex" do %>Phoenix.LiveView.HTMLFormatter<% end %>],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
