defmodule OnagalWeb.PageController do
  use OnagalWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
