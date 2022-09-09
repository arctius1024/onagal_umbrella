defmodule OnagalWeb.GalleryLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
  alias Onagal.Tags
  alias Onagal.Paginate

  @impl true
  def mount(_params, session, socket) do
    IO.puts("handle_mount")

    socket =
      socket
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> assign_session_filter(session)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("handle_params")

    tag_filter = Map.get(socket.assigns, :tag_filter, [])
    tag_list = Onagal.Tags.list_tags_as_options()

    socket =
      socket
      |> assign(:tag_filter, tag_filter)
      |> assign(:tag_list, tag_list)
      |> assign(:image_tags, Map.get(socket.assigns, :image_tags, []))
      |> assign(:selected_images, Map.get(socket.assigns, :selected_images, []))

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # action handlers

  defp apply_action(socket, :index, params) do
    IO.puts("apply_action :index")

    send_filter_update(:filter, socket.assigns)

    socket
    |> assign(:images, list_images(params, socket.assigns.tag_filter))
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    IO.puts("apply_action :show")

    image = Images.get_image_with_tags(id)
    tag_filter = socket.assigns.tag_filter
    images = list_images(params, tag_filter)

    {_page, images} = Paginate.find_image_page(images, tag_filter, image)

    # Since we ensure we have the correct image page above, we shouldn't
    # have an issue being more than a page off.
    {:ok, prev_image} = get_prev_image(params, tag_filter, images, image)
    {:ok, next_image} = get_next_image(params, tag_filter, images, image)

    socket
    |> assign(:next_image, next_image)
    |> assign(:prev_image, prev_image)
    |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))
    |> assign(:image_id, image.id)
    |> assign(:image_tags, list_tags_as_options(image.tags))
  end

  # Filter helpers

  @impl true
  def handle_info({:live_session_updated, session}, socket) do
    IO.puts("test handle_info :live_session_updated")

    {:noreply, socket |> assign(:tag_filter, Map.get(session, "tag_filter", []))}
  end

  @impl true
  def handle_info({:tag_filter, [tags: tags, params: params]}, socket) do
    IO.puts("index handle_info :tag_filter")

    images = list_images(params, tags)

    image =
      case images.entries do
        [] -> Images.get_first()
        _ -> hd(images.entries)
      end

    send_filter_update(:filter, socket.assigns)

    # Remove all images from selected_images on filter change. This could be done
    # more selectively, but this works for now.
    socket = socket |> assign(:selected_images, [])

    case socket.assigns.live_action do
      :show -> send_filter_update({:show, socket: socket, images: images, image: image})
      :index -> send_filter_update(:index, {images, socket.assigns.selected_images})
    end

    PhoenixLiveSession.put_session(socket, "tag_filter", tags)

    {:noreply, socket |> assign(:images, images)}
  end

  @impl true
  def handle_info({:tag_images, [tags: tags, mode: mode, params: _params]}, socket) do
    IO.puts("index handle_info :tag_image")

    Enum.each(socket.assigns.selected_images, fn image_id ->
      image = Images.get_image_with_tags(image_id)

      case mode do
        :replace ->
          Tags.upsert_image_tags_by_name(image, tags)

        :add ->
          Enum.each(tags, fn tag ->
            Tags.add_tag_to_image(image, tag)
          end)
      end
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_selections", %{"value" => "clear"}, socket) do
    IO.puts("index handle_event clear_selections")

    {:noreply, socket |> assign(:selected_images, [])}
  end

  @impl true
  @spec handle_event(<<_::96>>, map, any) :: {:noreply, any}
  def handle_event("select_image", %{"value" => image_id}, socket) do
    IO.puts("index handle_event select_image")
    image_id = String.to_integer(image_id)

    new_selected_images =
      cond do
        Enum.any?(socket.assigns.selected_images, fn x -> x == image_id end) ->
          socket.assigns.selected_images -- [image_id]

        true ->
          [image_id | socket.assigns.selected_images]
      end

    socket = socket |> assign(:selected_images, new_selected_images)

    # IO.inspect(socket.assigns.selected_images)

    {:noreply, socket}
  end

  defp send_filter_update(
         :filter,
         %{tag_filter: tags, tag_list: tag_list, image_tags: image_tags} = _assigns
       ) do
    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      tag_filter: tags,
      tag_list: tag_list,
      image_tags: image_tags
    )
  end

  defp send_filter_update(:index, {images, selected_images}) do
    IO.puts("index send_filter_update 1")

    send_update(
      OnagalWeb.GalleryLive.MontageComponent,
      id: "montage",
      images: images,
      selected_images: selected_images
    )
  end

  defp send_filter_update({:show, [socket: socket, images: images, image: image]}) do
    IO.puts("index send_filter_update 2")

    send_update(
      OnagalWeb.GalleryLive.DisplayComponent,
      id: "display",
      image_id: image.id,
      prev_image: Images.next_image_on_page(images, image),
      next_image: Images.prev_image_on_page(images, image),
      image_path: Routes.static_path(socket, Images.web_image_path(image))
    )
  end

  ####### index helper methods

  @doc """
    returns a list of paginated images
    params: pagination config
    filters: tag filters (%{"tags" => "" | [] })
  """
  def list_images(params), do: Images.paginate_images(params)
  def list_images(params, tags), do: Images.paginate_images(params, tags)

  ###### Show helper methods
  def get_prev_image(params, tag_filter, images, image),
    do: Paginate.get_prev_image(params, tag_filter, images, image)

  def get_next_image(params, tag_filter, images, image),
    do: Paginate.get_next_image(params, tag_filter, images, image)

  def list_tags_as_options(image_tags) do
    Enum.map(image_tags, fn tag -> tag.name end)
  end

  # generic session helper methods
  defp assign_session_filter(socket, session) do
    socket
    |> assign(:tag_filter, get_session_filter(session))
  end

  defp get_session_filter(session) do
    Map.get(session, "tag_filter", [])
  end
end
