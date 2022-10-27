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
        <div :for={image <- @images.entries} class="w-1/6 bg-orange-100 py-1 border-2 border-zinc-400">
          <.gallery_image
            socket={@socket}
            image={image}
            selected_images={@selected_images}
          >
          </.gallery_image>
        </div>
      </div>

      <div class="flex justify-center">
        <ul class="flex list-style-none">
          <li :if={@images.page_number > 1} class="page-item">
            <.link patch={Routes.gallery_index_path(@socket, :index, page: @images.page_number - 1)}
                    class="page-link relative block m-1 py-1.5 px-3 rounded border-0 outline-none
                           transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none
                           bg-green-400"
            >
              <div class="text-white font-bold">&lt;&lt; Prev Page</div>
            </.link>
          </li>

          <li :if={@images.page_number < @images.total_pages} class="page-item">
            <.link patch={Routes.gallery_index_path(@socket, :index, page: @images.page_number + 1)}
                    class="page-link relative block m-1 py-1.5 px-3 rounded border-0 outline-none
                           transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none
                           bg-green-400"
            >
            <div class="text-white font-bold">Next Page &gt;&gt;</div>
            </.link>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def gallery_image(assigns) do
    ~H"""
      <div class="p-1">
          <.link
            patch={Routes.gallery_index_path(@socket, :show, @image)}
          >
            <img id={"image-#{@image.id}"}
              class="p1 block object-scale-down h-120 w-120 rounded-lg border-2 border-black"
              src={thumbnail_for_image(@image)}
              alt={@image.original_name}>
          </.link>
      </div>
      <div class="">
          <button
            type="button"
            phx-click="select_image"
            value={@image.id}
            class={image_is_selected(@selected_images, @image)}
          >
            Select
          </button>
      </div>
    """
  end

  defp image_is_selected(images, image) do
    if Enum.any?(images, fn x -> x == image.id end),
      do: "bg-yellow-500 hover:bg-yellow-700 text-white font-bold py-1 px-3 m-1 rounded w-1/2",
      else: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-3 m-1 rounded w-1/2"
  end

  defp thumbnail_for_image(image) do
    Images.resolve_thumbnail_path(image)
  end
end
