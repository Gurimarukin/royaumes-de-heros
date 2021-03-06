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

  def handle_call({player_id, "surrender"}, _from, game, names) do
    Game.surrender(game, player_id)
    |> map_update(&{&1, {KeyList.find(names, player_id), :surrendered}})
  end

  def handle_call({player_id, ["play_card", card_id]}, _from, game, names) do
    Game.play_card(game, player_id, card_id)
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:play_card, with_card(game, player_id, fn p -> p.hand end, card_id)}}}
    )
  end

  def handle_call({player_id, ["use_expend_ability", card_id]}, _from, game, names) do
    Game.use_expend_ability(game, player_id, card_id)
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:use_expend_ability, with_card(game, player_id, fn p -> p.fight_zone end, card_id)}}}
    )
  end

  def handle_call({player_id, ["use_ally_ability", card_id]}, _from, game, names) do
    Game.use_ally_ability(game, player_id, card_id)
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:use_ally_ability, with_card(game, player_id, fn p -> p.fight_zone end, card_id)}}}
    )
  end

  def handle_call({player_id, ["use_sacrifice_ability", card_id]}, _from, game, names) do
    Game.use_sacrifice_ability(game, player_id, card_id)
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:use_sacrifice_ability, with_card(game, player_id, fn p -> p.fight_zone end, card_id)}}}
    )
  end

  def handle_call({player_id, ["buy_card", card_id]}, _from, game, names) do
    Game.buy_card(game, player_id, card_id)
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:buy_card,
         case KeyList.find(game.gems ++ game.market, card_id) do
           nil -> nil
           c -> c.key
         end}}}
    )
  end

  def handle_call({attacker_id, ["attack", defender_id, "__player"]}, _from, game, names) do
    Game.attack(game, attacker_id, defender_id, :player)
    |> map_update(
      &{&1,
       {KeyList.find(names, attacker_id), {:attack, KeyList.find(names, defender_id), :player}}}
    )
  end

  def handle_call({attacker_id, ["attack", defender_id, card_id]}, _from, game, names) do
    Game.attack(game, attacker_id, defender_id, card_id)
    |> map_update(
      &{&1,
       {KeyList.find(names, attacker_id),
        {:attack, KeyList.find(names, defender_id),
         with_card(game, defender_id, fn p -> p.fight_zone end, card_id)}}}
    )
  end

  # interactions start

  def handle_call({player_id, ["interact", ["discard_card", card_id]]}, _from, game, names) do
    Game.interact(game, player_id, {:discard_card, card_id})
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:interact, {:discard_card, with_card(game, player_id, fn p -> p.hand end, card_id)}}}}
    )
  end

  def handle_call({player_id, ["interact", ["draw_then_discard", discard]]}, _from, game, names) do
    Game.interact(game, player_id, {:draw_then_discard, discard})
    |> map_update(
      &{&1, {KeyList.find(names, player_id), {:interact, {:draw_then_discard, discard}}}}
    )
  end

  def handle_call({player_id, ["interact", ["prepare_champion", card_id]]}, _from, game, names) do
    Game.interact(game, player_id, {:prepare_champion, card_id})
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:interact,
         {:prepare_champion, with_card(game, player_id, fn p -> p.fight_zone end, card_id)}}}}
    )
  end

  def handle_call(
        {player_id, ["interact", ["put_card_from_discard_to_deck", card_id]]},
        _from,
        game,
        names
      ) do
    Game.interact(game, player_id, {:put_card_from_discard_to_deck, card_id})
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:interact,
         {:put_card_from_discard_to_deck,
          with_card(game, player_id, fn p -> p.discard end, card_id)}}}}
    )
  end

  def handle_call(
        {player_id, ["interact", ["put_champion_from_discard_to_deck", card_id]]},
        _from,
        game,
        names
      ) do
    Game.interact(game, player_id, {:put_champion_from_discard_to_deck, card_id})
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:interact,
         {:put_champion_from_discard_to_deck,
          with_card(game, player_id, fn p -> p.discard end, card_id)}}}}
    )
  end

  def handle_call(
        {attacker_id, ["interact", ["stun_champion", defender_id, card_id]]},
        _from,
        game,
        names
      ) do
    Game.interact(game, attacker_id, {:stun_champion, defender_id, card_id})
    |> map_update(
      &{&1,
       {KeyList.find(names, attacker_id),
        {:interact,
         {:stun_champion, KeyList.find(names, defender_id),
          with_card(game, defender_id, fn p -> p.fight_zone end, card_id)}}}}
    )
  end

  def handle_call(
        {player_id, ["interact", ["target_opponent_to_discard", who]]},
        _from,
        game,
        names
      ) do
    Game.interact(game, player_id, {:target_opponent_to_discard, who})
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:interact, {:target_opponent_to_discard, KeyList.find(names, who)}}}}
    )
  end

  def handle_call(
        {player_id, ["interact", ["sacrifice_from_hand_or_discard", card_ids]]},
        _from,
        game,
        names
      ) do
    Game.interact(game, player_id, {:sacrifice_from_hand_or_discard, card_ids})
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:interact,
         {:sacrifice_from_hand_or_discard,
          card_ids
          |> Enum.map(fn card_id ->
            with_card(game, player_id, fn p -> p.hand ++ p.discard end, card_id)
          end)}}}}
    )
  end

  def handle_call({player_id, ["interact", ["select_effect", index]]}, _from, game, names) do
    Game.interact(game, player_id, {:select_effect, index})
    |> map_update(
      &{&1,
       {KeyList.find(names, player_id),
        {:interact, {:select_effect, with_effect(game, player_id, index)}}}}
    )
  end

  # interactions end

  def handle_call({player_id, "discard_phase"}, _from, game, names) do
    Game.discard_phase(game, player_id)
    |> map_update(&{&1, {KeyList.find(names, player_id), :discard_phase}})
  end

  def handle_call({player_id, "draw_phase"}, _from, game, names) do
    Game.draw_phase(game, player_id)
    |> map_update(&{&1, {KeyList.find(names, &1.current_player), :new_turn}})
  end

  def handle_call(_message, _from, _lobby, _names), do: Option.none()

  defp with_card(game, player_id, get_cards, card_id) do
    case KeyList.find(game.players, player_id) do
      nil ->
        nil

      player ->
        case KeyList.find(get_cards.(player), card_id) do
          nil -> nil
          c -> c.key
        end
    end
  end

  defp with_effect(game, player_id, index) do
    case KeyList.find(game.players, player_id) do
      nil -> nil
      %{pending_interactions: [{:select_effect, effects} | _]} -> Enum.at(effects, index)
      _ -> nil
    end
  end

  @spec map_update(update :: Game.update(), f :: (Game.t() -> Game.t())) :: Game.update()
  defp map_update({:victory, winner_id, game}, f), do: {:victory, winner_id, f.(game)}
  defp map_update(option, f), do: Option.map(option, f)
end
