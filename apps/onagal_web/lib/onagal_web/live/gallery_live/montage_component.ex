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
    <div class="w-5/6">
      <div class="container m-auto grid grid-cols-6 grid-rows-4 bg-green-100 gap-1">
        <div :for={image <- @images.entries} class="bg-orange-100 py-1 border-1 border-zinc-400">
          <.gallery_image
            socket={@socket}
            image={image}
            selected_images={@selected_images}
          >
          </.gallery_image>
        </div>
      </div>

      <div class="container m-auto grid grid-cols-6 bg-green-100 gap-1">
        <div :if={@images.metadata.before} class="justify-center col-start-3 col-span-1 page-item">
          <.link patch={Routes.gallery_index_path(@socket, :index, page: :prev)}
                  class="page-link relative block m-1 py-1.5 px-3 rounded border-0 outline-none
                          transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none
                          bg-green-400"
          >
            <div class="col-start-1 col-span-2 text-white font-bold">&lt;&lt; Prev Page</div>
          </.link>
        </div>

        <div :if={@images.metadata.after} class="justify-center col-start-4 col-span-1 page-item">
          <.link patch={Routes.gallery_index_path(@socket, :index, page: :next)}
                  class="page-link relative block m-1 py-1.5 px-3 rounded border-0 outline-none
                          transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none
                          bg-green-400"
          >
            <div class="col-start-5 col-span-2 text-white font-bold">Next Page &gt;&gt;</div>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def gallery_image(assigns) do
    ~H"""
      <div class="flex flex-col items-center content-center align-center gap-y-1">
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
      </div>
    """
  end

  defp image_is_selected(images, image) do
    if Enum.any?(images, fn x -> x == image.id end),
      do: "bg-yellow-500 hover:bg-yellow-700 text-white font-bold py-1 px-3 m-1 rounded",
      else: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-3 m-1 rounded"
  end

  defp thumbnail_for_image(image) do
    Images.resolve_thumbnail_path(image)
  end
end
