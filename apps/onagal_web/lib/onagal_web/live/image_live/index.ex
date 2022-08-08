defmodule OnagalWeb.ImageLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
  alias Onagal.Images.Image

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :images, list_images())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Image")
    |> assign(:image, Images.get_image!(id))
  end

  # defp apply_action(socket, :new, _params) do
  #   socket
  #   |> assign(:page_title, "New Image")
  #   |> assign(:image, %Image{})
  # end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Images")
    |> assign(:image, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    image = Images.get_image!(id)
    # {:ok, _} = Images.delete_image(image)
    {:ok, _} = Onagal.Fs.cleanup_file(Images.full_image_path(image))

    {:noreply, assign(socket, :images, list_images())}
  end

  defp list_images do
    Images.list_images()
  end

  defp resolve_thumbnail_path(image) do
    if !File.exists?(Images.system_thumbnail_image_path(image)),
      do: Images.generate_thumbnail(image)

    Images.web_thumbnail_image_path(image)
  end
end
