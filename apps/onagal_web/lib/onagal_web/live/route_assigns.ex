defmodule OnagalWeb.RouteAssigns do
  # import Phoenix.LiveView
  # alias OnagalWeb.Router.Helpers, as: Routes

  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end
end
