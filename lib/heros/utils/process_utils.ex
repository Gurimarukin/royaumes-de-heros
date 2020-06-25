defmodule Heros.Utils.ProcessUtils do
  def send_self_after(time, message) do
    slef = self()

    Task.start(fn ->
      Process.sleep(time)
      if Process.alive?(slef), do: send(slef, message)
    end)
  end
end
