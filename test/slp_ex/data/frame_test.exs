defmodule SlpEx.Data.FrameTest do
  use ExUnit.Case, async: true

  alias SlpEx.Data.Frame

  doctest SlpEx.Data.Frame

  describe "new/1" do
    test "creates a new frame with default values" do
      frame = Frame.new()

      assert %Frame{
               index: nil,
               pre_frame: %{player_states: %{}, inputs: %{}},
               post_frame: %{
                 player_states: %{},
                 positions: %{},
                 velocities: %{},
                 animation_states: %{}
               },
               is_rollback: false
             } = frame
    end

    test "creates a new frame with provided attributes" do
      attrs = [index: 100, is_rollback: true]
      frame = Frame.new(attrs)

      assert frame.index == 100
      assert frame.is_rollback == true
    end
  end

  describe "validate/1" do
    test "returns error when index is nil" do
      frame = Frame.new()

      assert {:error, "Frame index is required"} = Frame.validate(frame)
    end

    test "returns error when index is not an integer" do
      frame = Frame.new(index: "not_integer")

      assert {:error, "Frame index must be an integer"} = Frame.validate(frame)
    end

    test "returns error when is_rollback is not boolean" do
      frame = Frame.new(index: 100, is_rollback: "not_boolean")

      assert {:error, "is_rollback must be a boolean"} = Frame.validate(frame)
    end

    test "returns ok for valid frame" do
      frame = Frame.new(index: 100)

      assert {:ok, ^frame} = Frame.validate(frame)
    end

    test "returns error for invalid data structure" do
      assert {:error, "Invalid frame data structure"} = Frame.validate(%{})
    end
  end

  describe "rollback?/1" do
    test "returns true for rollback frame" do
      frame = Frame.new(is_rollback: true)

      assert Frame.rollback?(frame) == true
    end

    test "returns false for non-rollback frame" do
      frame = Frame.new(is_rollback: false)

      assert Frame.rollback?(frame) == false
    end
  end

  describe "get_pre_player_state/2" do
    test "returns player state when it exists" do
      player_state = %{position_x: 10.0, position_y: 20.0}
      pre_frame = %{player_states: %{1 => player_state}, inputs: %{}}
      frame = Frame.new(pre_frame: pre_frame)

      assert Frame.get_pre_player_state(frame, 1) == player_state
    end

    test "returns nil when player state doesn't exist" do
      frame = Frame.new()

      assert Frame.get_pre_player_state(frame, 1) == nil
    end
  end

  describe "get_post_player_state/2" do
    test "returns player state when it exists" do
      player_state = %{position_x: 15.0, position_y: 25.0}

      post_frame = %{
        player_states: %{1 => player_state},
        positions: %{},
        velocities: %{},
        animation_states: %{}
      }

      frame = Frame.new(post_frame: post_frame)

      assert Frame.get_post_player_state(frame, 1) == player_state
    end

    test "returns nil when player state doesn't exist" do
      frame = Frame.new()

      assert Frame.get_post_player_state(frame, 1) == nil
    end
  end

  describe "get_player_inputs/2" do
    test "returns input data when it exists" do
      input_data = %{buttons: 1, joystick_x: 0.5, joystick_y: -0.3}
      pre_frame = %{player_states: %{}, inputs: %{1 => input_data}}
      frame = Frame.new(pre_frame: pre_frame)

      assert Frame.get_player_inputs(frame, 1) == input_data
    end

    test "returns nil when input data doesn't exist" do
      frame = Frame.new()

      assert Frame.get_player_inputs(frame, 1) == nil
    end
  end

  describe "active_players/1" do
    test "returns list of active player ports" do
      player_states = %{1 => %{}, 3 => %{}}
      pre_frame = %{player_states: player_states, inputs: %{}}
      frame = Frame.new(pre_frame: pre_frame)

      active_ports = Frame.active_players(frame)
      assert Enum.sort(active_ports) == [1, 3]
    end

    test "returns empty list when no players" do
      frame = Frame.new()

      assert Frame.active_players(frame) == []
    end
  end
end
