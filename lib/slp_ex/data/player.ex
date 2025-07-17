defmodule SlpEx.Data.Player do
  @moduledoc """
  Represents individual player data including character selection, tags, and controller information.
  """

  @type player_type :: :human | :cpu | :demo
  @type character ::
          :fox
          | :falco
          | :marth
          | :sheik
          | :jigglypuff
          | :peach
          | :ice_climbers
          | :captain_falcon
          | :pikachu
          | :samus
          | :dr_mario
          | :yoshi
          | :luigi
          | :link
          | :young_link
          | :donkey_kong
          | :ganondorf
          | :mewtwo
          | :roy
          | :mr_game_and_watch
          | :bowser
          | :kirby
          | :ness
          | :zelda
          | :pichu

  @type t :: %__MODULE__{
          port: non_neg_integer(),
          character: character() | nil,
          tag: String.t() | nil,
          player_type: player_type(),
          controller_fix: String.t() | nil
        }

  defstruct [
    :port,
    :character,
    :tag,
    :controller_fix,
    player_type: :human
  ]

  @doc """
  Creates a new Player struct with the given attributes.

  ## Examples

      iex> SlpEx.Data.Player.new(port: 1, character: :fox)
      %SlpEx.Data.Player{port: 1, character: :fox, player_type: :human}
      
      iex> SlpEx.Data.Player.new(port: 2, character: :falco, tag: "PPMD", player_type: :human)
      %SlpEx.Data.Player{port: 2, character: :falco, tag: "PPMD", player_type: :human}
  """
  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Validates that a Player struct has the minimum required data.

  Returns `{:ok, player}` if valid, `{:error, reason}` if invalid.
  """
  def validate(%__MODULE__{} = player) do
    cond do
      is_nil(player.port) or player.port < 1 or player.port > 4 ->
        {:error, "Player port must be between 1 and 4"}

      is_nil(player.character) ->
        {:error, "Player character is required"}

      player.player_type not in [:human, :cpu, :demo] ->
        {:error, "Invalid player type"}

      true ->
        {:ok, player}
    end
  end

  def validate(_), do: {:error, "Invalid player data structure"}

  @doc """
  Returns true if the player is controlled by a human.
  """
  def human?(%__MODULE__{player_type: :human}), do: true
  def human?(_), do: false

  @doc """
  Returns true if the player is a CPU.
  """
  def cpu?(%__MODULE__{player_type: :cpu}), do: true
  def cpu?(_), do: false
end
