defmodule Heros.Game.Helpers do
  alias Heros.Game.Cards.Card
  alias Heros.Utils.Option

  def interaction_filter(:put_card_from_discard_to_deck) do
    fn _card -> true end
  end

  def interaction_filter(:put_champion_from_discard_to_deck) do
    fn card -> Card.champion?(card.key) end
  end

  def handle_call(_message, _from, _lobby), do: Option.none()
end
