defmodule SlpEx.Data.GameTest do
  use ExUnit.Case, async: true

  alias SlpEx.Data.{Game, Settings, Player}

  doctest SlpEx.Data.Game

  describe "new/1" do
    test "creates a new game with default values" do
      game = Game.new()

      assert %Game{
               metadata: nil,
               settings: nil,
               frames: [],
               statistics: nil,
               version: nil,
               parsing_errors: []
             } = game
    end

    test "creates a new game with provided attributes" do
      attrs = [version: "3.0.0", parsing_errors: ["test error"]]
      game = Game.new(attrs)

      assert game.version == "3.0.0"
      assert game.parsing_errors == ["test error"]
      assert game.frames == []
    end
  end

  describe "validate/1" do
    test "returns error when version is nil" do
      game = Game.new()

      assert {:error, "Game version is required"} = Game.validate(game)
    end

    test "returns error when settings is nil" do
      game = Game.new(version: "3.0.0")

      assert {:error, "Game settings are required"} = Game.validate(game)
    end

    test "returns ok when game has required fields" do
      player = Player.new(port: 1, character: :fox)
      settings = Settings.new(players: [player])
      game = Game.new(version: "3.0.0", settings: settings)

      assert {:ok, ^game} = Game.validate(game)
    end

    test "returns error for invalid data structure" do
      assert {:error, "Invalid game data structure"} = Game.validate(%{})
    end
  end

  describe "add_error/2" do
    test "adds error to existing error list" do
      game = Game.new(parsing_errors: ["existing error"])
      updated_game = Game.add_error(game, "new error")

      assert updated_game.parsing_errors == ["new error", "existing error"]
    end

    test "adds error to empty error list" do
      game = Game.new()
      updated_game = Game.add_error(game, "first error")

      assert updated_game.parsing_errors == ["first error"]
    end
  end

  describe "has_errors?/1" do
    test "returns true when game has errors" do
      game = Game.new(parsing_errors: ["error"])

      assert Game.has_errors?(game) == true
    end

    test "returns false when game has no errors" do
      game = Game.new()

      assert Game.has_errors?(game) == false
    end
  end
end
