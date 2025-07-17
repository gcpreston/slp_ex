defmodule SlpEx.Data.Game do
  @moduledoc """
  Represents a complete parsed Slippi replay game with all associated data.

  This is the top-level data structure returned by the parser, containing
  metadata, settings, frame data, computed statistics, and any parsing errors.
  """

  alias SlpEx.Data.{Metadata, Settings, Frame, Statistics}

  @type t :: %__MODULE__{
          metadata: Metadata.t() | nil,
          settings: Settings.t() | nil,
          frames: [Frame.t()],
          statistics: Statistics.t() | nil,
          version: String.t() | nil,
          parsing_errors: [String.t()]
        }

  defstruct [
    :metadata,
    :settings,
    :statistics,
    :version,
    frames: [],
    parsing_errors: []
  ]

  @doc """
  Creates a new Game struct with optional initial data.

  ## Examples

      iex> SlpEx.Data.Game.new()
      %SlpEx.Data.Game{frames: [], parsing_errors: []}
      
      iex> SlpEx.Data.Game.new(version: "3.0.0")
      %SlpEx.Data.Game{version: "3.0.0", frames: [], parsing_errors: []}
  """
  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Validates that a Game struct has the minimum required data.

  Returns `{:ok, game}` if valid, `{:error, reason}` if invalid.
  """
  def validate(%__MODULE__{} = game) do
    cond do
      is_nil(game.version) ->
        {:error, "Game version is required"}

      is_nil(game.settings) ->
        {:error, "Game settings are required"}

      true ->
        {:ok, game}
    end
  end

  def validate(_), do: {:error, "Invalid game data structure"}

  @doc """
  Adds a parsing error to the game's error list.
  """
  def add_error(%__MODULE__{parsing_errors: errors} = game, error) when is_binary(error) do
    %{game | parsing_errors: [error | errors]}
  end

  @doc """
  Returns true if the game has any parsing errors.
  """
  def has_errors?(%__MODULE__{parsing_errors: errors}), do: length(errors) > 0
end
