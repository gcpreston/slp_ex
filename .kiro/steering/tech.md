# Technology Stack

## Language & Runtime
- **Elixir**: ~> 1.15
- **Erlang/OTP**: Standard library applications including `:logger`

## Build System
- **Mix**: Standard Elixir build tool and project manager
- **ExUnit**: Built-in testing framework

## Dependencies
- Currently minimal dependencies (standard library only)
- Future dependencies may include binary parsing utilities

## Common Commands

### Development
```bash
# Install dependencies
mix deps.get

# Compile the project
mix compile

# Run tests
mix test

# Run tests with coverage
mix test --cover

# Format code
mix format

# Check formatting
mix format --check-formatted

# Generate documentation
mix docs

# Start interactive shell
iex -S mix
```

### Code Quality
```bash
# Run static analysis (if Credo is added)
mix credo

# Run type checking (if Dialyzer is added)
mix dialyzer
```

## Code Formatting
- Uses standard Elixir formatter configuration
- Formats files in `{mix,.formatter}.exs`, `{config,lib,test}/**/*.{ex,exs}`
- Run `mix format` before committing changes