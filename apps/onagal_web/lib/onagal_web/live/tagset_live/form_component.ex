defmodule OnagalWeb.TagsetLive.FormComponent do
  use OnagalWeb, :live_component

  alias Onagal.Tags

  @impl true
  def update(%{tagset: tagset} = assigns, socket) do
    IO.puts("tagset_form :update")

    changeset = Tags.change_tagset(tagset)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"tagset" => tagset_params} = params, socket) do
    IO.puts("tagset_form :handle_event :validate")

    changeset =
      socket.assigns.tagset
      |> Tags.change_tagset(tagset_params)
      |> Map.put(:action, :validate)

    IO.puts("post-changeset")

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"tagset" => tagset_params}, socket) do
    IO.puts("tagset_form :handle_event :save")

    save_tagset(socket, socket.assigns.action, tagset_params)
  end

  defp save_tagset(socket, :edit, tagset_params) do
    IO.puts("tagset_form_component save_tagset :edit")
    tags = Tags.list_tags_by_name(tagset_params["tags"])

    case Tags.update_tagset(socket.assigns.tagset, Map.merge(tagset_params, %{"tags" => tags})) do
      {:ok, _tagset} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tagset updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_tagset(socket, :new, tagset_params) do
    IO.puts("tagset_form_component save_tagset :new")
    tags = Tags.list_tags_by_name(tagset_params["tags"])

    case Tags.create_tagset(Map.merge(tagset_params, %{"tags" => tags})) do
      {:ok, _tagset} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tagset created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
