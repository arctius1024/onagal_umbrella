defmodule OnagalWeb.FiltersetLive.FormComponent do
  use OnagalWeb, :live_component

  alias Onagal.Tags

  @impl true
  def update(%{filterset: filterset} = assigns, socket) do
    IO.puts("filterset_form :update")

    changeset = Tags.change_filterset(filterset)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"filterset" => filterset_params} = params, socket) do
    IO.puts("filterset_form :handle_event :validate")

    changeset =
      socket.assigns.filterset
      |> Tags.change_filterset(filterset_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"filterset" => filterset_params}, socket) do
    IO.puts("filterset_form :handle_event :save")

    save_filterset(socket, socket.assigns.action, filterset_params)
  end

  defp save_filterset(socket, :edit, filterset_params) do
    IO.puts("filterset_form_component save_filterset :edit")
    tags = Tags.list_tags_by_name(filterset_params["tags"])

    case Tags.update_filterset(
           socket.assigns.filterset,
           Map.merge(filterset_params, %{"tags" => tags})
         ) do
      {:ok, _filterset} ->
        {:noreply,
         socket
         |> put_flash(:info, "Filterset updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_filterset(socket, :new, filterset_params) do
    IO.puts("filterset_form_component save_filterset :new")
    tags = Tags.list_tags_by_name(filterset_params["tags"])

    case Tags.create_filterset(Map.merge(filterset_params, %{"tags" => tags})) do
      {:ok, _filterset} ->
        {:noreply,
         socket
         |> put_flash(:info, "Filterset created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
