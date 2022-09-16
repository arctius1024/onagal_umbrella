defmodule OnagalWeb.GalleryLive.DisplayComponent do
  use OnagalWeb, :live_component

  # alias Onagal.Images

  def update(
        %{
          id: "display",
          prev_image: prev_image,
          next_image: next_image,
          image_path: image_path,
          image: image
        } = _assigns,
        socket
      ) do
    socket =
      socket
      |> assign(:prev_image, prev_image)
      |> assign(:next_image, next_image)
      |> assign(:image_path, image_path)
      |> assign(:image, image)

    {:ok, socket}
  end

  def update(%{id: "display", image: image} = _assigns, socket) do
    {:ok, socket |> assign(:image, image)}
  end

  def render(assigns) do
    IO.puts("show render")

    ~H"""
    <ul>
      <table>
        <tr>
          <%= if @prev_image.id != @image.id do %>
            <td><%= live_patch "Prev", to: Routes.gallery_index_path(@socket, :show, @prev_image.id) %></td>
          <% else %>
            <td>Prev</td>
          <% end %>
          <%= if @next_image.id != @image.id do %>
            <td><%= live_patch "Next", to: Routes.gallery_index_path(@socket, :show, @next_image.id) %></td>
          <% else %>
            <td>Next</td>
          <% end %>
        </tr>
      </table>
      <div>
        <%= live_patch to: Routes.gallery_index_path(@socket, :index) do %>
          <img src={@image_path} style="width: 25vw; min-width: 320px;">
        <% end %>
      </div>
      <div>
        <ul class="imglist">
        <%= for image_tag <- list_tags_as_options(@image.tags) do %>
          <li><%= image_tag %></li>
        <% end %>
        </ul>
      </div>
    </ul>
    """
  end

  def list_tags_as_options(image_tags) do
    Enum.map(image_tags, fn tag -> tag.name end)
  end
end
