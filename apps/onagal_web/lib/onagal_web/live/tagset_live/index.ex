defmodule OnagalWeb.TagsetLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Tags
  alias Onagal.Tags.Tagset

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tagsets, list_tagsets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tagset")
    |> assign(:tagset, Tags.get_tagset!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tagset")
    |> assign(:tagset, %Tagset{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tagsets")
    |> assign(:tagset, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tagset = Tags.get_tagset!(id)
    {:ok, _} = Tags.delete_tagset(tagset)

    {:noreply, assign(socket, :tagsets, list_tagsets())}
  end

  defp list_tagsets do
    Tags.list_tagsets()
  end
end
