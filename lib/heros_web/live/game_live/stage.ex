defmodule HerosWeb.GameLive.Stage do
  @callback default_assigns(game :: term) :: [{term, term}]

  @callback handle_info(msg :: term, socket :: Phoenix.LiveView.Socket.t()) ::
              {:noreply, Phoenix.LiveView.Socket.t()} | {:stop, Phoenix.LiveView.Socket.t()}

  @callback handle_event(
              event :: binary,
              Phoenix.LiveView.unsigned_params(),
              socket :: Phoenix.LiveView.Socket.t()
            ) ::
              {:noreply, Phoenix.LiveView.Socket.t()} | {:stop, Phoenix.LiveView.Socket.t()}

  @callback render(assigns :: Phoenix.LiveView.Socket.assigns()) ::
              Phoenix.LiveView.Rendered.t()
end
