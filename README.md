# File Encryptor (XOR / Stream Cipher)

Educational/demo-grade file encryption written in [Goose](https://github.com/aardappel/goose).
Encrypts and decrypts input using a key-dependent XOR stream cipher, with base64 output
for terminal-safe text.

## Warning

This is **not** cryptographically secure. Do not use for real secrets or production data.
It exists to demonstrate systems programming in Goose: byte slices, fixed-size chunk
processing, CLI argument parsing, file I/O, and C-style `extern fn` interop (roadmap step 3).

## Build & Run

### Install Goose

Get a prebuilt compiler from the [releases page](https://github.com/aardappel/goose/releases)
(Windows, Linux, macOS), unpack it anywhere, and put its directory on `PATH`.

Or build from source:

```bash
git clone https://github.com/aardappel/goose
cd goose
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGOOSE_BUILTIN_LIBS=all
cmake --build build --config Release
```

The compiler is `build/goose`. On Linux, `goose build` also needs a C compiler
(gcc or clang) and libc headers (`libc6-dev` or `glibc-devel`).

```bash
# Development (fast, TinyCC)
goose run src/main.goose --encrypt

# Optimized binary (system C compiler)
goose build src/main.goose -o file-encryptor
./file-encryptor --encrypt
```

## Usage

```
./file-encryptor --encrypt
./file-encryptor --decrypt
```

- `--encrypt`: reads a line of text, generates two random `u64` seeds (128-bit seed space)
  plus a random `u64` nonce, prints the seed pair and nonce, writes the seed pair to `.seed`
  in the current directory, and prints base64 ciphertext (no `=` padding) with the 8-byte
  nonce prepended.
- `--decrypt`: reads the seed pair from `.seed`, expects base64 input with the nonce
  prepended, extracts the nonce, and prints the plaintext.

The same seed pair is required on both sides. If you run `--encrypt` again, `.seed` is
overwritten with a new random seed pair. The nonce is not secret — it travels with the
ciphertext — but must be unique per encryption; do not reuse it.

## Project Layout

```
src/main.goose   # entry point: CLI, seed/nonce handling, encrypt/decrypt pipeline
src/encrypt.goose# XOR stream cipher (key-seeded xorshift keystream)
LICENSE          # MIT
```
