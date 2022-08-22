defmodule OnagalWeb.GalleryLive.MontageComponent do
  use OnagalWeb, :live_component

  alias Onagal.Images

  def update(
        %{id: "montage", images: images} = _assigns,
        socket
      ) do
    socket =
      socket
      |> assign(:images, images)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul class="imglist">
        <%= for image <- @images.entries do %>
          <li>
            <%= live_patch to: Routes.gallery_index_path(@socket, :show, image) do %>
              <img src={Images.resolve_thumbnail_path(image)} alt={image.original_name}>
            <% end %>
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
end
