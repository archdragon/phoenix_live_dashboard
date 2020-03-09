defmodule Phoenix.LiveDashboard.HomeLive do
  use Phoenix.LiveDashboard.Web, :live_view

  alias Phoenix.LiveDashboard.SystemInfo

  @temporary_assigns [system_info: nil, system_usage: nil]

  @system_limits_sections [
    {:atoms, "Atoms"},
    {:ports, "Ports"},
    {:processes, "Processes"}
  ]

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
    <div class="row">
      <div class="col-sm-6">
        <h5 class="card-title">System information</h5>

        <div class="row mb-4">
              <div class="col">
                <div class="data-card background-elixir">
                  <h6 class="data-card-title">Elixir</h6>
                  <div class="data-card-value"><%= @system_info.elixir_version %></div>
                </div>
              </div>
              <div class="col">
                <div class="data-card background-phoenix">
                  <h6 class="data-card-title">Phoenix</h6>
                  <div class="data-card-value"><%= @system_info.phoenix_version %></div>
                </div>
              </div>
              <div class="col">
                <div class="data-card background-dashboard">
                  <h6 class="data-card-title">Dashboard</h6>
                  <div class="data-card-value"><%= @system_info.dashboard_version %></div>
                </div>
              </div>
        </div>

        <div class="card">
          <div class="card-body">
            <p><%= @system_info.banner %></p>
            <p class="mb-0">Compile for: <%= @system_info.system_architecture %></p>
          </div>
        </div>

      </div>
      <div class="col-sm-6">

            <h5 class="card-title">System usage / limits</h5>

            <%= for {section, title} <- system_limits_sections() do %>
              <div class="card progress-section mb-4">
                <div class="card-body">
                  <section>

                    <div class="d-flex justify-content-between">
                      <div>
                        <div><%= title %></div>
                      </div>
                      <div>
                        <small class="text-muted pr-2">
                          <%= @system_usage[section] %> / <%= @system_limits[section] %>
                        </small>
                        <strong>
                          <%= used(:atoms, @system_usage, @system_limits) %>%
                        </strong>
                      </div>
                    </div>

                    <div class="progress flex-grow-1 mt-2">
                      <div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: <%= used(:atoms, @system_usage, @system_limits) %>%"></div>
                    </div>
                  </section>
                </div>
              </div>
            <% end %>

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

  defp system_limits_sections(), do: @system_limits_sections
end
