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
    <div class="container px-5 py-2 mx-auto lg:pt-8 lg:px-32">
      <td>
        <.link :if={@prev_image.id != @image.id} patch={Routes.gallery_index_path(@socket, :show, @prev_image.id)}>
          Prev
        </.link>
      </td>

      <td>
        |
      </td>

      <td>
        <.link :if={@next_image.id != @image.id} patch={Routes.gallery_index_path(@socket, :show, @next_image.id)}>
          Next
        </.link>
      </td>

      <.link patch={Routes.gallery_index_path(@socket, :index)}>
        <img src={Routes.static_path(@socket, Images.web_image_path(@image))} style="width: 25vw; min-width: 320px;">
      </.link>

      <li :for={image_tag <- list_tags_as_options(@image.tags)} >
        <%= image_tag %>
      </li>
    </div>
    """
  end

  def list_tags_as_options(image_tags) do
    Enum.map(image_tags, fn tag -> tag.name end)
  end
end
