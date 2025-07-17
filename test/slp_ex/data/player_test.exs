defmodule SlpEx.Data.PlayerTest do
  use ExUnit.Case, async: true

  alias SlpEx.Data.Player

  doctest SlpEx.Data.Player

  describe "new/1" do
    test "creates a new player with default values" do
      player = Player.new()

      assert %Player{
               port: nil,
               character: nil,
               tag: nil,
               player_type: :human,
               controller_fix: nil
             } = player
    end

    test "creates a new player with provided attributes" do
      attrs = [port: 1, character: :fox, tag: "Mango", player_type: :human]
      player = Player.new(attrs)

      assert player.port == 1
      assert player.character == :fox
      assert player.tag == "Mango"
      assert player.player_type == :human
    end
  end

  describe "validate/1" do
    test "returns error when port is nil" do
      player = Player.new(character: :fox)

      assert {:error, "Player port must be between 1 and 4"} = Player.validate(player)
    end

    test "returns error when port is out of range" do
      player = Player.new(port: 0, character: :fox)
      assert {:error, "Player port must be between 1 and 4"} = Player.validate(player)

      player = Player.new(port: 5, character: :fox)
      assert {:error, "Player port must be between 1 and 4"} = Player.validate(player)
    end

    test "returns error when character is nil" do
      player = Player.new(port: 1)

      assert {:error, "Player character is required"} = Player.validate(player)
    end

    test "returns error for invalid player type" do
      player = Player.new(port: 1, character: :fox, player_type: :invalid)

      assert {:error, "Invalid player type"} = Player.validate(player)
    end

    test "returns ok for valid player" do
      player = Player.new(port: 1, character: :fox, player_type: :human)

      assert {:ok, ^player} = Player.validate(player)
    end

    test "returns error for invalid data structure" do
      assert {:error, "Invalid player data structure"} = Player.validate(%{})
    end
  end

  describe "human?/1" do
    test "returns true for human player" do
      player = Player.new(player_type: :human)

      assert Player.human?(player) == true
    end

    test "returns false for non-human player" do
      player = Player.new(player_type: :cpu)

      assert Player.human?(player) == false
    end
  end

  describe "cpu?/1" do
    test "returns true for cpu player" do
      player = Player.new(player_type: :cpu)

      assert Player.cpu?(player) == true
    end

    test "returns false for non-cpu player" do
      player = Player.new(player_type: :human)

      assert Player.cpu?(player) == false
    end
  end
end
