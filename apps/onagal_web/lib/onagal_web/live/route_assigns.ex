defmodule OnagalWeb.RouteAssigns do
  import Phoenix.LiveView
  alias OnagalWeb.Router.Helpers, as: Routes

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> assign(
        :main_menus,
        [
          {"Images", Routes.gallery_index_path(socket, :index)},
          {"Tags", Routes.tag_index_path(socket, :index)},
          {"Tagsets", Routes.tagset_index_path(socket, :index)},
          {"Filtersets", Routes.filterset_index_path(socket, :index)}
        ]
      )
      |> assign(
        :logged_in_menus,
        [
          {"Settings", Routes.user_settings_path(socket, :edit)},
          {"Dashboard", Routes.live_dashboard_path(socket, :home)}
        ]
      )
      |> assign(
        :logged_out_menus,
        [
          {"Login", Routes.user_session_path(socket, :new)},
          {"Register", Routes.user_registration_path(socket, :new)}
        ]
      )

    IO.inspect(socket.assigns)

    {:cont,
     socket
     |> attach_hook(:set_menu_path, :handle_params, &manage_active_tabs/3)}
  end

  defp manage_active_tabs(_params, url, socket) do
    {:cont, assign(socket, current_path: URI.parse(url).path)}
  end
end
