defmodule OnagalWeb.TagsetLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Tags

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:tagset, Tags.get_tagset!(id))}
  end

  defp page_title(:show), do: "Show Tagset"
  defp page_title(:edit), do: "Edit Tagset"
end
