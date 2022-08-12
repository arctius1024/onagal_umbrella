defmodule OnagalWeb.ImageLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_filter(session)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, session, socket) do
    image = Images.get_image!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, image)
     |> assign(:next_image, Images.get_next_image(image.id, socket.assigns.filter))
     |> assign(:prev_image, Images.get_prev_image(image.id, socket.assigns.filter))
     |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))}
  end

  @impl true
  def handle_info(%{"filter" => filters} = _info, socket) do
    {:noreply, socket |> assign(:filter, filters)}
  end

  defp page_title(:show), do: "Show Image"
  defp page_title(:edit), do: "Edit Image"

  defp put_session_filter(socket, session) do
    socket
    |> assign(:filter, get_session_filter(session))
  end

  defp get_session_filter(session) do
    Map.get(session, "filter", %{"tags" => ""})
  end
end
