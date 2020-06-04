defmodule Heros.Game.Helpers do
  alias Heros.Game
  alias Heros.Game.Cards.Card
  alias Heros.Utils.{KeyList, Option}

  def interaction_filter(:put_card_from_discard_to_deck) do
    fn _card -> true end
  end

  def interaction_filter(:put_champion_from_discard_to_deck) do
    fn card -> Card.champion?(card.key) end
  end

  def project(game, player_id, names) do
    {player, others} = KeyList.cycle(game.players, player_id)

    %{
      player: {player_id, project_player(player, KeyList.find(names, player_id))},
      other_players: others |> Enum.map(&project_other_player(&1, names)),
      current_player: game.current_player,
      gems: game.gems,
      market: game.market,
      market_deck: length(game.market_deck),
      cemetery: game.cemetery
    }
  end

  defp project_player(player, player_name) do
    %{
      pending_interactions: player.pending_interactions,
      temporary_effects: player.temporary_effects,
      discard_phase_done: player.discard_phase_done,
      name: player_name,
      hp: player.hp,
      max_hp: player.max_hp,
      gold: player.gold,
      combat: player.combat,
      hand: player.hand,
      deck: length(player.deck),
      discard: player.discard,
      fight_zone: player.fight_zone
    }
  end

  defp project_other_player({player_id, player}, names) do
    {player_id,
     %{
       temporary_effects: player.temporary_effects,
       name: KeyList.find(names, player_id),
       hp: player.hp,
       max_hp: player.max_hp,
       gold: player.gold,
       combat: player.combat,
       hand: length(player.hand),
       deck: length(player.deck),
       discard: player.discard,
       fight_zone: player.fight_zone
     }}
  end

  def handle_call({player_id, ["play_card", card_id]}, _from, game) do
    Game.play_card(game, player_id, card_id)
  end

  def handle_call({player_id, {:use_expend_ability, card_id}}, _from, game) do
    Game.use_expend_ability(game, player_id, card_id)
  end

  def handle_call({player_id, {:use_ally_ability, card_id}}, _from, game) do
    Game.use_ally_ability(game, player_id, card_id)
  end

  def handle_call({player_id, {:use_sacrifice_ability, card_id}}, _from, game) do
    Game.use_sacrifice_ability(game, player_id, card_id)
  end

  def handle_call({player_id, {:buy_card, card_id}}, _from, game) do
    Game.buy_card(game, player_id, card_id)
  end

  def handle_call({attacker_id, {:attack, defender_id, what}}, _from, game) do
    Game.attack(game, attacker_id, defender_id, what)
  end

  def handle_call({player_id, {:interact, interaction}}, _from, game) do
    Game.interact(game, player_id, interaction)
  end

  def handle_call({player_id, :discard_phase}, _from, game) do
    Game.discard_phase(game, player_id)
  end

  def handle_call({player_id, :draw_phase}, _from, game) do
    Game.draw_phase(game, player_id)
  end

  def handle_call(_message, _from, _lobby), do: Option.none()
end
