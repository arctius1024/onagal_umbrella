defmodule OnagalWeb.GalleryLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
  alias Onagal.Tags

  @impl true
  def mount(_params, session, socket) do
    IO.puts("handle_mount")

    sockets =
      socket
      |> assign(:page_title, "Listing Images")
      |> assign(:image, nil)

    # |> PhoenixLiveSession.maybe_subscribe(session) |> assign_session_filter(session)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("handle_params")
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    IO.puts("apply_action :index")
    tag_filter = Map.get(socket.assigns, :tag_filter, params["tag_filter"]) || []

    socket
    |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
    |> assign(:tag_filter, tag_filter)
    |> assign(:page, list_images(params, tag_filter))
  end

  @impl true
  def handle_event("filter", %{"tag_filter" => %{"tags" => tags}} = params, socket) do
    IO.puts("handle_event filter 1")

    {:noreply, handle_filter_event(params, socket, tags)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    IO.puts("handle_event filter 2")
    tags = []

    {:noreply, handle_filter_event(params, socket, tags)}
  end

  defp handle_filter_event(params, socket, tags) do
    IO.inspect(tags)

    socket =
      socket
      |> assign(:tag_filter, tags)
      |> assign(:page, list_images(params, tags))

    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      tag_filter: tags,
      tag_list: Onagal.Tags.list_tags_as_options()
    )

    # PhoenixLiveSession.put_session(socket, "tag_filter", tags)

    socket
  end

  # def handle_info({:live_session_updated, session}, socket) do
  #   IO.puts("index handle_info live_session_updated")
  #   {:noreply, assign_session_filter(socket, session)}
  # end

  @impl true
  @doc """
    returns a list of paginated images
    params: pagination config
    filters: tag filters (%{"tags" => "" | [] })
  """
  defp list_images(params, []) do
    Images.paginate_images(params)
  end

  defp list_images(params, tags) when is_binary(tags) do
    Images.paginate_images_with_tags(params, [tags])
  end

  defp list_images(params, tags) when is_list(tags) do
    Images.paginate_images_with_tags(params, tags)
  end

  defp list_images(params) do
    Images.paginate_images(params)
  end

  defp available_tags, do: Tags.list_tags()

  defp resolve_thumbnail_path(image) do
    if !File.exists?(Images.system_thumbnail_image_path(image)),
      do: Images.generate_thumbnail(image)

    Images.web_thumbnail_image_path(image)
  end

  defp assign_session_filter(socket, session) do
    socket
    |> assign(:tag_filter, get_session_filter(session))
  end

  defp get_session_filter(session) do
    Map.get(session, "tag_filter", [])
  end

  def stringify_filter(tags) do
    Enum.join(Enum.map(tags, fn v -> v end), ", ")
  end
end
