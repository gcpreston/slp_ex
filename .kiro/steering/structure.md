# Project Structure

## Directory Layout

```
slp_ex/
├── lib/                    # Source code
│   └── slp_ex.ex          # Main module
├── test/                   # Test files
│   ├── slp_ex_test.exs    # Main module tests
│   └── test_helper.exs    # Test configuration
├── .kiro/                  # Kiro IDE configuration
│   ├── specs/             # Feature specifications
│   └── steering/          # AI assistant guidelines
├── .elixir-tools/         # Language server files
├── mix.exs                # Project configuration
├── .formatter.exs         # Code formatting rules
├── .gitignore            # Git ignore patterns
└── README.md             # Project documentation
```

## Module Organization

### Current Structure
- `SlpEx` - Main module (placeholder implementation)

### Planned Architecture (based on specs)
- `SlpEx` - Public API and main entry point
- `SlpEx.Parser` - Core binary parsing logic
- `SlpEx.Data` - Data structures and schemas
- `SlpEx.Stats` - Statistics computation
- `SlpEx.Utils` - Utility functions

## Naming Conventions

- **Modules**: PascalCase (e.g., `SlpEx.Parser.FrameData`)
- **Functions**: snake_case (e.g., `parse_replay_file/1`)
- **Variables**: snake_case (e.g., `frame_data`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `@default_timeout`)
- **Files**: snake_case matching module names (e.g., `frame_data.ex`)

## Test Organization

- Test files mirror the `lib/` structure in `test/`
- Test modules end with `Test` (e.g., `SlpExTest`)
- Use `doctest` for testing documentation examples
- Group related tests using `describe` blocks
- Use descriptive test names that explain the behavior being tested