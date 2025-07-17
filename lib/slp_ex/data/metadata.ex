defmodule SlpEx.Data.Metadata do
  @moduledoc """
  Represents game metadata including recording information and match details.

  Metadata contains information about when and how the game was recorded,
  including timestamps, console information, and match duration.
  """

  @type console_type :: :dolphin | :network | :nintendont

  @type t :: %__MODULE__{
          start_at: DateTime.t() | nil,
          last_frame: integer() | nil,
          played_on: console_type() | nil,
          console_nick: String.t() | nil,
          duration: non_neg_integer() | nil,
          slippi_version: String.t() | nil
        }

  defstruct [
    :start_at,
    :last_frame,
    :played_on,
    :console_nick,
    :duration,
    :slippi_version
  ]

  @doc """
  Creates a new Metadata struct with the given attributes.

  ## Examples

      iex> SlpEx.Data.Metadata.new()
      %SlpEx.Data.Metadata{}
      
      iex> start_time = ~U[2023-01-01 12:00:00Z]
      iex> SlpEx.Data.Metadata.new(start_at: start_time, played_on: :dolphin)
      %SlpEx.Data.Metadata{start_at: ~U[2023-01-01 12:00:00Z], played_on: :dolphin}
  """
  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  @doc """
  Validates that a Metadata struct has valid data.

  Returns `{:ok, metadata}` if valid, `{:error, reason}` if invalid.
  """
  def validate(%__MODULE__{} = metadata) do
    cond do
      not is_nil(metadata.start_at) and not valid_datetime?(metadata.start_at) ->
        {:error, "start_at must be a valid DateTime"}

      not is_nil(metadata.last_frame) and not is_integer(metadata.last_frame) ->
        {:error, "last_frame must be an integer"}

      not is_nil(metadata.played_on) and
          metadata.played_on not in [:dolphin, :network, :nintendont] ->
        {:error, "Invalid console type"}

      not is_nil(metadata.duration) and
          (not is_integer(metadata.duration) or metadata.duration < 0) ->
        {:error, "duration must be a non-negative integer"}

      true ->
        {:ok, metadata}
    end
  end

  def validate(_), do: {:error, "Invalid metadata data structure"}

  @doc """
  Returns the match duration in seconds, calculated from frame data if not explicitly set.
  """
  def duration_seconds(%__MODULE__{duration: duration}) when is_integer(duration) do
    duration
  end

  def duration_seconds(%__MODULE__{last_frame: last_frame}) when is_integer(last_frame) do
    # Melee runs at 60 FPS, so convert frames to seconds
    Float.round(last_frame / 60.0, 2)
  end

  def duration_seconds(_), do: nil

  @doc """
  Returns true if the game was played on Dolphin emulator.
  """
  def dolphin?(%__MODULE__{played_on: :dolphin}), do: true
  def dolphin?(_), do: false

  @doc """
  Returns true if the game was played over network.
  """
  def network?(%__MODULE__{played_on: :network}), do: true
  def network?(_), do: false

  @doc """
  Returns a human-readable string representation of the console type.
  """
  def console_name(%__MODULE__{played_on: console_type}) do
    case console_type do
      :dolphin -> "Dolphin Emulator"
      :network -> "Network Stream"
      :nintendont -> "Nintendont"
      nil -> "Not specified"
    end
  end

  # Private helper functions

  defp valid_datetime?(%DateTime{}), do: true
  defp valid_datetime?(_), do: false
end
