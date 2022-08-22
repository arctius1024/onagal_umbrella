defmodule OnagalWeb.GalleryLive.DisplayComponent do
  use OnagalWeb, :live_component

  # alias Onagal.Images

  def update(
        %{
          id: "display",
          prev_image: prev_image,
          next_image: next_image,
          image_path: image_path,
          image_id: image_id
        } = _assigns,
        socket
      ) do
    IO.puts("display update")

    socket =
      socket
      |> assign(:prev_image, prev_image)
      |> assign(:next_image, next_image)
      |> assign(:image_path, image_path)
      |> assign(:image_id, image_id)

    {:ok, socket}
  end

  def render(assigns) do
    IO.puts("show render")

    ~H"""
    <ul>
      <span><%= live_patch "Back", to: Routes.gallery_index_path(@socket, :index) %></span>
      <%= if @prev_image.id != @image_id do %>
        <span><%= live_patch "Prev", to: Routes.gallery_index_path(@socket, :show, @prev_image.id) %></span>
      <% end %>
      <img src={@image_path}>
      <%= if @next_image.id != @image_id do %>
        <span><%= live_patch "Next", to: Routes.gallery_index_path(@socket, :show, @next_image.id) %></span>
      <% end %>
    </ul>
    """
  end
end
