defmodule OnagalWeb.GalleryLive.MontageComponent do
  use OnagalWeb, :live_component

  alias Onagal.Images

  def update(
        %{id: "montage", images: images, selected_images: selected_images} = _assigns,
        socket
      ) do
    socket =
      socket
      |> assign(:images, images)
      |> assign(:selected_images, selected_images)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul class="imglist">
        <%= for image <- @images.entries do %>
          <li>
            <div>
              <%= live_patch to: Routes.gallery_index_path(@socket, :show, image) do %>
              <img id={"image-#{image.id}"}
                  class={image_is_selected(@selected_images, image)}
                  src={thumbnail_for_image(image)}
                  alt={image.original_name}>
              <% end %>
            </div>
            <div>
              <button
                type="button"
                phx-click="select_image"
                value={image.id}
                class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded"
              >
                Select
              </button>
            </div>
          </li>
        <% end %>
      </ul>

      <div class="pagination">
        <%= if @images.page_number > 1 do %>
          <%= live_patch "<< Prev Page",
              to: Routes.gallery_index_path(@socket, :index, page: @images.page_number - 1),
              class: "pagination-link" %>
        <% end %>

        <%= if @images.page_number < @images.total_pages do %>
          <%= live_patch "Next Page >>",
              to: Routes.gallery_index_path(@socket, :index, page: @images.page_number + 1),
              class: "pagination-link" %>
        <% end %>
      </div>
    </div>
    """
  end

  defp image_is_selected(images, image) do
    if Enum.any?(images, fn x -> x == image.id end), do: "selected", else: "unselected"
  end

  defp thumbnail_for_image(image) do
    Images.resolve_thumbnail_path(image)
  end
end
