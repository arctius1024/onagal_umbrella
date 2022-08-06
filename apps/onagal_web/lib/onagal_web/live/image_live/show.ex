defmodule OnagalWeb.ImageLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, Images.get_image!(id))
     |> assign(:image_path, Routes.static_path(socket, get_image_path(Images.get_image!(id))))}
  end

  defp get_image_path(%Images.Image{} = image) do
    # FIX: original path and /managed_images should be configured
    Regex.replace(~r/^\/home\/ssawyer\/manage/, Images.full_image_path(image), "/managed_images")
  end

  defp get_image_path(_), do: "/images/phoenix.png"

  defp page_title(:show), do: "Show Image"
  defp page_title(:edit), do: "Edit Image"
end
