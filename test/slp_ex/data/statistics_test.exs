defmodule SlpEx.Data.StatisticsTest do
  use ExUnit.Case, async: true

  alias SlpEx.Data.Statistics

  doctest SlpEx.Data.Statistics

  describe "new/1" do
    test "creates a new statistics with default values" do
      stats = Statistics.new()

      assert %Statistics{
               match_duration: nil,
               total_frames: nil,
               winner: nil,
               game_end_method: nil,
               player_stats: %{},
               game_events: []
             } = stats
    end

    test "creates a new statistics with provided attributes" do
      attrs = [total_frames: 3600, match_duration: 60.0, winner: 1]
      stats = Statistics.new(attrs)

      assert stats.total_frames == 3600
      assert stats.match_duration == 60.0
      assert stats.winner == 1
    end
  end

  describe "validate/1" do
    test "returns ok for valid statistics with default values" do
      stats = Statistics.new()

      assert {:ok, ^stats} = Statistics.validate(stats)
    end

    test "returns error when match_duration is negative" do
      stats = Statistics.new(match_duration: -1.0)

      assert {:error, "match_duration must be a non-negative number"} = Statistics.validate(stats)
    end

    test "returns error when match_duration is not a number" do
      stats = Statistics.new(match_duration: "not_number")

      assert {:error, "match_duration must be a non-negative number"} = Statistics.validate(stats)
    end

    test "returns error when total_frames is negative" do
      stats = Statistics.new(total_frames: -1)

      assert {:error, "total_frames must be a non-negative integer"} = Statistics.validate(stats)
    end

    test "returns error when total_frames is not an integer" do
      stats = Statistics.new(total_frames: 60.5)

      assert {:error, "total_frames must be a non-negative integer"} = Statistics.validate(stats)
    end

    test "returns error when player_stats is not a map" do
      stats = Statistics.new(player_stats: "not_map")

      assert {:error, "player_stats must be a map"} = Statistics.validate(stats)
    end

    test "returns error when game_events is not a list" do
      stats = Statistics.new(game_events: "not_list")

      assert {:error, "game_events must be a list"} = Statistics.validate(stats)
    end

    test "returns error for invalid player stats" do
      # Port 0 is invalid
      invalid_stats = %{0 => %{}}
      stats = Statistics.new(player_stats: invalid_stats)

      assert {:error, "Invalid player statistics data"} = Statistics.validate(stats)
    end

    test "returns error for invalid game events" do
      # Missing required fields
      invalid_events = [%{invalid: "event"}]
      stats = Statistics.new(game_events: invalid_events)

      assert {:error, "Invalid game events data"} = Statistics.validate(stats)
    end

    test "returns ok for valid statistics with all fields" do
      player_stats = %{1 => Statistics.empty_player_stats()}
      events = [%{type: :kill, frame: 100, player: 1, data: %{}}]

      stats =
        Statistics.new(
          match_duration: 60.0,
          total_frames: 3600,
          player_stats: player_stats,
          game_events: events,
          winner: 1,
          game_end_method: :stock
        )

      assert {:ok, ^stats} = Statistics.validate(stats)
    end

    test "returns error for invalid data structure" do
      assert {:error, "Invalid statistics data structure"} = Statistics.validate(%{})
    end
  end

  describe "get_player_stats/2" do
    test "returns player stats when they exist" do
      player_stats = Statistics.empty_player_stats()
      stats = Statistics.new(player_stats: %{1 => player_stats})

      assert Statistics.get_player_stats(stats, 1) == player_stats
    end

    test "returns nil when player stats don't exist" do
      stats = Statistics.new()

      assert Statistics.get_player_stats(stats, 1) == nil
    end
  end

  describe "put_player_stats/3" do
    test "adds new player stats" do
      stats = Statistics.new()
      player_stats = Statistics.empty_player_stats()

      updated_stats = Statistics.put_player_stats(stats, 1, player_stats)

      assert updated_stats.player_stats[1] == player_stats
    end

    test "updates existing player stats" do
      old_stats = %{kill_count: 1}
      new_stats = %{kill_count: 2}
      stats = Statistics.new(player_stats: %{1 => old_stats})

      updated_stats = Statistics.put_player_stats(stats, 1, new_stats)

      assert updated_stats.player_stats[1] == new_stats
    end
  end

  describe "add_event/2" do
    test "adds event to empty event list" do
      stats = Statistics.new()
      event = %{type: :kill, frame: 100, player: 1, data: %{}}

      updated_stats = Statistics.add_event(stats, event)

      assert updated_stats.game_events == [event]
    end

    test "adds event to existing event list" do
      existing_event = %{type: :death, frame: 50, player: 2, data: %{}}
      stats = Statistics.new(game_events: [existing_event])
      new_event = %{type: :kill, frame: 100, player: 1, data: %{}}

      updated_stats = Statistics.add_event(stats, new_event)

      assert updated_stats.game_events == [new_event, existing_event]
    end
  end

  describe "get_events_by_type/2" do
    test "returns events of specified type" do
      kill_event = %{type: :kill, frame: 100, player: 1, data: %{}}
      death_event = %{type: :death, frame: 100, player: 2, data: %{}}
      stats = Statistics.new(game_events: [kill_event, death_event])

      kill_events = Statistics.get_events_by_type(stats, :kill)

      assert kill_events == [kill_event]
    end

    test "returns empty list when no events of type exist" do
      stats = Statistics.new()

      events = Statistics.get_events_by_type(stats, :kill)

      assert events == []
    end
  end

  describe "get_events_by_player/2" do
    test "returns events for specified player" do
      player1_event = %{type: :kill, frame: 100, player: 1, data: %{}}
      player2_event = %{type: :death, frame: 100, player: 2, data: %{}}
      stats = Statistics.new(game_events: [player1_event, player2_event])

      player1_events = Statistics.get_events_by_player(stats, 1)

      assert player1_events == [player1_event]
    end

    test "returns empty list when no events for player exist" do
      stats = Statistics.new()

      events = Statistics.get_events_by_player(stats, 1)

      assert events == []
    end
  end

  describe "total_kills/1" do
    test "returns sum of all player kill counts" do
      player1_stats = %{kill_count: 3}
      player2_stats = %{kill_count: 2}
      stats = Statistics.new(player_stats: %{1 => player1_stats, 2 => player2_stats})

      assert Statistics.total_kills(stats) == 5
    end

    test "returns 0 when no players have kills" do
      stats = Statistics.new()

      assert Statistics.total_kills(stats) == 0
    end

    test "handles nil kill counts" do
      player1_stats = %{kill_count: 3}
      player2_stats = %{kill_count: nil}
      stats = Statistics.new(player_stats: %{1 => player1_stats, 2 => player2_stats})

      assert Statistics.total_kills(stats) == 3
    end
  end

  describe "total_damage_dealt/1" do
    test "returns sum of all player damage dealt" do
      player1_stats = %{damage_dealt: 150.5}
      player2_stats = %{damage_dealt: 200.0}
      stats = Statistics.new(player_stats: %{1 => player1_stats, 2 => player2_stats})

      assert Statistics.total_damage_dealt(stats) == 350.5
    end

    test "returns 0.0 when no players have damage dealt" do
      stats = Statistics.new()

      assert Statistics.total_damage_dealt(stats) == 0.0
    end

    test "handles nil damage dealt" do
      player1_stats = %{damage_dealt: 150.5}
      player2_stats = %{damage_dealt: nil}
      stats = Statistics.new(player_stats: %{1 => player1_stats, 2 => player2_stats})

      assert Statistics.total_damage_dealt(stats) == 150.5
    end
  end

  describe "has_winner?/1" do
    test "returns true when winner is set" do
      stats = Statistics.new(winner: 1)

      assert Statistics.has_winner?(stats) == true
    end

    test "returns false when winner is nil" do
      stats = Statistics.new()

      assert Statistics.has_winner?(stats) == false
    end
  end

  describe "duration_seconds/1" do
    test "returns match_duration when explicitly set" do
      stats = Statistics.new(match_duration: 120.5)

      assert Statistics.duration_seconds(stats) == 120.5
    end

    test "calculates duration from total_frames when match_duration not set" do
      # 60 seconds at 60 FPS
      stats = Statistics.new(total_frames: 3600)

      assert Statistics.duration_seconds(stats) == 60.0
    end

    test "returns nil when neither duration nor frames is set" do
      stats = Statistics.new()

      assert Statistics.duration_seconds(stats) == nil
    end

    test "prefers explicit duration over calculated from frames" do
      stats = Statistics.new(match_duration: 120.0, total_frames: 3600)

      assert Statistics.duration_seconds(stats) == 120.0
    end
  end

  describe "empty_player_stats/0" do
    test "returns a properly structured empty player stats map" do
      empty_stats = Statistics.empty_player_stats()

      assert is_map(empty_stats)
      assert empty_stats.kill_count == 0
      assert empty_stats.death_count == 0
      assert empty_stats.action_count == 0
      assert is_nil(empty_stats.stocks_remaining)
      assert is_nil(empty_stats.damage_dealt)
      assert is_nil(empty_stats.damage_taken)
    end
  end
end
