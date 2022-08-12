defmodule OnagalWeb.ImageLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
  alias Onagal.Tags

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_filter(session)

    push_event(socket, "tags", socket.assigns.filter)
    push_event(socket, "filters", socket.assigns.filter)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Image")
    |> assign(:image, Images.get_image!(id))
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Images")
    |> assign(:image, nil)
    |> assign(:page, list_images(params, socket.assigns.filter))
  end

  @impl true
  def handle_event("filter", %{"image_tag_filter" => %{"tags" => tags}} = params, socket) do
    socket = assign(socket, :filter, %{"tags" => tags})
    socket = assign(socket, :page, list_images(params, socket.assigns.filter))
    PhoenixLiveSession.put_session(socket, "filter", socket.assigns.filter)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{} = params, socket) do
    socket = assign(socket, :filter, %{"tags" => ""})
    socket = assign(socket, :page, list_images(params, socket.assigns.filter))
    PhoenixLiveSession.put_session(socket, "filter", socket.assigns.filter)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    image = Images.get_image!(id)
    # {:ok, _} = Images.delete_image(image)
    {:ok, _} = Onagal.Fs.cleanup_file(Images.full_image_path(image))

    {:noreply, assign(socket, :images, list_images({}))}
  end

  @impl true
  @doc """
    returns a list of paginated images
    params: pagination config
    filters: tag filters (%{"tags" => "" | [] })
  """
  defp list_images(params, %{"tags" => ""} = filters) do
    Images.paginate_images(params)
  end

  defp list_images(params, %{"tags" => tags} = filters) when is_binary(tags) do
    Images.paginate_images_with_tags(params, [tags])
  end

  defp list_images(params, %{"tags" => tags} = filters) when is_list(tags) do
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

  defp put_session_filter(socket, session) do
    socket
    |> assign(:filter, Map.get(session, "filter", %{"tags" => ""}))
  end
end
