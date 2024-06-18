defmodule <%= @app_module %>.PostLayout do
  use <%= @app_module %>.Component
  use Tableau.Layout, layout: <%= @app_module %>.RootLayout

  def template(assigns) do
    temple do
      render(@inner_content)
    end
  end
end

