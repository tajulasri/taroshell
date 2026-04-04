# Taro Shell

A desktop SSH console application built with Flutter. Manage SSH connections, terminal sessions, SFTP file transfers, and SSH keys from a single interface.

## Features

- **Multi-tab terminal** — Open multiple SSH sessions simultaneously with tab-based navigation and drag-to-reorder.
- **Server management** — Save server profiles with host, port, username, and auth method. Organize servers into named, color-coded collections.
- **SSH key management** — Generate Ed25519/RSA key pairs, import existing keys, and manage passphrases. Private keys are stored with AES-256 encryption.
- **SFTP file browser** — Browse remote file systems, upload/download files, and manage directories within each session.
- **Known hosts (TOFU)** — Trust-On-First-Use host key verification with SHA-256 fingerprint display. Warns on host key changes.
- **Connection history** — Tracks recent connections with quick reconnect from the sidebar.
- **Dark and light themes** — Switch between dark, light, or system-matched appearance.
- **Customizable terminal** — Adjust font size, scrollback buffer, cursor style, and connection timeout.

## Requirements

- Flutter SDK `^3.11.0`
- macOS 10.15+ (primary target), Linux and Windows support included
- No additional services required — all data stored locally via SQLite

## Getting Started

```bash
# Clone the repository
git clone https://github.com/tajulasri/taroshell.git
cd taroshell

# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d macos
```

## Project Structure

```
lib/
  core/
    constants/       # App-wide constants (ports, timeouts, dimensions)
    database/        # Drift ORM schema and generated code
    router/          # GoRouter navigation configuration
    shortcuts/       # Keyboard shortcut bindings
    theme/           # Material Design 3 theming and terminal colors
    utils/           # Crypto, SSH key parsing, logging utilities
  features/
    connections/     # Server profiles, collections, connection history
    keys/            # SSH key generation, import, storage
    known_hosts/     # Host key fingerprint persistence
    terminal/        # SSH sessions, terminal emulator, tab management
    sftp/            # Remote file browsing and transfers
    settings/        # App preferences (theme, font, terminal config)
  shared/
    widgets/         # App scaffold, sidebar, search field
```

Each feature follows a layered architecture: `domain/` (entities, repository interfaces) → `data/` (DAOs, repository implementations) → `presentation/` (providers, screens, widgets).

## Tech Stack

| Layer              | Library                          |
|--------------------|----------------------------------|
| Framework          | Flutter (desktop)                |
| SSH client         | dartssh2                         |
| Terminal emulator  | xterm                            |
| State management   | Riverpod                         |
| Database           | Drift (SQLite)                   |
| Routing            | GoRouter                         |
| Window management  | window_manager                   |
| Secure storage     | flutter_secure_storage           |
| Cryptography       | pointycastle, pinenacl, asn1lib  |
| Font               | JetBrains Mono                   |

## Security

- SSH private keys are encrypted at rest using AES-256 before storage in the local database.
- The encryption key is managed via OS keychain and a local file with restrictive permissions (`chmod 600`).
- No credentials are stored in plaintext. Passwords and passphrases are prompted at connection time and never persisted.
- Host key verification follows the TOFU model with explicit user confirmation for new or changed host keys.

## License

Copyright 2026 espressobyte. All rights reserved.

## Author

espressobyte@gmail.com
