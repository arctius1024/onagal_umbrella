defmodule OnagalWeb.ImageLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    image = Images.get_image!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, image)
     |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))}
  end

  defp page_title(:show), do: "Show Image"
  defp page_title(:edit), do: "Edit Image"
end
