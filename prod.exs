# iex -S mix run dev.exs
Logger.configure(level: :debug)

# Configures the endpoint
Application.put_env(:phoenix_live_dashboard, DemoWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "dashboard-theme.herokuapp.com", port: System.get_env("PORT")],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
  live_view: [signing_salt: "hMegieSe"],
  debug_errors: true,
  check_origin: false,
  pubsub: [name: Demo.PubSub, adapter: Phoenix.PubSub.PG2]
)

defmodule DemoWeb.Telemetry do
  import Telemetry.Metrics

  def metrics do
    [
      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end
end

defmodule DemoWeb.PageController do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, :index) do
    content(conn, """
    <h2>Phoenix LiveDashboard Dev</h2>
    <a href="/dashboard" target="_blank">Open Dashboard</a>
    """)
  end

  def call(conn, :hello) do
    name = Map.get(conn.params, "name", "friend")
    content(conn, "<p>Hello, #{name}!</p>")
  end

  defp content(conn, content) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, "<!doctype html><html><body>#{content}</body></html>")
  end
end

defmodule DemoWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :fetch_session
  end

  scope "/" do
    pipe_through :browser
    get "/", DemoWeb.PageController, :index
    get "/hello", DemoWeb.PageController, :hello
    get "/hello/:name", DemoWeb.PageController, :hello
    live_dashboard("/dashboard", metrics: DemoWeb.Telemetry)
  end
end

defmodule DemoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_live_dashboard

  socket "/live", Phoenix.LiveView.Socket

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.Session,
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "/VEDsdfsffMnp5"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug DemoWeb.Router
end

Application.put_env(:phoenix, :serve_endpoints, true)

Task.start(fn ->
  children = [DemoWeb.Endpoint]
  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  Process.sleep(:infinity)
end)
