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
      <div class="flex flex-row flex-wrap bg-yellow-100">
        <%= for image <- @images.entries do %>
          <div class="w-1/6 bg-orange-100 py-1 border-2 border-zinc-400">
            <.link
              patch={Routes.gallery_index_path(@socket, :show, image)}
            >
              <img id={"image-#{image.id}"}
                class={image_is_selected(@selected_images, image)}
                src={thumbnail_for_image(image)}
                alt={image.original_name}>
            </.link>

              <button
                type="button"
                phx-click="select_image"
                value={image.id}
                class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded"
              >
                Select
              </button>
          </div>
        <% end %>
      </div>

      <div class="flex justify-center">
        <ul class="flex list-style-none">
          <%= if @images.page_number > 1 do %>
            <li class="page-item">
              <.link patch={Routes.gallery_index_path(@socket, :index, page: @images.page_number - 1)}
                     class="page-link relative block py-1.5 px-3 rounded border-0 bg-transparent outline-none transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none"
              >
                &lt;&lt; Prev Page
              </.link>
            </li>
          <% end %>

          <%= if @images.page_number < @images.total_pages do %>
            <li class="page-item">
              <.link patch={Routes.gallery_index_path(@socket, :index, page: @images.page_number + 1)}
                     class="page-link relative block py-1.5 px-3 rounded border-0 bg-transparent outline-none transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none"
              >
                Next Page &gt;&gt;
              </.link>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp image_is_selected(images, image) do
    if Enum.any?(images, fn x -> x == image.id end),
      do: "block object-scale-down h-120 w-120 rounded-lg border-2 border-red-500",
      else: "block object-scale-down h-120 w-120 rounded-lg border-2 border-black"
  end

  defp thumbnail_for_image(image) do
    Images.resolve_thumbnail_path(image)
  end
end
