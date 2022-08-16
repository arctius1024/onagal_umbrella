defmodule OnagalWeb.GalleryLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @impl true
  def mount(_params, session, socket) do
    IO.puts("show mount")
    # IO.inspect(get_session_filter(session))

    # |> PhoenixLiveSession.maybe_subscribe(session)
    # |> assign_session_filter(session)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _session, socket) do
    IO.puts("show handle_params")
    tag_filter = Map.get(socket.assigns, :tag_filter, params["tag_filter"]) || []
    image = Images.get_image!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, image)
     |> assign(:tag_filter, tag_filter)
     |> assign(:next_image, Images.get_next_image(image.id, tag_filter))
     |> assign(:prev_image, Images.get_prev_image(image.id, tag_filter))
     |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))
     |> assign(:tag_list, Onagal.Tags.list_tags_as_options())}
  end

  @impl true
  def handle_event("filter", %{"tag_filter" => %{"tags" => tags}} = _params, socket) do
    IO.puts("show handle_event filter 1")

    socket =
      socket
      |> assign(:tag_filter, tags)

    #  |> assign(:filter_text, stringify_filter(tags))

    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      tag_filter: tags,
      tag_list: Onagal.Tags.list_tags_as_options()
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", _params, socket) do
    IO.puts("show handle_event filter 2")

    tags = []

    socket =
      socket
      |> assign(:tag_filter, tags)

    # |> assign(:filter_text, stringify_filter(tags))

    send_update(
      OnagalWeb.GalleryLive.FilterComponent,
      id: "filter",
      tag_filter: tags,
      tag_list: Onagal.Tags.list_tags_as_options()
    )

    {:noreply, socket}
  end

  # def handle_info({:live_session_updated, session}, socket) do
  #   IO.puts("show handle_info live_session_updated")
  #   {:noreply, assign_session_filter(socket, session)}
  # end

  defp page_title(:show), do: "Show Image"
  defp page_title(:edit), do: "Edit Image"

  defp assign_session_filter(socket, session) do
    IO.puts("show assign session_filter")

    socket
    |> assign(:tag_filter, get_session_filter(session))
  end

  defp get_session_filter(session) do
    Map.get(session, "tag_filter", [])
  end

  def stringify_filter(tags) do
    Enum.join(Enum.map(tags, fn v -> v end), ", ")
  end
end
