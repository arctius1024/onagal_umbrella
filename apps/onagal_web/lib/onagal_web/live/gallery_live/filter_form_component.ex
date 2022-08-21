defmodule OnagalWeb.GalleryLive.FilterComponent do
  use OnagalWeb, :live_component

  # alias Onagal.Images

  @impl true
  def update(
        %{id: "filter", tag_filter: tag_filter, tag_list: tag_list} = _assigns,
        socket
      )
      when is_list(tag_list) do
    socket =
      socket
      |> assign(:tag_filter, tag_filter)
      |> assign(:tag_list, tag_list)

    {:ok, socket}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

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
    </div>
    """
  end

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
    IO.inspect(tags)

    send(self(), {:tag_filter, tags: tags, params: params})

    socket |> assign(:tag_filter, tags)
  end
end
