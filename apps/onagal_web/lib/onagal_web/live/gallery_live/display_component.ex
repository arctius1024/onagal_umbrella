defmodule OnagalWeb.GalleryLive.DisplayComponent do
  use OnagalWeb, :live_component

  alias Onagal.Images

  def update(
        %{
          id: "display",
          prev_image: prev_image,
          next_image: next_image,
          image: image
        } = _assigns,
        socket
      ) do
    socket =
      socket
      |> assign(:prev_image, prev_image)
      |> assign(:next_image, next_image)
      |> assign(:image, image)

    override_tags(image.tags)

    {:ok, socket}
  end

  def update(%{id: "display", image: image} = _assigns, socket) do
    override_tags(image.tags)

    {:ok, socket |> assign(:image, image)}
  end

  defp override_tags(tags) do
    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      selected_tags: list_tags_as_options(tags)
    )
  end

  def render(assigns) do
    IO.puts("show render")

    ~H"""
    <div class="container px-3 py-2 mx-auto lg:pt-8 lg:px-16">
      <ul class="flex list-style-none">
        <li>
          <.link :if={@prev_image.id != @image.id} patch={Routes.gallery_index_path(@socket, :show, @prev_image.id)}
            class="page-link relative block m-1 py-1.5 px-3 rounded border-0 outline-none
                    transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none
                    bg-green-400">
              <div class="text-white font-bold">Prev</div>
          </.link>
        </li>

        <li>
          <.link :if={@next_image.id != @image.id} patch={Routes.gallery_index_path(@socket, :show, @next_image.id)}
            class="page-link relative block m-1 py-1.5 px-3 rounded border-0 outline-none
                    transition-all duration-300 rounded text-gray-800 hover:text-gray-800 focus:shadow-none
                    bg-green-400">
          <div class="text-white font-bold">Next</div>
          </.link>
        </li>
      </ul>

      <.link patch={Routes.gallery_index_path(@socket, :index)}>
        <img src={Routes.static_path(@socket, Images.web_image_path(@image))} style="width: 25vw; min-width: 320px;">
      </.link>

      <div class="p-1">
        <span>Tags: </span>

        <ul>
          <li :for={image_tag <- list_tags_as_options(@image.tags)}
            class="text-orange-700">
            <%= image_tag %>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def list_tags_as_options(image_tags) do
    Enum.map(image_tags, fn tag -> tag.name end)
  end
end
