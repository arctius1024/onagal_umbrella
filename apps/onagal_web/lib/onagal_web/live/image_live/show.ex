defmodule OnagalWeb.ImageLive.Show do
  use OnagalWeb, :live_view

  alias Onagal.Images

  @impl true
  def mount(_params, session, socket) do
    # if connected?(socket) do
    #   Phoenix.PubSub.subscribe(Onagal.PubSub, "page_#{get_user_id(session)}")
    # end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    image = Images.get_image!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:image, image)
     |> assign(:next_image, Images.get_next_image(image.id))
     |> assign(:prev_image, Images.get_prev_image(image.id))
     |> assign(:image_path, Routes.static_path(socket, Images.web_image_path(image)))}
  end

  @impl true
  def handle_info(%{"filter" => filters} = _info, socket) do
    {:noreply, socket |> assign(:filter, filters)}
  end

  defp page_title(:show), do: "Show Image"
  defp page_title(:edit), do: "Edit Image"

  # defp get_user_id(session) do
  #   user_token = session["user_token"]
  #   user = user_token && Onagal.Accounts.get_user_by_session_token(user_token)
  #   user.id
  # end
end
