defmodule Heros.Game do
  use Agent, restart: :temporary

  alias Heros.Game

  defstruct public: true,
            players: [],
            max_players: 4,
            stage: :lobby

  def short_infos(game) do
    Agent.get(game, fn game ->
      %{
        public: game.public,
        n_players: length(game.players),
        max_players: game.max_players,
        stage: game.stage
      }
    end)
  end

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %Game{} end)
  end

  # @doc """
  # Gets a value from the `bucket` by `key`.
  # """
  # def get(bucket, key) do
  #   Agent.get(bucket, &Map.get(&1, key))
  # end

  # @doc """
  # Puts the `value` for the given `key` in the `bucket`.
  # """
  # def put(bucket, key, value) do
  #   Agent.update(bucket, &Map.put(&1, key, value))
  # end

  # def delete(bucket, key) do
  #   Agent.get_and_update(bucket, fn dict ->
  #     Map.pop(dict, key)
  #   end)
  # end
end
