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
      <section class="overflow-hidden text-gray-700 ">
        <div class="container px-5 py-2 mx-auto lg:pt-8 lg:px-8">
          <div class="flex flex-wrap -m-1 md:-m-2">

            <%= for image <- @images.entries do %>
              <div class="flex  w-1/5">
                <div class="p-1 md:p-5">
                  <%= live_patch to: Routes.gallery_index_path(@socket, :show, image) do %>
                    <img id={"image-#{image.id}"}
                      class={image_is_selected(@selected_images, image)}
                      src={thumbnail_for_image(image)}
                      alt={image.original_name}>
                  <% end %>
                  <button
                    type="button"
                    phx-click="select_image"
                    value={image.id}
                    class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded"
                  >
                    Select
                  </button>
                </div>
              </div>
            <% end %>

          </div>
        </div>

        <div class="flex justify-center">
          <ul class="flex list-style-none">
            <%= if @images.page_number > 1 do %>
              <li class="page-item">
                <%= live_patch "<< Prev Page",
                    to: Routes.gallery_index_path(@socket, :index, page: @images.page_number - 1),
                    class: "page-link relative block py-1.5 px-3 rounded border-0 bg-transparent outline-none transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none" %>
              </li>
            <% end %>

            <%= if @images.page_number < @images.total_pages do %>
              <li class="page-item">
                <%= live_patch "Next Page >>",
                      to: Routes.gallery_index_path(@socket, :index, page: @images.page_number + 1),
                      class: "page-link relative block py-1.5 px-3 rounded border-0 bg-transparent outline-none transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none" %>
              </li>
            <% end %>
          </ul>
        </div>
      </section>

    </div>
    """
  end

  defp image_is_selected(images, image) do
    if Enum.any?(images, fn x -> x == image.id end),
      do:
        "block scale-100 object-cover object-center w-full h-full rounded-lg border-4 border-red-500",
      else:
        "block scale-100 object-cover object-center w-full h-full rounded-lg border-4 border-black"
  end

  defp thumbnail_for_image(image) do
    Images.resolve_thumbnail_path(image)
  end
end
