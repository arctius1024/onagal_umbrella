defmodule OnagalWeb.GalleryLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
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

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    IO.puts("apply_action :index")

    send_filter_update(:filter, socket.assigns)

    socket
    |> assign(:images, list_images(params, socket.assigns.tag_filter))
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

    send_filter_update(:filter, socket.assigns)

    case socket.assigns.live_action do
      :index -> send_filter_update(:index, {images})
    end

    PhoenixLiveSession.put_session(socket, "tag_filter", tags)

    {:noreply, socket |> assign(:images, images)}
  end

  defp send_filter_update(:filter, %{tag_filter: tags, tag_list: tag_list} = _assigns) do
    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      tag_filter: tags,
      tag_list: tag_list
    )
  end

  defp send_filter_update(:index, {images}) do
    IO.puts("index send_filter_update 1")

    send_update(
      OnagalWeb.GalleryLive.MontageComponent,
      id: "montage",
      images: images
    )
  end

  # TODO: cleanup/refactor sweep
  # TODO: REALLY getting ugly in here, need to clean this up next commit
  ####### index helper methods

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

  # generic session helper methods
  defp assign_session_filter(socket, session) do
    socket
    |> assign(:tag_filter, get_session_filter(session))
  end

  defp get_session_filter(session) do
    Map.get(session, "tag_filter", [])
  end
end
