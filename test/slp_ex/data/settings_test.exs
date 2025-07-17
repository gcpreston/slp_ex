defmodule SlpEx.Data.SettingsTest do
  use ExUnit.Case, async: true

  alias SlpEx.Data.{Settings, Player}

  doctest SlpEx.Data.Settings

  describe "new/1" do
    test "creates new settings with default values" do
      settings = Settings.new()

      assert %Settings{
               version: nil,
               players: [],
               is_teams: false,
               item_spawn_behavior: 0,
               self_destruct_score_value: -1,
               stage_id: nil,
               stage: nil,
               game_timer: 480
             } = settings
    end

    test "creates new settings with provided attributes" do
      player = Player.new(port: 1, character: :fox)
      attrs = [players: [player], stage: :battlefield, is_teams: true]
      settings = Settings.new(attrs)

      assert settings.players == [player]
      assert settings.stage == :battlefield
      assert settings.is_teams == true
    end
  end

  describe "validate/1" do
    test "returns error when no players" do
      settings = Settings.new()

      assert {:error, "At least one player is required"} = Settings.validate(settings)
    end

    test "returns error when more than 4 players" do
      players = for i <- 1..5, do: Player.new(port: i, character: :fox)
      settings = Settings.new(players: players)

      assert {:error, "Maximum of 4 players allowed"} = Settings.validate(settings)
    end

    test "returns error when players are invalid" do
      # Invalid port
      invalid_player = Player.new(port: 0, character: :fox)
      settings = Settings.new(players: [invalid_player])

      assert {:error, "All players must be valid"} = Settings.validate(settings)
    end

    test "returns ok for valid settings" do
      player = Player.new(port: 1, character: :fox)
      settings = Settings.new(players: [player])

      assert {:ok, ^settings} = Settings.validate(settings)
    end

    test "returns error for invalid data structure" do
      assert {:error, "Invalid settings data structure"} = Settings.validate(%{})
    end
  end

  describe "player_count/1" do
    test "returns correct player count" do
      player1 = Player.new(port: 1, character: :fox)
      player2 = Player.new(port: 2, character: :falco)
      settings = Settings.new(players: [player1, player2])

      assert Settings.player_count(settings) == 2
    end

    test "returns 0 for no players" do
      settings = Settings.new()

      assert Settings.player_count(settings) == 0
    end
  end

  describe "teams?/1" do
    test "returns true for teams match" do
      settings = Settings.new(is_teams: true)

      assert Settings.teams?(settings) == true
    end

    test "returns false for non-teams match" do
      settings = Settings.new(is_teams: false)

      assert Settings.teams?(settings) == false
    end
  end

  describe "get_player/2" do
    test "returns player by port" do
      player1 = Player.new(port: 1, character: :fox)
      player2 = Player.new(port: 2, character: :falco)
      settings = Settings.new(players: [player1, player2])

      assert Settings.get_player(settings, 1) == player1
      assert Settings.get_player(settings, 2) == player2
    end

    test "returns nil for non-existent port" do
      player = Player.new(port: 1, character: :fox)
      settings = Settings.new(players: [player])

      assert Settings.get_player(settings, 3) == nil
    end
  end
end
