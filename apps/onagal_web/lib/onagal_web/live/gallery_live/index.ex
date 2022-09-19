defmodule OnagalWeb.GalleryLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
  alias Onagal.Tags
  alias Onagal.Paginate

  @moduledoc """
    Main live hub for GalleryLive
  """

  @impl true
  def mount(_params, session, socket) do
    IO.puts("handle_mount")

    # selected_filters -> tags currently selected as filters
    # selected_tags -> tags currently selected to apply to images
    # selected_images -> images currently selected (for tagging)
    socket =
      socket
      |> assign(:selected_filters, [])
      |> assign(:selected_tags, [])
      |> assign(:selected_images, [])
      |> assign(:image_tags, [])
      |> assign(:page, 1)
      |> assign(:tag_list, Onagal.Tags.list_tags_as_options())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("handle_params")

    socket =
      socket
      |> assign(:page, parse_page(Map.get(params, "page", "1")))
      |> assign(:tag_list, Onagal.Tags.list_tags_as_options())

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    IO.puts("apply_action :index")

    socket |> assign(:images, list_images(params, socket.assigns.selected_filters))
  end

  defp apply_action(socket, :show, %{"id" => id} = params) do
    IO.puts("apply_action :show")

    image = Images.get_image_with_tags(id)
    selected_filters = socket.assigns.selected_filters
    page = Map.get(socket.assigns, :images, list_images(params, selected_filters))

    {prev_image, image, next_image, images} =
      Paginate.resolve_image_tuples(page, image, params, selected_filters)

    socket
    |> assign(:next_image, next_image)
    |> assign(:prev_image, prev_image)
    |> assign(:images, images)
    |> assign(:image, image |> Onagal.Repo.preload(:tags))
    |> assign(:page, images.page_number)
    |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))
  end

  @impl true
  def handle_info({:selected_filters, [tags: tags, params: params]}, socket) do
    IO.puts("index handle_info :selected_filters")

    images = list_images(params, tags)

    image =
      if images.entries == [],
        do: Images.get_first(),
        else: hd(images.entries) |> Onagal.Repo.preload(:tags)

    socket =
      socket
      |> assign(:selected_filters, tags)
      |> assign(:images, images)
      |> assign(:image, image)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:selected_tags, [tags: tags, mode: mode, params: _params]}, socket) do
    IO.puts("index handle_info :selected_tags")

    socket = handle_image_tagging(socket.assigns.live_action, tags, mode, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_selections", %{"value" => "clear"}, socket) do
    IO.puts("index handle_event clear_selections")

    {:noreply, socket |> assign(:selected_images, [])}
  end

  @impl true
  def handle_event("clear_filters", %{"value" => "clear"}, socket) do
    IO.puts("index handle_event clear_filters")

    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      selected_filters: []
    )

    {:noreply, socket |> assign(:selected_filters, [])}
  end

  @impl true
  def handle_event("clear_tags", %{"value" => "clear"}, socket) do
    IO.puts("index handle_event clear_tags")

    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      selected_tags: []
    )

    {:noreply, socket |> assign(:selected_tags, [])}
  end

  @impl true
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

    {:noreply, socket |> assign(:selected_images, new_selected_images)}
  end

  defp handle_image_tagging(:index, tags, mode, socket) do
    Enum.each(socket.assigns.selected_images, fn image_id ->
      image = Images.get_image_with_tags(image_id)
      retag_image(image, mode, tags)
    end)

    socket
  end

  defp handle_image_tagging(:show, tags, mode, socket) do
    image = socket.assigns.image |> Onagal.Repo.preload(:tags)
    retag_image(image, mode, tags)
    image = image |> Onagal.Repo.preload(:tags, force: true)

    send_update(
      OnagalWeb.GalleryLive.DisplayComponent,
      id: "display",
      image: image
    )

    socket |> assign(:image, image)
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
  def list_tags_as_options(image_tags) do
    Enum.map(image_tags, fn tag -> tag.name end)
  end

  # generic session helper methods
  def retag_image(image, mode, tags) when is_list(tags) do
    case mode do
      :replace ->
        Tags.upsert_image_tags_by_name(image, tags)

      :add ->
        Enum.each(tags, fn tag ->
          Tags.add_tag_to_image(image, tag)
        end)
    end
  end

  defp parse_page(raw_page) do
    case Integer.parse(raw_page) do
      {page, _} -> page
      :error -> 1
    end
  end
end
