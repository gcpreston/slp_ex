defmodule SlpEx.Data.Frame do
  @moduledoc """
  Represents frame-by-frame game state data including pre-frame and post-frame information.

  Frame data contains the detailed game state for each frame of the match, including
  player positions, velocities, animation states, and input data.
  """

  @type player_state :: %{
          position_x: float() | nil,
          position_y: float() | nil,
          velocity_x: float() | nil,
          velocity_y: float() | nil,
          animation_state: non_neg_integer() | nil,
          action_state: non_neg_integer() | nil,
          facing_direction: float() | nil,
          percent: float() | nil,
          shield_size: float() | nil,
          last_attack_landed: non_neg_integer() | nil,
          combo_count: non_neg_integer() | nil,
          last_hit_by: non_neg_integer() | nil,
          stocks: non_neg_integer() | nil
        }

  @type input_data :: %{
          buttons: non_neg_integer() | nil,
          joystick_x: float() | nil,
          joystick_y: float() | nil,
          c_stick_x: float() | nil,
          c_stick_y: float() | nil,
          trigger: float() | nil,
          processed_buttons: non_neg_integer() | nil
        }

  @type pre_frame_data :: %{
          player_states: %{non_neg_integer() => player_state()},
          inputs: %{non_neg_integer() => input_data()}
        }

  @type post_frame_data :: %{
          player_states: %{non_neg_integer() => player_state()},
          positions: %{non_neg_integer() => {float(), float()}},
          velocities: %{non_neg_integer() => {float(), float()}},
          animation_states: %{non_neg_integer() => non_neg_integer()}
        }

  @type t :: %__MODULE__{
          index: integer(),
          pre_frame: pre_frame_data(),
          post_frame: post_frame_data(),
          is_rollback: boolean()
        }

  defstruct [
    :index,
    pre_frame: %{player_states: %{}, inputs: %{}},
    post_frame: %{player_states: %{}, positions: %{}, velocities: %{}, animation_states: %{}},
    is_rollback: false
  ]

  @doc """
  Creates a new Frame struct with the given attributes.

  ## Examples

      iex> SlpEx.Data.Frame.new(index: 100)
      %SlpEx.Data.Frame{index: 100, is_rollback: false}
      
      iex> SlpEx.Data.Frame.new(index: 200, is_rollback: true)
      %SlpEx.Data.Frame{index: 200, is_rollback: true}
  """
  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Validates that a Frame struct has the minimum required data.

  Returns `{:ok, frame}` if valid, `{:error, reason}` if invalid.
  """
  def validate(%__MODULE__{} = frame) do
    cond do
      is_nil(frame.index) ->
        {:error, "Frame index is required"}

      not is_integer(frame.index) ->
        {:error, "Frame index must be an integer"}

      not is_boolean(frame.is_rollback) ->
        {:error, "is_rollback must be a boolean"}

      not valid_frame_data?(frame.pre_frame) ->
        {:error, "Invalid pre-frame data structure"}

      not valid_frame_data?(frame.post_frame) ->
        {:error, "Invalid post-frame data structure"}

      true ->
        {:ok, frame}
    end
  end

  def validate(_), do: {:error, "Invalid frame data structure"}

  @doc """
  Returns true if this frame is a rollback frame.
  """
  def rollback?(%__MODULE__{is_rollback: is_rollback}), do: is_rollback

  @doc """
  Gets player state data for a specific player port from pre-frame data.
  """
  def get_pre_player_state(%__MODULE__{pre_frame: %{player_states: states}}, port) do
    Map.get(states, port)
  end

  @doc """
  Gets player state data for a specific player port from post-frame data.
  """
  def get_post_player_state(%__MODULE__{post_frame: %{player_states: states}}, port) do
    Map.get(states, port)
  end

  @doc """
  Gets input data for a specific player port.
  """
  def get_player_inputs(%__MODULE__{pre_frame: %{inputs: inputs}}, port) do
    Map.get(inputs, port)
  end

  @doc """
  Returns all active player ports in this frame.
  """
  def active_players(%__MODULE__{pre_frame: %{player_states: states}}) do
    Map.keys(states)
  end

  # Private helper functions

  defp valid_frame_data?(%{player_states: states}) when is_map(states), do: true
  defp valid_frame_data?(_), do: false
end
