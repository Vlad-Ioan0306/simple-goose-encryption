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
goose build src/main.goose
./file-encryptor --encrypt
```

## Usage

```
file-encryptor --encrypt
file-encryptor --decrypt
```

- `--encrypt`: reads a line of text, encrypts it with a randomly generated seed, prints
  base64 ciphertext (no `=` padding), and saves the seed to `.seed` in the current
  directory.
- `--decrypt`: reads the seed from `.seed`, expects base64 input, prints the plaintext.

The same seed is required on both sides. If you run `--encrypt` again, `.seed` is
overwritten with a new random seed.

## Project Layout

```
src/main.goose   # entry point: CLI, seed handling, encrypt/decrypt pipeline
src/encrypt.goose# XOR stream cipher (key-seeded xorshift keystream)
LICENSE          # MIT
```
