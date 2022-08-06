defmodule OnagalWeb.ImageLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @managed_path System.get_env("MANAGE_DIR")
  @managed_web_path "/managed_images"

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
    # FIX: handle these paths in a better way
    Regex.replace(~r/^#{@managed_path}/, Images.full_image_path(image), @managed_web_path)
  end

  defp get_image_path(_), do: "/images/phoenix.png"

  defp page_title(:show), do: "Show Image"
  defp page_title(:edit), do: "Edit Image"
end
