defmodule CollywobbleWeb.PageController do
  use CollywobbleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
