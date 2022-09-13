defmodule OnagalWeb.GalleryLive.FilterComponent do
  use OnagalWeb, :live_component

  alias Onagal.Tags

  @impl true
  def update(
        %{id: "filter", tag_filter: tag_filter, tag_list: tag_list, image_tags: image_tags} =
          _assigns,
        socket
      )
      when is_list(tag_list) do
    socket =
      socket
      |> assign(:tag_filter, tag_filter)
      |> assign(:tag_list, tag_list)
      |> assign(:image_tags, image_tags)
      |> assign(:tagset_list, list_tagsets)
      |> assign(:filterset_list, list_filtersets)

    {:ok, socket}
  end

  # Filtering here
  @impl true
  def handle_event("filter", %{"tag_filter" => %{"tags" => tags}} = params, socket) do
    IO.puts("filter_form handle_event filter 1")

    {:noreply, handle_filter_event(params, socket, tags)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    IO.puts("filter_form handle_event filter 2")
    tags = []

    {:noreply, handle_filter_event(params, socket, tags)}
  end

  defp handle_filter_event(params, socket, tags) do
    IO.puts("filter_form handle_filter_event")

    send(self(), {:tag_filter, tags: tags, params: params})

    socket |> assign(:tag_filter, tags)
  end

  # Filterset here
  def handle_event(
        "filterset_select",
        %{"filterset" => %{"select_filterset" => filterset}} = params,
        socket
      ) do
    IO.puts("filter_form handle_event :filterset_select")

    tags = Tags.list_tags_by_filterset_name(filterset)

    {:noreply, handle_filter_event(params, socket, list_tags(tags))}
  end

  # Tagset here
  def handle_event(
        "tagset_select",
        %{"tagset" => %{"select_tagset" => tagset}} = params,
        socket
      ) do
    IO.puts("tagset_form handle_event :tagset_select")

    tags = Tags.list_tags_by_tagset_name(tagset)

    # {:noreply, handle_tag_event(params, socket, list_tags(tags), :replace)}
    {:noreply, socket |> assign(:image_tags, list_tags(tags))}
  end

  # Tagging here
  @impl true
  def handle_event(
        "tag",
        %{"tag_image" => %{"tags" => tags, "add_replace" => add_replace}} = params,
        socket
      ) do
    IO.puts("filter_form handle_event tag 1")
    mode = if add_replace == "true", do: :replace, else: :add

    {:noreply, handle_tag_event(params, socket, tags, mode)}
  end

  @impl true
  def handle_event("tag", %{"tag_image" => %{"add_replace" => add_replace}} = params, socket) do
    IO.puts("filter_form handle_event tag 2")
    tags = []
    mode = if add_replace == "true", do: :replace, else: :add

    {:noreply, handle_tag_event(params, socket, tags, mode)}
  end

  defp handle_tag_event(params, socket, tags, mode) do
    IO.puts("filter_form handle_tag_event")

    send(self(), {:tag_images, tags: tags, mode: mode, params: params})

    socket |> assign(:tag_image, tags)
  end

  defp list_tags(tags) do
    Enum.map(tags, fn tag -> tag.name end)
  end

  defp list_tagsets do
    Enum.map(Tags.list_tagsets(), fn tagset -> tagset.name end)
  end

  defp list_filtersets do
    Enum.map(Tags.list_filtersets(), fn filterset -> filterset.name end)
  end
end
