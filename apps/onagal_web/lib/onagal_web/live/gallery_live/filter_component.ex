defmodule OnagalWeb.GalleryLive.FilterComponent do
  use OnagalWeb, :live_component

  alias Onagal.Tags

  @impl true
  def update(
        %{
          id: "filter",
          tag_list: tag_list,
          selected_filters: selected_filters,
          selected_tags: selected_tags
        } = _assigns,
        socket
      ) do
    socket =
      socket
      |> assign(:selected_filters, selected_filters)
      |> assign(:selected_tags, selected_tags)
      |> assign(:tag_list, tag_list)
      |> assign(:tagset_list, list_tagsets())
      |> assign(:filterset_list, list_filtersets())

    {:ok, socket}
  end

  def update(%{id: "filter", selected_filters: selected_filters}, socket) do
    IO.puts("filter_component :update selected_filters")
    {:ok, socket |> assign(:selected_filters, selected_filters)}
  end

  def update(%{id: "filter", selected_tags: selected_tags}, socket) do
    IO.puts("filter_component :update selected_tags")
    {:ok, socket |> assign(:selected_tags, selected_tags)}
  end

  # Filtering here
  @impl true
  def handle_event("filter", %{"selected_filters" => %{"tags" => tags}} = params, socket) do
    IO.puts("filter_form handle_event filter 1")

    {:noreply, handle_filter_event(params, socket, tags)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    IO.puts("filter_form handle_event filter 2")
    tags = []

    {:noreply, handle_filter_event(params, socket, tags)}
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
        %{"tagset" => %{"select_tagset" => tagset}} = _params,
        socket
      ) do
    IO.puts("tagset_form handle_event :tagset_select")

    tags = Tags.list_tags_by_tagset_name(tagset)

    # {:noreply, handle_tag_event(params, socket, list_tags(tags), :replace)}
    {:noreply, socket |> assign(:selected_tags, list_tags(tags))}
  end

  # Tagging here
  @impl true
  def handle_event(
        "tag",
        %{"selected_tags" => %{"tags" => tags, "add_replace" => add_replace}} = params,
        socket
      ) do
    IO.puts("filter_form handle_event tag 1")
    mode = if add_replace == "true", do: :replace, else: :add

    {:noreply, handle_tag_event(params, socket, tags, mode)}
  end

  @impl true
  def handle_event("tag", %{"selected_tags" => %{"add_replace" => add_replace}} = params, socket) do
    IO.puts("filter_form handle_event tag 2")
    tags = []
    mode = if add_replace == "true", do: :replace, else: :add

    {:noreply, handle_tag_event(params, socket, tags, mode)}
  end

  # Filter helper
  defp handle_filter_event(params, socket, tags) do
    IO.puts("filter_form handle_filter_event")

    send(self(), {:selected_filters, tags: tags, params: params})

    socket |> assign(:selected_filters, tags)
  end

  # Tag helper
  defp handle_tag_event(params, socket, tags, mode) do
    IO.puts("filter_form handle_tag_event")

    send(self(), {:selected_tags, tags: tags, mode: mode, params: params})

    socket |> assign(:selected_tags, tags)
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
