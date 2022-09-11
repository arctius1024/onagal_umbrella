defmodule OnagalWeb.TagsetLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Tags
  alias Onagal.Tags.Tagset

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tagset_collection, list_tagset())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    IO.puts("tagset_index apply_action :edit")
    tagset = Tags.get_tagset!(id) |> Onagal.Repo.preload(:tags)

    socket
    |> assign(:page_title, "Edit Tagset")
    |> assign(:tagset, tagset)
    |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
    |> assign(:selected_tags, selected_tags(tagset))
    |> assign(:tag_filter, [])
  end

  defp apply_action(socket, :new, _params) do
    IO.puts("tagset_index apply_action :new")

    socket
    |> assign(:page_title, "New Tagset")
    |> assign(:tagset, %Tagset{tags: []})
    |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
    |> assign(:selected_tags, [])
    |> assign(:tag_filter, [])
  end

  defp apply_action(socket, :index, _params) do
    IO.puts("tagset_index apply_action :index")

    socket
    |> assign(:page_title, "Listing Tagset")
    |> assign(:tag_list, Onagal.Tags.list_tags_as_options())
    |> assign(:tagset, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tagset = Tags.get_tagset!(id)
    {:ok, _} = Tags.delete_tagset(tagset)

    {:noreply, assign(socket, :tagset_collection, list_tagset())}
  end

  defp list_tagset do
    IO.puts("tagset_index :list_tagset")

    Tags.list_tagsets()
    |> Onagal.Repo.preload(:tags)
  end

  defp selected_tags(tagset) do
    Enum.map(tagset.tags, & &1.name)
  end
end
