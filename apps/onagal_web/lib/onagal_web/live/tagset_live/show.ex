defmodule OnagalWeb.TagsetLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Tags

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    IO.puts("tagset_show :handle_params")

    tagset = Tags.get_tagset!(id) |> Onagal.Repo.preload(:tags)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
     |> assign(:selected_tags, selected_tags(tagset))
     |> assign(:tagset, tagset)}
  end

  defp page_title(:show), do: "Show Tagset"
  defp page_title(:edit), do: "Edit Tagset"

  defp selected_tags(tagset) do
    Enum.map(tagset.tags, & &1.name)
  end
end
