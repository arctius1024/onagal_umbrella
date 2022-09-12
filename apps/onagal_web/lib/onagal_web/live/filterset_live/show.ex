defmodule OnagalWeb.FiltersetLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Tags

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    IO.puts("filterset_show :handle_params")

    filterset = Tags.get_filterset!(id) |> Onagal.Repo.preload(:tags)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
     |> assign(:selected_tags, selected_tags(filterset))
     |> assign(:filterset, filterset)}
  end

  defp page_title(:show), do: "Show Filterset"
  defp page_title(:edit), do: "Edit Filterset"

  defp selected_tags(filterset) do
    Enum.map(filterset.tags, & &1.name)
  end
end
