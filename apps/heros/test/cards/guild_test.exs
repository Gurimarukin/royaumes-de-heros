defmodule Heros.Cards.GuildTest do
  use ExUnit.Case, async: true

  alias Heros.{Cards, Game, Player}
  alias Heros.Cards.Card

  test "borg" do
    assert Card.cost(:borg) == 6
    assert Card.type(:borg) == {:guard, 6}
    assert Card.faction(:borg) == :guild
    assert Card.champion?(:borg)
    assert Card.guard?(:borg)

    [borg] = Cards.with_id(:borg)

    {id, card} = borg
    expended_borg = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hp: 10, hand: [borg]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(borg, 0))

    p1 = %{p1 | hand: [], fight_zone: [borg]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(borg, 0))

    p1 = %{p1 | combat: 4, fight_zone: [expended_borg]}

    assert Game.player(game, "p1") == p1
  end

  test "bribe" do
    assert Card.cost(:bribe) == 3
    assert Card.type(:bribe) == :action
    assert Card.faction(:bribe) == :guild
    assert not Card.champion?(:bribe)
    assert not Card.guard?(:bribe)

    [bribe] = Cards.with_id(:bribe)
    [rasmus] = Cards.with_id(:rasmus)
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [recruit] = Cards.with_id(:recruit)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    {id, card} = bribe
    expended_bribe = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | gold: 10,
        hand: [bribe],
        fight_zone: [rasmus],
        deck: [gem1],
        discard: [gem2]
    }

    p2 = Player.empty()

    game = %{
      Game.empty([{"p1", p1}, {"p2", p2}], "p1")
      | market: [tithe_priest, recruit]
    }

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(bribe, 0))

    p1 = %{p1 | gold: 13, hand: [], fight_zone: [rasmus, bribe]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(bribe, 0))

    p1 = %{
      p1
      | temporary_effects: [:put_next_purchased_action_on_deck],
        fight_zone: [rasmus, expended_bribe]
    }

    assert Game.player(game, "p1") == p1

    # buy champion
    assert {:ok, game} = Game.buy_card(game, "p1", elem(tithe_priest, 0))

    p1 = %{p1 | gold: 11, discard: [tithe_priest, gem2]}

    assert Game.player(game, "p1") == p1
    assert game.market == [nil, recruit]

    before_buy_action = game

    # buy action
    assert {:ok, game} = Game.buy_card(game, "p1", elem(recruit, 0))

    p1 = %{p1 | gold: 9, temporary_effects: [], deck: [recruit, gem1]}

    assert Game.player(game, "p1") == p1
    assert game.market == [nil, nil]

    # discard phase
    game = before_buy_action

    assert {:ok, game} = Game.discard_phase(game, "p1")

    p1 = Game.player(game, "p1")

    assert p1.temporary_effects == []
  end

  test "death_threat" do
    assert Card.cost(:death_threat) == 3
    assert Card.type(:death_threat) == :action
    assert Card.faction(:death_threat) == :guild
    assert not Card.champion?(:death_threat)
    assert not Card.guard?(:death_threat)

    [death_threat] = Cards.with_id(:death_threat)
    [rasmus] = Cards.with_id(:rasmus)
    [arkus] = Cards.with_id(:arkus)
    [kraka] = Cards.with_id(:kraka)
    [cron] = Cards.with_id(:cron)
    [darian] = Cards.with_id(:darian)

    {id, card} = death_threat
    expended_death_threat = {id, %{card | ally_ability_used: true}}

    {id, card} = arkus
    expended_arkus = {id, %{card | expend_ability_used: true}}

    # when enemy has a champion
    p1 = %{Player.empty() | hp: 10, hand: [death_threat], fight_zone: [rasmus]}
    p2 = %{Player.empty() | fight_zone: [expended_arkus, kraka]}
    p3 = %{Player.empty() | fight_zone: [cron]}
    p4 = Player.empty()
    p5 = %{Player.empty() | hp: 0, fight_zone: [darian]}
    game = Game.empty([{"p1", p1}, {"p2", p2}, {"p3", p3}, {"p4", p4}, {"p5", p5}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(death_threat, 0))

    p1 = %{p1 | hand: [], fight_zone: [rasmus, death_threat]}

    assert Game.player(game, "p1") == p1

    before_ally = {game, p1}

    # ally then interact (one guard, one non guard)
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(death_threat, 0))

    p1 = %{
      p1
      | pending_interactions: [:stun_champion],
        fight_zone: [rasmus, expended_death_threat]
    }

    assert Game.player(game, "p1") == p1

    # can't stun non guard if there is a guard
    assert :error = Game.interact(game, "p1", {:stun_champion, "p2", elem(kraka, 0)})
    # can't target non neightbour player
    assert :error = Game.interact(game, "p1", {:stun_champion, "p3", elem(cron, 0)})

    assert {:ok, game} = Game.interact(game, "p1", {:stun_champion, "p2", elem(arkus, 0)})

    p1 = %{p1 | pending_interactions: []}
    p2 = %{p2 | fight_zone: [kraka], discard: [arkus]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2

    # ally (no champions), nothing to interact with
    {game, p1} = before_ally
    p2 = Player.empty()
    game = Game.update_player(game, "p2", fn _ -> p2 end)

    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(death_threat, 0))

    p1 = %{p1 | pending_interactions: [], fight_zone: [rasmus, expended_death_threat]}

    assert Game.player(game, "p1") == p1
    assert Game.player(game, "p2") == p2
  end

  test "deception" do
    assert Card.cost(:deception) == 5
    assert Card.type(:deception) == :action
    assert Card.faction(:deception) == :guild
    assert not Card.champion?(:deception)
    assert not Card.guard?(:deception)

    [deception] = Cards.with_id(:deception)
    [rasmus] = Cards.with_id(:rasmus)
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    {id, card} = deception
    expended_deception = {id, %{card | ally_ability_used: true}}

    p1 = %{
      Player.empty()
      | gold: 10,
        hand: [deception],
        fight_zone: [rasmus],
        deck: [gem1],
        discard: [gem2]
    }

    p2 = Player.empty()

    game = %{
      Game.empty([{"p1", p1}, {"p2", p2}], "p1")
      | market: [tithe_priest]
    }

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(deception, 0))

    p1 = %{p1 | gold: 12, hand: [gem1], fight_zone: [rasmus, deception], deck: []}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(deception, 0))

    p1 = %{
      p1
      | temporary_effects: [:put_next_purchased_card_in_hand],
        fight_zone: [rasmus, expended_deception]
    }

    assert Game.player(game, "p1") == p1

    # buy card
    assert {:ok, game} = Game.buy_card(game, "p1", elem(tithe_priest, 0))

    p1 = %{p1 | gold: 10, temporary_effects: [], hand: [gem1, tithe_priest]}

    assert Game.player(game, "p1") == p1
    assert game.market == [nil]
  end

  test "fire_bomb" do
    assert Card.cost(:fire_bomb) == 8
    assert Card.type(:fire_bomb) == :action
    assert Card.faction(:fire_bomb) == :guild
    assert not Card.champion?(:fire_bomb)
    assert not Card.guard?(:fire_bomb)

    [fire_bomb] = Cards.with_id(:fire_bomb)
    [arkus] = Cards.with_id(:arkus)
    [gem1, gem2] = Cards.with_id(:gem, 2)

    # without enemy champion

    p1 = %{Player.empty() | hand: [fire_bomb], deck: [gem1], discard: [gem2]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(fire_bomb, 0))

    p1 = %{
      p1
      | combat: 8,
        hand: [gem1],
        fight_zone: [fire_bomb],
        deck: []
    }

    assert Game.player(game, "p1") == p1

    # sacrifice
    assert {:ok, game} = Game.use_sacrifice_ability(game, "p1", elem(fire_bomb, 0))

    p1 = %{p1 | combat: 13, fight_zone: []}

    assert Game.player(game, "p1") == p1
    assert game.cemetery == [fire_bomb]

    # with enemy champion

    p1 = %{Player.empty() | hand: [fire_bomb], deck: [gem1], discard: [gem2]}
    p2 = %{Player.empty() | fight_zone: [arkus]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(fire_bomb, 0))

    p1 = %{
      p1
      | combat: 8,
        pending_interactions: [:stun_champion],
        hand: [gem1],
        fight_zone: [fire_bomb],
        deck: []
    }

    assert Game.player(game, "p1") == p1

    # interaction
    assert {:ok, game} = Game.interact(game, "p1", {:stun_champion, "p2", elem(arkus, 0)})

    p2 = %{p2 | fight_zone: [], discard: [arkus]}

    assert Game.player(game, "p2") == p2
  end

  test "hit_job" do
    assert Card.cost(:hit_job) == 4
    assert Card.type(:hit_job) == :action
    assert Card.faction(:hit_job) == :guild
    assert not Card.champion?(:hit_job)
    assert not Card.guard?(:hit_job)

    [hit_job] = Cards.with_id(:hit_job)
    [rasmus] = Cards.with_id(:rasmus)
    [arkus] = Cards.with_id(:arkus)

    {id, card} = hit_job
    expended_hit_job = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [hit_job], fight_zone: [rasmus]}
    p2 = %{Player.empty() | fight_zone: [arkus]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(hit_job, 0))

    p1 = %{p1 | combat: 7, hand: [], fight_zone: [rasmus, hit_job]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(hit_job, 0))

    p1 = %{p1 | pending_interactions: [:stun_champion], fight_zone: [rasmus, expended_hit_job]}

    assert Game.player(game, "p1") == p1
  end

  test "intimidation" do
    assert Card.cost(:intimidation) == 2
    assert Card.type(:intimidation) == :action
    assert Card.faction(:intimidation) == :guild
    assert not Card.champion?(:intimidation)
    assert not Card.guard?(:intimidation)

    [intimidation] = Cards.with_id(:intimidation)
    [rasmus] = Cards.with_id(:rasmus)

    {id, card} = intimidation
    expended_intimidation = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [intimidation], fight_zone: [rasmus]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(intimidation, 0))

    p1 = %{p1 | combat: 5, hand: [], fight_zone: [rasmus, intimidation]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(intimidation, 0))

    p1 = %{p1 | gold: 2, fight_zone: [rasmus, expended_intimidation]}

    assert Game.player(game, "p1") == p1
  end

  test "myros" do
    assert Card.cost(:myros) == 5
    assert Card.type(:myros) == {:guard, 3}
    assert Card.faction(:myros) == :guild
    assert Card.champion?(:myros)
    assert Card.guard?(:myros)

    [myros] = Cards.with_id(:myros)
    [rasmus] = Cards.with_id(:rasmus)

    {id, card} = myros
    expended_myros = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_myros
    full_expended_myros = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [myros], fight_zone: [rasmus]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(myros, 0))

    p1 = %{p1 | hand: [], fight_zone: [rasmus, myros]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(myros, 0))

    p1 = %{p1 | gold: 3, fight_zone: [rasmus, expended_myros]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(myros, 0))

    p1 = %{p1 | combat: 4, fight_zone: [rasmus, full_expended_myros]}

    assert Game.player(game, "p1") == p1
  end

  test "parov" do
    assert Card.cost(:parov) == 5
    assert Card.type(:parov) == {:guard, 5}
    assert Card.faction(:parov) == :guild
    assert Card.champion?(:parov)
    assert Card.guard?(:parov)

    [parov] = Cards.with_id(:parov)
    [rasmus] = Cards.with_id(:rasmus)
    [gem] = Cards.with_id(:gem)

    {id, card} = parov
    expended_parov = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_parov
    full_expended_parov = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [parov], fight_zone: [rasmus], deck: [gem]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(parov, 0))

    p1 = %{p1 | hand: [], fight_zone: [rasmus, parov]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(parov, 0))

    p1 = %{p1 | combat: 3, fight_zone: [rasmus, expended_parov]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(parov, 0))

    p1 = %{p1 | hand: [gem], deck: [], fight_zone: [rasmus, full_expended_parov]}

    assert Game.player(game, "p1") == p1
  end

  test "profit" do
    assert Card.cost(:profit) == 1
    assert Card.type(:profit) == :action
    assert Card.faction(:profit) == :guild
    assert not Card.champion?(:profit)
    assert not Card.guard?(:profit)

    [profit] = Cards.with_id(:profit)
    [rasmus] = Cards.with_id(:rasmus)

    {id, card} = profit
    expended_profit = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [profit], fight_zone: [rasmus]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(profit, 0))

    p1 = %{p1 | gold: 2, hand: [], fight_zone: [rasmus, profit]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(profit, 0))

    p1 = %{p1 | combat: 4, fight_zone: [rasmus, expended_profit]}

    assert Game.player(game, "p1") == p1
  end

  test "rake" do
    assert Card.cost(:rake) == 7
    assert Card.type(:rake) == {:not_guard, 7}
    assert Card.faction(:rake) == :guild
    assert Card.champion?(:rake)
    assert not Card.guard?(:rake)

    [rake] = Cards.with_id(:rake)
    [arkus] = Cards.with_id(:arkus)

    {id, card} = rake
    expended_rake = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hand: [rake]}
    p2 = %{Player.empty() | fight_zone: [arkus]}
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(rake, 0))

    p1 = %{p1 | hand: [], fight_zone: [rake]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(rake, 0))

    p1 = %{p1 | combat: 4, pending_interactions: [:stun_champion], fight_zone: [expended_rake]}

    assert Game.player(game, "p1") == p1
  end

  test "rasmus" do
    assert Card.cost(:rasmus) == 4
    assert Card.type(:rasmus) == {:not_guard, 5}
    assert Card.faction(:rasmus) == :guild
    assert Card.champion?(:rasmus)
    assert not Card.guard?(:rasmus)

    [rasmus] = Cards.with_id(:rasmus)
    [profit] = Cards.with_id(:profit)
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [gem] = Cards.with_id(:gem)

    {id, card} = rasmus
    expended_rasmus = {id, %{card | expend_ability_used: true}}

    {id, card} = expended_rasmus
    full_expended_rasmus = {id, %{card | ally_ability_used: true}}

    p1 = %{Player.empty() | hand: [rasmus], fight_zone: [profit], deck: [gem]}
    p2 = Player.empty()
    game = %{Game.empty([{"p1", p1}, {"p2", p2}], "p1") | market: [tithe_priest]}

    assert {:ok, game} = Game.play_card(game, "p1", elem(rasmus, 0))

    p1 = %{p1 | hand: [], fight_zone: [profit, rasmus]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(rasmus, 0))

    p1 = %{p1 | gold: 2, fight_zone: [profit, expended_rasmus]}

    assert Game.player(game, "p1") == p1

    # ally
    assert {:ok, game} = Game.use_ally_ability(game, "p1", elem(rasmus, 0))

    p1 = %{
      p1
      | temporary_effects: [:put_next_purchased_card_on_deck],
        fight_zone: [profit, full_expended_rasmus]
    }

    assert Game.player(game, "p1") == p1

    # buy card
    assert {:ok, game} = Game.buy_card(game, "p1", elem(tithe_priest, 0))

    p1 = %{p1 | gold: 0, temporary_effects: [], deck: [tithe_priest, gem]}

    assert Game.player(game, "p1") == p1
    assert game.market == [nil]
  end

  test "smash_and_grab" do
    assert Card.cost(:smash_and_grab) == 6
    assert Card.type(:smash_and_grab) == :action
    assert Card.faction(:smash_and_grab) == :guild
    assert not Card.champion?(:smash_and_grab)
    assert not Card.guard?(:smash_and_grab)

    [smash_and_grab] = Cards.with_id(:smash_and_grab)
    [tithe_priest] = Cards.with_id(:tithe_priest)
    [arkus] = Cards.with_id(:arkus)
    [gem] = Cards.with_id(:gem)

    # with discarded cards

    p1 = %{Player.empty() | hand: [smash_and_grab], deck: [gem], discard: [tithe_priest, arkus]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(smash_and_grab, 0))

    p1 = %{
      p1
      | combat: 6,
        pending_interactions: [:put_card_from_discard_to_deck],
        hand: [],
        fight_zone: [smash_and_grab]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # interaction

    # not a discarded card
    assert :error = Game.interact(game, "p1", {:put_card_from_discard_to_deck, elem(gem, 0)})

    # use interaction
    assert {:ok, game} =
             Game.interact(game, "p1", {:put_card_from_discard_to_deck, elem(arkus, 0)})

    p1 = %{p1 | pending_interactions: [], deck: [arkus, gem], discard: [tithe_priest]}

    assert Game.player(game, "p1") == p1

    # don't use interaction
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:put_card_from_discard_to_deck, nil})

    p1 = %{p1 | pending_interactions: []}

    assert Game.player(game, "p1") == p1

    # without discarded cards

    p1 = %{Player.empty() | hand: [smash_and_grab], deck: [gem], discard: []}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    # primary
    assert {:ok, game} = Game.play_card(game, "p1", elem(smash_and_grab, 0))

    p1 = %{p1 | hand: [], fight_zone: [smash_and_grab], combat: 6}

    assert Game.player(game, "p1") == p1
  end

  test "street_thug" do
    assert Card.cost(:street_thug) == 3
    assert Card.type(:street_thug) == {:not_guard, 4}
    assert Card.faction(:street_thug) == :guild
    assert Card.champion?(:street_thug)
    assert not Card.guard?(:street_thug)

    [street_thug] = Cards.with_id(:street_thug)

    {id, card} = street_thug
    expended_street_thug = {id, %{card | expend_ability_used: true}}

    p1 = %{Player.empty() | hand: [street_thug]}
    p2 = Player.empty()
    game = Game.empty([{"p1", p1}, {"p2", p2}], "p1")

    assert {:ok, game} = Game.play_card(game, "p1", elem(street_thug, 0))

    p1 = %{p1 | hand: [], fight_zone: [street_thug]}

    assert Game.player(game, "p1") == p1

    # expend
    assert {:ok, game} = Game.use_expend_ability(game, "p1", elem(street_thug, 0))

    p1 = %{
      p1
      | pending_interactions: [select_effect: [add_gold: 1, add_combat: 2]],
        fight_zone: [expended_street_thug]
    }

    assert Game.player(game, "p1") == p1

    before_interact = {game, p1}

    # interaction 0
    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 0})

    p1 = %{p1 | pending_interactions: [], gold: 1}

    assert Game.player(game, "p1") == p1

    # interaction 1
    {game, p1} = before_interact

    assert {:ok, game} = Game.interact(game, "p1", {:select_effect, 1})

    p1 = %{p1 | pending_interactions: [], combat: 2}

    assert Game.player(game, "p1") == p1
  end
end
