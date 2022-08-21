defmodule OnagalWeb.GalleryLive.MontageComponent do
  use OnagalWeb, :live_component

  alias Onagal.Images

  def update(
        %{id: "montage", page: page} = _assigns,
        socket
      ) do
    socket =
      socket
      |> assign(:page, page)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul class="imglist">
        <%= for image <- @page.entries do %>
          <li>
            <%= live_patch to: Routes.gallery_index_path(@socket, :show, image) do %>
              <img src={Images.resolve_thumbnail_path(image)} alt={image.original_name}>
            <% end %>
          </li>
        <% end %>
      </ul>

      <div class="pagination">
        <%= if @page.page_number > 1 do %>
          <%= live_patch "<< Prev Page",
              to: Routes.gallery_index_path(@socket, :index, page: @page.page_number - 1),
              class: "pagination-link" %>
        <% end %>

        <%= if @page.page_number < @page.total_pages do %>
          <%= live_patch "Next Page >>",
              to: Routes.gallery_index_path(@socket, :index, page: @page.page_number + 1),
              class: "pagination-link" %>
        <% end %>
      </div>
    </div>
    """
  end
end
