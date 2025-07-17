defmodule SlpEx.Data.MetadataTest do
  use ExUnit.Case, async: true

  alias SlpEx.Data.Metadata

  doctest SlpEx.Data.Metadata

  describe "new/1" do
    test "creates a new metadata with default values" do
      metadata = Metadata.new()

      assert %Metadata{
               start_at: nil,
               last_frame: nil,
               played_on: nil,
               console_nick: nil,
               duration: nil,
               slippi_version: nil
             } = metadata
    end

    test "creates a new metadata with provided attributes" do
      start_time = ~U[2023-01-01 12:00:00Z]
      attrs = [start_at: start_time, played_on: :dolphin, console_nick: "Test Console"]
      metadata = Metadata.new(attrs)

      assert metadata.start_at == start_time
      assert metadata.played_on == :dolphin
      assert metadata.console_nick == "Test Console"
    end
  end

  describe "validate/1" do
    test "returns ok for valid metadata with all fields nil" do
      metadata = Metadata.new()

      assert {:ok, ^metadata} = Metadata.validate(metadata)
    end

    test "returns error when start_at is not a DateTime" do
      metadata = Metadata.new(start_at: "not_datetime")

      assert {:error, "start_at must be a valid DateTime"} = Metadata.validate(metadata)
    end

    test "returns error when last_frame is not an integer" do
      metadata = Metadata.new(last_frame: "not_integer")

      assert {:error, "last_frame must be an integer"} = Metadata.validate(metadata)
    end

    test "returns error for invalid console type" do
      metadata = Metadata.new(played_on: :invalid_console)

      assert {:error, "Invalid console type"} = Metadata.validate(metadata)
    end

    test "accepts valid console types" do
      for console_type <- [:dolphin, :network, :nintendont] do
        metadata = Metadata.new(played_on: console_type)
        assert {:ok, ^metadata} = Metadata.validate(metadata)
      end
    end

    test "returns error when duration is negative" do
      metadata = Metadata.new(duration: -1)

      assert {:error, "duration must be a non-negative integer"} = Metadata.validate(metadata)
    end

    test "returns error when duration is not an integer" do
      metadata = Metadata.new(duration: "not_integer")

      assert {:error, "duration must be a non-negative integer"} = Metadata.validate(metadata)
    end

    test "returns ok for valid metadata with all valid fields" do
      start_time = ~U[2023-01-01 12:00:00Z]

      metadata =
        Metadata.new(
          start_at: start_time,
          last_frame: 3600,
          played_on: :dolphin,
          console_nick: "Test",
          duration: 60,
          slippi_version: "3.0.0"
        )

      assert {:ok, ^metadata} = Metadata.validate(metadata)
    end

    test "returns error for invalid data structure" do
      assert {:error, "Invalid metadata data structure"} = Metadata.validate(%{})
    end
  end

  describe "duration_seconds/1" do
    test "returns duration when explicitly set" do
      metadata = Metadata.new(duration: 120)

      assert Metadata.duration_seconds(metadata) == 120
    end

    test "calculates duration from last_frame when duration not set" do
      # 60 seconds at 60 FPS
      metadata = Metadata.new(last_frame: 3600)

      assert Metadata.duration_seconds(metadata) == 60.0
    end

    test "returns nil when neither duration nor last_frame is set" do
      metadata = Metadata.new()

      assert Metadata.duration_seconds(metadata) == nil
    end

    test "prefers explicit duration over calculated from frames" do
      metadata = Metadata.new(duration: 120, last_frame: 3600)

      assert Metadata.duration_seconds(metadata) == 120
    end
  end

  describe "dolphin?/1" do
    test "returns true when played on dolphin" do
      metadata = Metadata.new(played_on: :dolphin)

      assert Metadata.dolphin?(metadata) == true
    end

    test "returns false when not played on dolphin" do
      metadata = Metadata.new(played_on: :network)

      assert Metadata.dolphin?(metadata) == false
    end

    test "returns false when played_on is nil" do
      metadata = Metadata.new()

      assert Metadata.dolphin?(metadata) == false
    end
  end

  describe "network?/1" do
    test "returns true when played over network" do
      metadata = Metadata.new(played_on: :network)

      assert Metadata.network?(metadata) == true
    end

    test "returns false when not played over network" do
      metadata = Metadata.new(played_on: :dolphin)

      assert Metadata.network?(metadata) == false
    end

    test "returns false when played_on is nil" do
      metadata = Metadata.new()

      assert Metadata.network?(metadata) == false
    end
  end

  describe "console_name/1" do
    test "returns correct name for dolphin" do
      metadata = Metadata.new(played_on: :dolphin)

      assert Metadata.console_name(metadata) == "Dolphin Emulator"
    end

    test "returns correct name for network" do
      metadata = Metadata.new(played_on: :network)

      assert Metadata.console_name(metadata) == "Network Stream"
    end

    test "returns correct name for nintendont" do
      metadata = Metadata.new(played_on: :nintendont)

      assert Metadata.console_name(metadata) == "Nintendont"
    end

    test "returns correct name when nil" do
      metadata = Metadata.new()

      assert Metadata.console_name(metadata) == "Not specified"
    end
  end
end
