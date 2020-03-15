defmodule Phoenix.LiveDashboard.LoggerLive do
  use Phoenix.LiveDashboard.Web, :live_view

  @impl true
  def mount(%{"stream" => stream} = params, session, socket) do
    %{"request_logger" => {param_key, cookie_key}} = session

    if connected?(socket) do
      # TODO: Remove || once we support Phoenix v1.5+
      endpoint = socket.endpoint
      pubsub_server = endpoint.config(:pubsub_server) || endpoint.__pubsub_server__()
      Phoenix.PubSub.subscribe(pubsub_server, Phoenix.LiveDashboard.RequestLogger.topic(stream))
    end

    socket =
      socket
      |> assign_defaults(params, session)
      |> assign(stream: stream, param_key: param_key, cookie_key: cookie_key, cookie_enabled: false)

    {:ok, socket, temporary_assigns: [messages: []]}
  end

  def mount(%{"node" => node}, %{"request_logger" => _}, socket) do
    stream = :crypto.strong_rand_bytes(3) |> Base.url_encode64()
    {:ok, push_redirect(socket, to: live_dashboard_path(socket, :request_logger, node, [stream]))}
  end

  @impl true
  def handle_info({:logger, level, message}, socket) do
    {:noreply, assign(socket, messages: [{message, level}])}
  end

  def handle_info({:node_redirect, node}, socket) do
    to = live_dashboard_path(socket, :request_logger, node, [socket.assigns.stream])
    {:noreply, push_redirect(socket, to: to)}
  end

  @impl true
  def handle_event("toggle_cookie", %{"enable" => "true"}, socket) do
    {:noreply, assign(socket, :cookie_enabled, true)}
  end

  def handle_event("toggle_cookie", _params, socket) do
    {:noreply, assign(socket, :cookie_enabled, false)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <%= if @messages != [] do %>
      <h5 class="card-title">Logs</h5>

      <div class="card mb-4">
        <div class="card-body">
          <div id="logger-messages" phx-update="append">
            <%= for {message, level} <- @messages do %>
              <pre id="log-<%= System.unique_integer() %>" class="log-level-<%= level %>"><%= message %></pre>
            <% end %>
          </div>
        </div>
      </div>
    <% end %>

    <div class="row">
      <%= if @param_key do %>
        <div class="col-md-6" phx-hook="PhxRequestLoggerQueryParameter">
          <h5 class="card-title">Query Parameter</h5>

          <div class="card mb-4">
            <div class="card-body">
              <p>Access any page with this query parameter:</p>

              <textarea rows="1" class="code-field text-monospace" readonly="readonly">?<%= @param_key %>=<%= sign(@socket, @param_key, @stream) %></textarea>

              <button class="btn btn-primary float-right">Copy to clipboard</button>
            </div>
          </div>
        </div>
      <% end %>

      <%= if @cookie_key do %>
        <div class="col-md-6">
          <h5 class="card-title">Cookie Parameter</h5>

          <div class="card mb-4">
            <div class="card-body">
              <p>Create a logger cookie to automatically log requests for the current browser session.</p>

              <div class="row">
                <div class="col">
                  <span class="cookie-status" data-enabled="<%= @cookie_enabled %>">Cookie enabled</span>
                </div>

                <div class="col">
                  <div phx-hook="PhxRequestLoggerCookie" id="request-logger-cookie-buttons"
                    data-cookie-key=<%=@cookie_key %>
                    data-cookie-value=<%=sign(@socket, @cookie_key, @stream) %>
                    data-cookie-enabled="<%= @cookie_enabled %>">

                    <%= if @cookie_enabled do %>
                      <button phx-click="toggle_cookie" phx-value-enable="false" class="btn btn-secondary float-right">Disable cookie</button>
                    <% else %>
                      <button phx-click="toggle_cookie" phx-value-enable="true" class="btn btn-primary float-right">Enable cookie</button>
                    <% end %>
                  </div>
                </div>
              </div>

            </div>
          </div>
        </div>
      <% end %>
    </div>

    <div class="row">
      <div class="col text-center">
        Want to refresh the logger parameter? <%= live_redirect "Activate a new stream", to: live_dashboard_path(@socket, :request_logger, @menu.node) %>
      </div>
    </div>
    """
  end

  defp sign(socket, key, value) do
    Phoenix.LiveDashboard.RequestLogger.sign(socket.endpoint, key, value)
  end
end
