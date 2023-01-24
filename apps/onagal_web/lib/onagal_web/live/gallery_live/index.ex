defmodule OnagalWeb.GalleryLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
  alias Onagal.Tags
  alias Onagal.Paginate

  @moduledoc """
    Main live hub for GalleryLive
  """

  @impl true
  def mount(_params, _session, socket) do
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

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.puts("handle_params")

    socket =
      socket
      |> assign(:tag_list, Onagal.Tags.list_tags_as_options())

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"page" => "prev"} = params) do
    images = get_socket_images(socket, params)
    prev_images = get_socket_prev_images(socket, images, params)
    new_images = images_prev_page(prev_images, socket.assigns.selected_filters, params)

    socket = assign_images_tuple(socket, {new_images, prev_images, images})

    apply_action(socket, :index, Map.delete(params, "page"))
  end

  defp apply_action(socket, :index, %{"page" => "next"} = params) do
    images = get_socket_images(socket, params)
    next_images = get_socket_next_images(socket, images, params)
    new_images = images_next_page(next_images, socket.assigns.selected_filters, params)

    socket = assign_images_tuple(socket, {images, next_images, new_images})

    apply_action(socket, :index, Map.delete(params, "page"))
  end

  defp apply_action(socket, :index, %{} = params) do
    socket
    |> assign_new(:images, fn -> list_images(socket.assigns.selected_filters, params) end)
    |> assign(:image, nil)
    |> assign(:next_image, nil)
    |> assign(:prev_image, nil)
  end

  defp apply_action(socket, :show, params) do
    IO.puts("apply_action :show")

    # TODO: Possible change this up if we can do offset starts on pages
    if Map.has_key?(socket.assigns, :images),
      do: show_action(socket, params),
      else: push_patch(socket, to: Routes.gallery_index_path(socket, :index))
  end

  defp show_action(socket, %{"id" => id} = params) do
    image = Images.get_image_with_tags(id)

    socket = refresh_image_lists(image, socket, params)

    socket
    |> assign(:image, image)
    |> assign(:prev_image, get_prev_image(image, socket))
    |> assign(:next_image, get_next_image(image, socket))
  end

  # Handlers

  @impl true
  def handle_info({:selected_filters, [filters: filters, params: params]}, socket) do
    IO.puts("index handle_info :selected_filters")

    images = list_images(filters, params)

    image =
      if images.entries == [],
        do: nil,
        else: hd(images.entries) |> Onagal.Repo.preload(:tags)

    socket =
      socket
      |> assign(:selected_filters, filters)
      |> assign(:images, images)

    handle_filtering(
      socket.assigns.live_action,
      filters,
      images,
      image,
      socket
    )
  end

  defp handle_filtering(:index, filters, images, image, socket) do
    socket =
      socket
      |> assign(:image, image)

    {:noreply, socket}
  end

  defp handle_filtering(:show, _filters, _images, image, socket) do
    case image do
      nil ->
        {:noreply, push_patch(socket, to: Routes.gallery_index_path(socket, :index, page: 1))}

      _ ->
        {:noreply, push_patch(socket, to: Routes.gallery_index_path(socket, :show, image.id))}
    end
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

  # ####### index helper methods
  def params_to_paginate(params) do
    cond do
      # Deprecated - we now store prev/current/next images and use those directly...
      # Map.get(params, "next") -> [after: Map.get(params, "next")]
      # Map.get(params, "prev") -> [before: Map.get(params, "prev")]
      Map.get(params, "id") -> [id: String.to_integer(Map.get(params, "id"))]
      true -> []
    end
  end

  defp get_socket_images(socket, params),
    do: Map.get(socket.assigns, :images, list_images(socket.assigns.selected_filters, params))

  defp get_socket_prev_images(socket, images, params),
    do:
      Map.get(
        socket.assigns,
        :prev_images,
        images_prev_page(images, socket.assigns.selected_filters, params)
      )

  defp get_socket_next_images(socket, images, params),
    do:
      Map.get(
        socket.assigns,
        :next_images,
        images_next_page(images, socket.assigns.selected_filters, params)
      )

  defp assign_images_tuple(socket, {prev_images, images, next_images}) do
    socket
    |> assign(:prev_images, prev_images)
    |> assign(:images, images)
    |> assign(:next_images, next_images)
  end

  def refresh_image_lists(image, socket, params) do
    # Images _must_ be set, if not it should be caught in caller
    images = Map.get(socket.assigns, :images)

    prev_images =
      Map.get(
        socket.assigns,
        :prev_images,
        images_prev_page(images, socket.assigns.selected_filters, params)
      )

    next_images =
      Map.get(
        socket.assigns,
        :next_images,
        images_next_page(images, socket.assigns.selected_filters, params)
      )

    cond do
      Paginate.image_on_current_page(images, image) ->
        socket
        |> assign_new(:prev_images, fn -> prev_images end)
        |> assign_new(:next_images, fn -> next_images end)

      Paginate.image_on_prior_page(images, image) ->
        socket
        |> assign(:images, prev_images)
        |> assign(:next_images, images)
        |> assign(
          :prev_images,
          images_prev_page(prev_images, socket.assigns.selected_filters, params)
        )

      Paginate.image_on_future_page(images, image) ->
        socket
        |> assign(:images, next_images)
        |> assign(:prev_images, images)
        |> assign(
          :next_images,
          images_next_page(next_images, socket.assigns.selected_filters, params)
        )
    end
  end

  def get_prev_image(image, socket) do
    images = Map.get(socket.assigns, :images)

    cond do
      image.id == hd(images.entries).id ->
        case List.last(Map.get(socket.assigns, :prev_images).entries) do
          x when x.id > image.id -> nil
          x -> x
        end

      true ->
        image_index = Enum.find_index(images.entries, fn img -> img.id == image.id end)
        Enum.at(images.entries, image_index - 1)
    end
  end

  def get_next_image(image, socket) do
    images = Map.get(socket.assigns, :images)

    cond do
      image.id == List.last(images.entries).id ->
        case hd(Map.get(socket.assigns, :next_images).entries) do
          x when x.id < image.id -> nil
          x -> x
        end

      true ->
        image_index = Enum.find_index(images.entries, fn img -> img.id == image.id end)
        Enum.at(images.entries, image_index + 1)
    end
  end

  # Paginate wrappers
  defp list_images(params), do: Paginate.paginate_images([], params_to_paginate(params))
  defp list_images(%{}, params), do: Paginate.paginate_images([], params_to_paginate(params))
  defp list_images(tags, params), do: Paginate.paginate_images(tags, params_to_paginate(params))

  defp images_next_page(images, params),
    do: Paginate.images_next_page(images, [], params.to_paginate(params))

  defp images_next_page(images, %{}, params),
    do: Paginate.images_next_page(images, [], params_to_paginate(params))

  defp images_next_page(images, tags, params),
    do: Paginate.images_next_page(images, tags, params_to_paginate(params))

  defp images_prev_page(images, params),
    do: Paginate.images_prev_page(images, [], params.to_paginate(params))

  defp images_prev_page(images, %{}, params),
    do: Paginate.images_prev_page(images, [], params_to_paginate(params))

  defp images_prev_page(images, tags, params),
    do: Paginate.images_prev_page(images, tags, params_to_paginate(params))

  # ###### Show helper methods
  def list_tags_as_options(image_tags) do
    Enum.map(image_tags, fn tag -> tag.name end)
  end

  #### generic session helper methods
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
end
