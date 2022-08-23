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

  defp apply_action(socket, :show, %{"id" => id} = params) do
    IO.puts("apply_action :show")

    image = Images.get_image!(id)
    tag_filter = socket.assigns.tag_filter
    # images = list_images_by_image_page(params, image, tag_filter)
    images = list_images(params, tag_filter)

    {prev_image, images} =
      case get_prev_image(params, tag_filter, images, image) do
        {:ok, prev_image} ->
          {prev_image, images}

        {:error, :next_page} ->
          next_images =
            list_images(Map.merge(params, %{page: images.page_number + 1}), tag_filter)

          {:ok, prev_image} = get_prev_image(params, tag_filter, next_images, image)
          {prev_image, next_images}
      end

    {next_image, images} =
      case get_next_image(params, tag_filter, images, image) do
        {:ok, next_image} ->
          {next_image, images}

        {:error, :prev_page} ->
          prev_images =
            list_images(Map.merge(params, %{page: images.page_number - 1}), tag_filter)

          {:ok, next_image} = get_next_image(params, tag_filter, prev_images, image)
          {next_image, prev_images}
      end

    socket
    |> assign(:next_image, next_image)
    |> assign(:prev_image, prev_image)
    |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))
    |> assign(:image_id, image.id)
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

  ###### Show helper methods
  def get_prev_image(params, tag_filter, images, image) do
    case check_for_prev_image(images, image) do
      {:ok, prev_image} ->
        {:ok, prev_image}

      {:error, :start_boundary} ->
        {:ok, image}

      {:error, :page_boundary} ->
        prev_images = list_images(Map.merge(params, %{page: images.page_number - 1}), tag_filter)
        {:ok, List.last(prev_images.entries)}

      {:error, :next_page} ->
        {:error, :next_page}

      {:error, :prev_page} ->
        {:error, :prev_page}
    end
  end

  def check_for_prev_image(images, image) do
    IO.puts("check_for_prev_image")

    cond do
      image.id < hd(images.entries).id ->
        {:error, :prev_page}

      image.id > List.last(images.entries).id ->
        {:error, :next_page}

      image.id == hd(images.entries).id && images.page_number == 1 ->
        {:error, :start_boundary}

      image.id == hd(images.entries).id ->
        {:error, :page_boundary}

      true ->
        image_index = Enum.find_index(images.entries, fn img -> img.id == image.id end)
        {:ok, Enum.at(images.entries, image_index - 1)}
    end
  end

  def get_next_image(params, tag_filter, images, image) do
    IO.puts("get_next_image")

    case check_for_next_image(images, image) do
      {:ok, next_image} ->
        {:ok, next_image}

      {:error, :end_boundary} ->
        {:ok, image}

      {:error, :page_boundary} ->
        next_images = list_images(Map.merge(params, %{page: images.page_number + 1}), tag_filter)
        {:ok, hd(next_images.entries)}

      {:error, :next_page} ->
        {:error, :next_page}

      {:error, :prev_page} ->
        {:error, :prev_page}
    end
  end

  def check_for_next_image(images, image) do
    IO.puts("check_for_next_image")

    cond do
      image.id < hd(images.entries).id ->
        {:error, :prev_page}

      image.id > List.last(images.entries).id ->
        {:error, :next_page}

      image.id == List.last(images.entries).id && images.total_pages == images.page_number ->
        {:error, :end_boundary}

      image.id == List.last(images.entries).id ->
        {:error, :page_boundary}

      true ->
        image_index = Enum.find_index(images.entries, fn img -> img.id == image.id end)
        {:ok, Enum.at(images.entries, image_index + 1)}
    end
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
