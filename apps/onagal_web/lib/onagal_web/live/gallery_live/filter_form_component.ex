defmodule OnagalWeb.GalleryLive.FilterComponent do
  use OnagalWeb, :live_component

  alias Onagal.{Images, Tags}

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

  def render(assigns) do
    ~H"""
    <div>
      <.form let={f}
          for={:tag_filter}
          phx-submit="filter"
      >
          <%= label f, :tags %>
          <%= multiple_select f, :tags, @tag_list, selected: @tag_filter %>

          <%= label f, :submit %>
          <%= submit "Filter" %>
      </.form>
    </div>
    """
  end
end
