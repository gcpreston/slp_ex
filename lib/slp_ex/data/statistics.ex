defmodule SlpEx.Data.Statistics do
  @moduledoc """
  Represents computed statistics and derived data from a parsed Slippi replay.

  Statistics include match-level metrics like duration and total frames, as well as
  player-specific metrics like stocks remaining, damage dealt/taken, and action counts.
  """

  @type game_event :: %{
          type: atom(),
          frame: integer(),
          player: non_neg_integer() | nil,
          data: map()
        }

  @type player_stats :: %{
          stocks_remaining: non_neg_integer() | nil,
          damage_dealt: float() | nil,
          damage_taken: float() | nil,
          kill_count: non_neg_integer() | nil,
          death_count: non_neg_integer() | nil,
          action_count: non_neg_integer() | nil,
          l_cancel_success: non_neg_integer() | nil,
          l_cancel_fail: non_neg_integer() | nil,
          air_dodge_count: non_neg_integer() | nil,
          wavedash_count: non_neg_integer() | nil,
          waveland_count: non_neg_integer() | nil,
          dash_dance_count: non_neg_integer() | nil,
          ledge_grab_count: non_neg_integer() | nil,
          opening_count: non_neg_integer() | nil,
          neutral_win_count: non_neg_integer() | nil,
          counter_hit_count: non_neg_integer() | nil,
          beneficial_trade_count: non_neg_integer() | nil
        }

  @type t :: %__MODULE__{
          match_duration: float() | nil,
          total_frames: integer() | nil,
          player_stats: %{non_neg_integer() => player_stats()},
          game_events: [game_event()],
          winner: non_neg_integer() | nil,
          game_end_method: atom() | nil
        }

  defstruct [
    :match_duration,
    :total_frames,
    :winner,
    :game_end_method,
    player_stats: %{},
    game_events: []
  ]

  @doc """
  Creates a new Statistics struct with the given attributes.

  ## Examples

      iex> SlpEx.Data.Statistics.new()
      %SlpEx.Data.Statistics{player_stats: %{}, game_events: []}
      
      iex> SlpEx.Data.Statistics.new(total_frames: 3600, match_duration: 60.0)
      %SlpEx.Data.Statistics{total_frames: 3600, match_duration: 60.0, player_stats: %{}, game_events: []}
  """
  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Validates that a Statistics struct has valid data.

  Returns `{:ok, statistics}` if valid, `{:error, reason}` if invalid.
  """
  def validate(%__MODULE__{} = stats) do
    cond do
      not is_nil(stats.match_duration) and
          (not is_number(stats.match_duration) or stats.match_duration < 0) ->
        {:error, "match_duration must be a non-negative number"}

      not is_nil(stats.total_frames) and
          (not is_integer(stats.total_frames) or stats.total_frames < 0) ->
        {:error, "total_frames must be a non-negative integer"}

      not is_map(stats.player_stats) ->
        {:error, "player_stats must be a map"}

      not is_list(stats.game_events) ->
        {:error, "game_events must be a list"}

      not valid_player_stats?(stats.player_stats) ->
        {:error, "Invalid player statistics data"}

      not valid_game_events?(stats.game_events) ->
        {:error, "Invalid game events data"}

      true ->
        {:ok, stats}
    end
  end

  def validate(_), do: {:error, "Invalid statistics data structure"}

  @doc """
  Gets statistics for a specific player.
  """
  def get_player_stats(%__MODULE__{player_stats: stats}, player_port) do
    Map.get(stats, player_port)
  end

  @doc """
  Sets statistics for a specific player.
  """
  def put_player_stats(%__MODULE__{player_stats: stats} = statistics, player_port, player_stats) do
    %{statistics | player_stats: Map.put(stats, player_port, player_stats)}
  end

  @doc """
  Adds a game event to the statistics.
  """
  def add_event(%__MODULE__{game_events: events} = stats, event) when is_map(event) do
    %{stats | game_events: [event | events]}
  end

  @doc """
  Returns all events of a specific type.
  """
  def get_events_by_type(%__MODULE__{game_events: events}, event_type) do
    Enum.filter(events, &(&1.type == event_type))
  end

  @doc """
  Returns all events for a specific player.
  """
  def get_events_by_player(%__MODULE__{game_events: events}, player_port) do
    Enum.filter(events, &(&1.player == player_port))
  end

  @doc """
  Returns the total number of kills across all players.
  """
  def total_kills(%__MODULE__{player_stats: stats}) do
    stats
    |> Map.values()
    |> Enum.map(&(&1[:kill_count] || 0))
    |> Enum.sum()
  end

  @doc """
  Returns the total damage dealt across all players.
  """
  def total_damage_dealt(%__MODULE__{player_stats: stats}) do
    stats
    |> Map.values()
    |> Enum.map(&(&1[:damage_dealt] || 0.0))
    |> Enum.sum()
  end

  @doc """
  Returns true if the match has a winner determined.
  """
  def has_winner?(%__MODULE__{winner: winner}), do: not is_nil(winner)

  @doc """
  Returns the match duration in seconds, calculated from frames if not explicitly set.
  """
  def duration_seconds(%__MODULE__{match_duration: duration}) when is_number(duration) do
    duration
  end

  def duration_seconds(%__MODULE__{total_frames: frames}) when is_integer(frames) do
    Float.round(frames / 60.0, 2)
  end

  def duration_seconds(_), do: nil

  @doc """
  Creates an empty player stats structure.
  """
  def empty_player_stats do
    %{
      stocks_remaining: nil,
      damage_dealt: nil,
      damage_taken: nil,
      kill_count: 0,
      death_count: 0,
      action_count: 0,
      l_cancel_success: 0,
      l_cancel_fail: 0,
      air_dodge_count: 0,
      wavedash_count: 0,
      waveland_count: 0,
      dash_dance_count: 0,
      ledge_grab_count: 0,
      opening_count: 0,
      neutral_win_count: 0,
      counter_hit_count: 0,
      beneficial_trade_count: 0
    }
  end

  # Private helper functions

  defp valid_player_stats?(stats) when is_map(stats) do
    Enum.all?(stats, fn {port, player_stats} ->
      is_integer(port) and port >= 1 and port <= 4 and is_map(player_stats)
    end)
  end

  defp valid_player_stats?(_), do: false

  defp valid_game_events?(events) when is_list(events) do
    Enum.all?(events, fn event ->
      is_map(event) and
        Map.has_key?(event, :type) and
        Map.has_key?(event, :frame) and
        is_atom(event.type) and
        is_integer(event.frame)
    end)
  end

  defp valid_game_events?(_), do: false
end
