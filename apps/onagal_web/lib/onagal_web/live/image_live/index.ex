defmodule OnagalWeb.ImageLive.Index do
  use OnagalWeb, :live_view

  alias Onagal.Images
  alias Onagal.Tags

  @impl true
  def mount(_params, session, socket) do
    # if connected?(socket) do
    #   Phoenix.PubSub.subscribe(Onagal.PubSub, "page_#{get_user_id(session)}")
    # end

    {:ok,
     socket
     |> assign(:user_id, get_user_id(session))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Image")
    |> assign(:image, Images.get_image!(id))
  end

  defp apply_action(socket, :index, params) do
    filter = fn -> %{"tags" => ""} end

    socket
    |> assign(:page_title, "Listing Images")
    |> assign(:image, nil)
    |> assign_new(:filter, filter)
    |> assign(:page, list_images(params, filter.()))
  end

  @impl true
  def handle_event("filter", %{"image_tag_filter" => %{"tags" => tags}} = params, socket) do
    socket = assign(socket, :filter, %{"tags" => tags})
    socket = assign(socket, :page, list_images(params, socket.assigns.filter))

    # Phoenix.PubSub.broadcast(
    #   Onagal.PubSub,
    #   "page_#{socket.assigns.user_id}",
    #   %{"filter" => socket.assigns.filter}
    # )

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{} = params, socket) do
    socket = assign(socket, :filter, %{"tags" => ""})
    socket = assign(socket, :page, list_images(params, socket.assigns.filter))

    # Phoenix.PubSub.broadcast(
    #   Onagal.PubSub,
    #   "page_#{socket.assigns.user_id}",
    #   %{"filter" => socket.assigns.filter}
    # )

    {:noreply, socket}
  end

  # @impl true
  # def handle_info(%{"filter" => filters} = _info, socket) do
  #   {:noreply, socket |> assign(:filter, filters)}
  # end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    image = Images.get_image!(id)
    # {:ok, _} = Images.delete_image(image)
    {:ok, _} = Onagal.Fs.cleanup_file(Images.full_image_path(image))

    {:noreply, assign(socket, :images, list_images({}))}
  end

  @impl true
  @doc """
    returns a list of paginated images
    params: pagination config
    filters: tag filters (%{"tags" => "" | [] })
  """
  defp list_images(params, %{"tags" => ""} = filters) do
    Images.paginate_images(params)
  end

  defp list_images(params, %{"tags" => tags} = filters) when is_binary(tags) do
    Images.paginate_images_with_tags(params, [tags])
  end

  defp list_images(params, %{"tags" => tags} = filters) when is_list(tags) do
    Images.paginate_images_with_tags(params, tags)
  end

  defp list_images(params) do
    Images.paginate_images(params)
  end

  defp available_tags, do: Tags.list_tags()

  defp resolve_thumbnail_path(image) do
    if !File.exists?(Images.system_thumbnail_image_path(image)),
      do: Images.generate_thumbnail(image)

    Images.web_thumbnail_image_path(image)
  end

  # defp get_user_id(session) do
  #   user_token = session["user_token"]
  #   user = user_token && Onagal.Accounts.get_user_by_session_token(user_token)
  #   user.id
  # end
end
