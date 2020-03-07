defmodule Phoenix.LiveDashboard.HomeLive do
  use Phoenix.LiveDashboard.Web, :live_view

  alias Phoenix.LiveDashboard.SystemInfo

  @temporary_assigns [system_info: nil, system_usage: nil]

  @impl true
  def mount(%{"node" => _} = params, session, socket) do
    socket = assign_defaults(socket, params, session, true)

    %{
      # Read once
      system_info: system_info,
      # Kept forever
      system_limits: system_limits,
      # Updated periodically
      system_usage: system_usage
    } = SystemInfo.info(socket.assigns.menu.node)

    socket =
      assign(socket,
        system_info: system_info,
        system_limits: system_limits,
        system_usage: system_usage
      )

    {:ok, socket, temporary_assigns: @temporary_assigns}
  end

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: live_dashboard_path(socket, :home, node()))}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <h2 class="section-title">Home thing</h2>

    <div class="row">
      <div class="col-sm-6">

        <div class="box-cell">
          <h2>System info</h2>

          <p><%= @system_info.banner %></p>

          <ul>
            <li>Elixir version: <%= @system_info.elixir_version %></li>
            <li>Phoenix version: <%= @system_info.phoenix_version %></li>
            <li>Dashboard version: <%= @system_info.dashboard_version %></li>
            <li>Compiled for: <%= @system_info.system_architecture %></li>
          </ul>
        </div>

      </div>
      <div class="col-sm-6">

        <div class="box-cell">
          <h2>System usage / limits</h2>

          <section class="pb-4">
            <div>
              <strong>Atoms</strong>
            </div>

            <div class="progress flex-grow-1 my-1">
              <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: <%= used(:atoms, @system_usage, @system_limits) %>%"></div>
            </div>

            <div class="d-flex justify-content-between">
              <div>
                <%= @system_usage.atoms %> / <%= @system_limits.atoms %>
              </div>
              <div>
                <%= used(:atoms, @system_usage, @system_limits) %>% used
              </div>
            </div>
          </section>

          <strong>Ports</strong>
          <div class="progress">
            <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: <%= used(:atoms, @system_usage, @system_limits) %>%"></div>
          </div>

          <ul>
            <li>Atoms: <%= @system_usage.atoms %> / <%= @system_limits.atoms %> (<%= used(:atoms, @system_usage, @system_limits) %>% used)</li>
            <li>Ports: <%= @system_usage.ports %> / <%= @system_limits.ports %> (<%= used(:ports, @system_usage, @system_limits) %>% used)</li>
            <li>Processes: <%= @system_usage.processes %> / <%= @system_limits.processes %> (<%= used(:processes, @system_usage, @system_limits) %>% used)</li>
          </ul>
        </div>

      </div>
    </div>
    """
  end

  defp used(attr, usage, limit) do
    trunc(Map.fetch!(usage, attr) / Map.fetch!(limit, attr) * 100)
  end

  @impl true
  def handle_info({:node_redirect, node}, socket) do
    {:noreply, push_redirect(socket, to: live_dashboard_path(socket, :home, node))}
  end

  def handle_info(:refresh, socket) do
    {:noreply, assign(socket, system_usage: SystemInfo.usage(socket.assigns.menu.node))}
  end
end
