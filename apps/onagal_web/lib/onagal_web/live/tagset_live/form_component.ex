defmodule OnagalWeb.TagsetLive.FormComponent do
  use OnagalWeb, :live_component

  alias Onagal.Tags

  @impl true
  def update(%{tagset: tagset} = assigns, socket) do
    changeset = Tags.change_tagset(tagset)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"tagset" => tagset_params}, socket) do
    changeset =
      socket.assigns.tagset
      |> Tags.change_tagset(tagset_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"tagset" => tagset_params}, socket) do
    save_tagset(socket, socket.assigns.action, tagset_params)
  end

  defp save_tagset(socket, :edit, tagset_params) do
    case Tags.update_tagset(socket.assigns.tagset, tagset_params) do
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
    case Tags.create_tagset(tagset_params) do
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
