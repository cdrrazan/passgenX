# passgenX 🔐

          .-------------------------------------------------------------------.
          |██████╗  █████╗ ███████╗███████╗ ██████╗ ███████╗███╗   ██╗██╗  ██╗|
          |██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝ ██╔════╝████╗  ██║╚██╗██╔╝|
          |██████╔╝███████║███████╗███████╗██║  ███╗█████╗  ██╔██╗ ██║ ╚███╔╝ |
          |██╔═══╝ ██╔══██║╚════██║╚════██║██║   ██║██╔══╝  ██║╚██╗██║ ██╔██╗ |
          |██║     ██║  ██║███████║███████║╚██████╔╝███████╗██║ ╚████║██╔╝ ██╗|
          |╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝|
          '-------------------------------------------------------------------'

                    🔐 Deterministic Password Generator for Rubyists

**passgenX** is a secure, deterministic password generator based on a master
password, domain, and secret identifier. It helps you recreate passwords
*without storing them remotely*—great for disaster recovery or reducing
dependency on password managers.

- 💡 Deterministic: Same inputs → same password.
- 🧠 Remember just one master password.
- 🧱 Optional local vault for managing secret identifiers.
- 🔒 Works offline, open source, and CLI-based.

---

## ✨ Features

- Deterministic password generation (SHA256 + character filtering)
- Custom options: length, casing, symbols, digits
- Optional identifier system (for multiple accounts per domain)
- Vault system: `~/.passgenx/vault.yml`
- No external dependencies
- Works anywhere Ruby does

---

## 🔧 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/cdrrazan/passgenX.git
   cd passgenX
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. (Optional) Symlink the executable to your path:
   ```bash
   chmod +x bin/passgenx
   ln -s "$(pwd)/bin/passgenx" /usr/local/bin/passgenx
   ```

---

## 🚀 Usage

### Generate a password interactively

```bash
  bin/passgenx
```

**Prompts:**

- Domain
- Master password (masked)
- Identifier (optional — auto-filled from vault if set)
- Custom options: length, casing, symbols, digits

---

### Setup identifier in vault

```bash
  bin/passgenx setup
```

Stores a securely generated identifier for the given domain in
`~/.passgenx/vault.yml`.

---

### Example

```bash
$ passgenx
Enter domain: github.com
Enter master password: •••••••••••
Enter identifier (optional):
Password length (default 16): 20
Use casing? (lower/upper/both): both
Include symbols? (y/n): y
Include digits? (y/n): y
🔄 Generating password...
✅ Your password: Yc!wKq7#GhU1E@avxz3Z
```

---

## 🗂 Vault System

- Your vault lives at `~/.passgenx/vault.yml`
- Use `passgenx setup` to create entries
- Identifiers are never uploaded or shared
- You can edit this YAML manually or keep it in version control (if encrypted)

---

## Sample Output

```
.-------------------------------------------------------------------.
|██████╗  █████╗ ███████╗███████╗ ██████╗ ███████╗███╗   ██╗██╗  ██╗|
|██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝ ██╔════╝████╗  ██║╚██╗██╔╝|
|██████╔╝███████║███████╗███████╗██║  ███╗█████╗  ██╔██╗ ██║ ╚███╔╝ |
|██╔═══╝ ██╔══██║╚════██║╚════██║██║   ██║██╔══╝  ██║╚██╗██║ ██╔██╗ |
|██║     ██║  ██║███████║███████║╚██████╔╝███████╗██║ ╚████║██╔╝ ██╗|
|╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝|
'-------------------------------------------------------------------'

         🔐 Deterministic Password Generator for Rubyists


🌐  Domain: github.com
🔑  Master password: 
🆔  Identifier (optional, press Enter to use vault/default): 

⚙️  Configuration
📏  Password length (default 16): 20
🔠  Case type? (lower / upper / both) [both]: both
🔣  Include symbols? (y/n) [y]: y
🔢  Include digits? (y/n) [y]: y

🔄 Generating password with length: 20

--------------------------------------------------
✅  Your generated password: xxxxxxxxxxxxxxxxxx
--------------------------------------------------

```

---

## 🧪 Development

Clone and run locally:

```bash
git clone https://github.com/cdrrazan/passgenX.git
cd passgenX
bundle install
bin/passgenx
```

---

## 🛡 License

This project is licensed under the [MIT License](LICENSE.txt).

---

## 📫 Contributing

Bug reports and pull requests are welcome on GitHub
at [cdrrazan/passgenX](https://github.com/cdrrazan/passgenX/issues).
