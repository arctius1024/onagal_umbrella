defmodule OnagalWeb.GalleryLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @impl true
  def mount(_params, session, socket) do
    IO.puts("handle_mount")

    socket =
      socket
      |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> assign_session_filter(session)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("handle_params")

    tag_filter = Map.get(socket.assigns, :tag_filter, [])

    socket =
      socket
      |> assign(:tag_filter, tag_filter)
      |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
      |> assign(:images, list_images(params, tag_filter))
      |> assign(:page, Map.get(params, "page", 1))

    send_filter_update({:filter, tags: tag_filter})

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    IO.puts("apply_action :show")

    # Find image associated with image id passed in params
    image = Images.get_image!(id)
    tag_filter = socket.assigns.tag_filter
    images = list_images_by_image_page(params, image, tag_filter)

    [prev_image, _, next_image] = resolve_image_nav(images, image, tag_filter)

    socket
    |> assign(:next_image, next_image)
    |> assign(:prev_image, prev_image)
    |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))
    |> assign(:page, images.page_number)
    |> assign(:image_id, image.id)
  end

  defp apply_action(socket, :index, params) do
    IO.puts("apply_action :index")

    tag_filter = socket.assigns.tag_filter

    socket
    |> assign(:images, list_images(params, tag_filter))
  end

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
        [] -> get_default_image()
        _ -> hd(images.entries)
      end

    send_filter_update({:filter, tags: tags})

    case socket.assigns.live_action do
      :index -> send_filter_update({:index, images: images})
      :show -> send_filter_update({:show, socket: socket, images: images, image: image})
    end

    PhoenixLiveSession.put_session(socket, "tag_filter", tags)

    {:noreply, socket |> assign(:images, images)}
  end

  defp send_filter_update({:filter, [tags: tags]}) do
    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      tag_filter: tags,
      tag_list: Onagal.Tags.list_tags_as_options()
    )
  end

  defp send_filter_update({:index, [images: images]}) do
    IO.puts("index send_filter_update 1")

    send_update(
      OnagalWeb.GalleryLive.MontageComponent,
      id: "montage",
      images: images
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

  # TODO: cleanup/refactor sweep
  # TODO: REALLY getting ugly in here, need to clean this up next commit
  ####### helper methods

  @doc """
    returns a list of paginated images
    params: pagination config
    filters: tag filters (%{"tags" => "" | [] })
  """
  def list_images(params, []) do
    Images.paginate_images(params)
  end

  def list_images(params, tags) when is_binary(tags) do
    Images.paginate_images_with_tags(params, [tags])
  end

  def list_images(params, tags) when is_list(tags) do
    Images.paginate_images_with_tags(params, tags)
  end

  def list_images(params) do
    Images.paginate_images(params)
  end

  def list_images_by_image_page(params, image, tag_filter) do
    IO.puts("list_images_by_page")

    images = list_images(params, tag_filter)

    if verify_image_on_page(images, image) do
      images
    else
      page = find_image_page(params, image, images, tag_filter)
      list_images(Map.merge(params, %{page: page}), tag_filter)
    end
  end

  def verify_image_on_page(images, image) do
    IO.puts("verify_image_on_page")

    if image.id >= hd(images.entries).id &&
         image.id <= List.last(images.entries).id do
      true
    else
      false
    end
  end

  def find_image_page(params, image, images, tags) do
    IO.puts("index find_image_page")

    min_page_id = hd(images.entries).id
    max_page_id = List.last(images.entries).id

    cond do
      image.id < min_page_id ->
        find_image_page(
          params,
          image,
          list_images(Map.merge(params, %{page: images.page_number - 1}), tags),
          tags
        )

      image.id > max_page_id ->
        find_image_page(
          params,
          image,
          list_images(Map.merge(params, %{page: images.page_number + 1}), tags),
          tags
        )

      true ->
        images.page_number
    end
  end

  defp resolve_image_nav(images, image, tags) do
    IO.puts("index resolve_image_nav")

    [prev_image, _, next_image] = Images.find_page_tuple(images, image)

    prev_image = resolve_prev_image(images, prev_image, tags)
    next_image = resolve_next_image(images, next_image, tags)

    [prev_image, nil, next_image]
  end

  defp resolve_prev_image(images, prev_image, tags) do
    IO.puts("index resolve_prev_image")
    page = images.page_number

    case [prev_image, page] do
      [nil, 1] ->
        hd(images.entries)

      [nil, _] ->
        prev_page = list_images(%{"page" => page - 1}, tags)
        List.last(prev_page.entries)

      [_, _] ->
        prev_image
    end
  end

  defp resolve_next_image(images, next_image, tags) do
    total_pages = images.total_pages
    page = images.page_number

    case [next_image, page] do
      [nil, ^total_pages] ->
        List.last(images.entries)

      [nil, _] ->
        next_page = list_images(%{"page" => page + 1}, tags)
        hd(next_page.entries)

      [_, _] ->
        next_image
    end
  end

  def get_default_image(), do: Images.get_first()

  # defp available_tags, do: Tags.list_tags()

  # Deprecated non-working Phoenix Live Session hooks
  defp assign_session_filter(socket, session) do
    socket
    |> assign(:tag_filter, get_session_filter(session))
  end

  defp get_session_filter(session) do
    Map.get(session, "tag_filter", [])
  end

  @spec stringify_filter(any) :: binary
  def stringify_filter(tags) do
    Enum.join(Enum.map(tags, fn v -> v end), ", ")
  end
end
