defmodule <%= @app_module %>.PostLayout do
  use Tableau.Layout, layout: <%= @app_module %>.RootLayout
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <%= {:safe, render(@inner_content)} %>
    """
  end
end
