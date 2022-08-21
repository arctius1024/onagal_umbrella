defmodule OnagalWeb.GalleryLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @impl true
  def mount(_params, session, socket) do
    IO.puts("handle_mount")

    socket =
      socket
      |> assign(:image, nil)
      |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> assign_session_filter(session)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("handle_params")

    tag_filter = Map.get(socket.assigns, :tag_filter, [])
    send_filter_update({:filter, tags: tag_filter})

    socket =
      socket
      |> assign(:tag_filter, tag_filter)
      |> assign(:tag_list, Onagal.Tags.list_tags_as_options())

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    IO.puts("apply_action :show")

    image = Images.get_image!(id)
    tag_filter = socket.assigns.tag_filter

    page = OnagalWeb.GalleryLive.Index.list_images(params, tag_filter)
    [prev_image, _, next_image] = Images.find_page_tuple(page, image)

    socket
    |> assign(:next_image, next_image)
    |> assign(:prev_image, prev_image)
    |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))
  end

  defp apply_action(socket, :index, params) do
    IO.puts("apply_action :index")

    tag_filter = socket.assigns.tag_filter

    socket
    |> assign(:page, list_images(params, tag_filter))
  end

  @impl true
  def handle_info({:live_session_updated, session}, socket) do
    IO.puts("test handle_info :live_session_updated")
    {:noreply, socket |> assign(:tag_filter, Map.get(session, "tag_filter", []))}
  end

  @impl true
  def handle_info({:tag_filter, [tags: tags, params: params]}, socket) do
    IO.puts("index handle_info :tag_filter")
    # IO.inspect(tags)
    # IO.inspect(params)
    IO.puts("---------")

    page = OnagalWeb.GalleryLive.Index.list_images(params, tags)

    image =
      case page.entries do
        [] -> get_default_image()
        _ -> hd(page.entries)
      end

    send_filter_update({:filter, tags: tags})

    case socket.assigns.live_action do
      :index -> send_filter_update({:index, page: page})
      :show -> send_filter_update({:show, socket: socket, page: page, image: image})
    end

    PhoenixLiveSession.put_session(socket, "tag_filter", tags)

    {:noreply, socket |> assign(:page, page)}
  end

  defp send_filter_update({:filter, [tags: tags]}) do
    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      tag_filter: tags,
      tag_list: Onagal.Tags.list_tags_as_options()
    )
  end

  defp send_filter_update({:index, [page: page]}) do
    IO.puts("index send_filter_update 1")

    send_update(
      OnagalWeb.GalleryLive.MontageComponent,
      id: "montage",
      page: page
    )
  end

  defp send_filter_update({:show, [socket: socket, page: page, image: image]}) do
    IO.puts("index send_filter_update 2")

    send_update(
      OnagalWeb.GalleryLive.DisplayComponent,
      id: "display",
      prev_image: Images.next_image_on_page(page, image),
      next_image: Images.prev_image_on_page(page, image),
      image_path: Routes.static_path(socket, Images.web_image_path(image))
    )
  end

  # TODO: cleanup/refactor sweep
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
