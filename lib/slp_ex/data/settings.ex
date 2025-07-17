defmodule SlpEx.Data.Settings do
  @moduledoc """
  Represents game configuration and settings including players, stage, and game rules.
  """

  alias SlpEx.Data.Player

  @type stage ::
          :battlefield
          | :final_destination
          | :dreamland
          | :pokemon_stadium
          | :yoshis_story
          | :fountain_of_dreams
          | :frozen_pokemon_stadium

  @type t :: %__MODULE__{
          version: String.t() | nil,
          players: [Player.t()],
          is_teams: boolean(),
          item_spawn_behavior: non_neg_integer(),
          self_destruct_score_value: integer(),
          stage_id: non_neg_integer() | nil,
          stage: stage() | nil,
          game_timer: non_neg_integer()
        }

  defstruct [
    :version,
    :stage_id,
    :stage,
    players: [],
    is_teams: false,
    item_spawn_behavior: 0,
    self_destruct_score_value: -1,
    game_timer: 480
  ]

  @doc """
  Creates a new Settings struct with the given attributes.

  ## Examples

      iex> SlpEx.Data.Settings.new()
      %SlpEx.Data.Settings{players: [], is_teams: false, item_spawn_behavior: 0, self_destruct_score_value: -1, game_timer: 480}
      
      iex> player = SlpEx.Data.Player.new(port: 1, character: :fox)
      iex> SlpEx.Data.Settings.new(players: [player], stage: :battlefield)
      %SlpEx.Data.Settings{players: [%SlpEx.Data.Player{port: 1, character: :fox, player_type: :human}], stage: :battlefield, is_teams: false, item_spawn_behavior: 0, self_destruct_score_value: -1, game_timer: 480}
  """
  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Validates that a Settings struct has the minimum required data.

  Returns `{:ok, settings}` if valid, `{:error, reason}` if invalid.
  """
  def validate(%__MODULE__{} = settings) do
    cond do
      length(settings.players) == 0 ->
        {:error, "At least one player is required"}

      length(settings.players) > 4 ->
        {:error, "Maximum of 4 players allowed"}

      not valid_players?(settings.players) ->
        {:error, "All players must be valid"}

      true ->
        {:ok, settings}
    end
  end

  def validate(_), do: {:error, "Invalid settings data structure"}

  @doc """
  Returns the number of active players in the game.
  """
  def player_count(%__MODULE__{players: players}), do: length(players)

  @doc """
  Returns true if the game is a teams match.
  """
  def teams?(%__MODULE__{is_teams: is_teams}), do: is_teams

  @doc """
  Gets a player by their port number.
  """
  def get_player(%__MODULE__{players: players}, port) do
    Enum.find(players, &(&1.port == port))
  end

  # Private helper functions

  defp valid_players?(players) do
    Enum.all?(players, fn player ->
      case Player.validate(player) do
        {:ok, _} -> true
        {:error, _} -> false
      end
    end)
  end
end
