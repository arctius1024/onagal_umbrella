defmodule OnagalWeb.GalleryLive.FilterComponent do
  use OnagalWeb, :live_component

  # alias Onagal.Images

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

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form let={f}
          for={:tag_filter}
          phx-submit="filter"
          phx-target={@myself}
      >
          <%= label f, :tags %>
          <%= multiple_select f, :tags, @tag_list, selected: @tag_filter %>

          <%= label f, :submit %>
          <%= submit "Filter" %>
      </.form>

      <.form let={f}
        for={:tag_image}
        phx-submit="tag"
        phx-target={@myself}
      >
        <%= label f, :tags %>
        <%= multiple_select f, :tags, @tag_list, selected: @image_tags %>

        <%= label f, :submit %>
        <%= submit "Tag" %>
      </.form>

      <button
        type="button"
        phx-click="clear_selections"
        value="clear"
      >
        Clear Selections
      </button>
    </div>
    """
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

  # Tagging here
  @impl true
  def handle_event("tag", %{"tag_image" => %{"tags" => tags}} = params, socket) do
    IO.puts("filter_form handle_event tag 1")

    {:noreply, handle_tag_event(params, socket, tags)}
  end

  @impl true
  def handle_event("tag", params, socket) do
    IO.puts("filter_form handle_event tag 2")
    tags = []

    {:noreply, handle_tag_event(params, socket, tags)}
  end

  defp handle_tag_event(params, socket, tags) do
    IO.puts("filter_form handle_tag_event")

    send(self(), {:tag_images, tags: tags, params: params})

    socket |> assign(:tag_image, tags)
  end
end
