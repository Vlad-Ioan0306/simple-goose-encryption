# File Encryptor (XOR / Stream Cipher)

Educational/demo-grade file encryption written in [Goose](https://github.com/aardappel/goose).
Encrypts and decrypts files using a key-dependent XOR stream cipher, with base64 output
for terminal-safe text. Operates on fixed-size chunks (64 KB) and works on binary files.

## Warning

This is **not** cryptographically secure. Do not use for real secrets or production data.
It exists to demonstrate systems programming in Goose: byte slices, fixed-size chunk
processing, CLI argument parsing, file I/O, and project structure.

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
goose run src/main.goose --encrypt --input plain.txt --output enc.txt

# Optimized binary (system C compiler)
goose build src/main.goose -o file-encryptor
./file-encryptor --encrypt --input plain.txt --output enc.txt
```

## Usage

```
./file-encryptor --encrypt --input FILE --output FILE [--key SEED]
./file-encryptor --decrypt --input FILE --output FILE [--key SEED]
./file-encryptor --benchmark
```

- `--encrypt`: reads `--input` file in 64 KB chunks, generates two random `u64` seeds
  (128-bit seed space) plus a random `u64` nonce, writes the seed pair to `.seed` in the
  current directory, and writes base64 ciphertext to `--output` with the 8-byte nonce
  prepended. Prints the seed pair and nonce to stdout.
- `--decrypt`: reads the seed pair from `.seed` (or provides `--key`), expects base64 input
  with the nonce prepended in `--input`, extracts the nonce, and writes plaintext to
  `--output`.
- `--key SEED`: use a single `u64` seed value for both cipher states instead of generating
  random seeds.
- `--benchmark`: encrypts and decrypts a 10 MB buffer and reports bytes processed.

The same seed pair is required on both sides. If you run `--encrypt` again without `--key`,
`.seed` is overwritten with a new random seed pair. The nonce is not secret — it travels
with the ciphertext — but must be unique per encryption; do not reuse it.

## Project Layout

```
src/main.goose   # entry point: CLI dispatch, seed resolution, mode orchestration
src/cli.goose    # argument parsing: --encrypt/--decrypt/--input/--output/--key/--benchmark
src/io.goose     # file I/O with 64 KB chunking; encrypt_file / decrypt_file
src/encrypt.goose# XOR stream cipher (key-seeded xorshift keystream)
src/seed.goose   # u64/seed parsing utilities
src/bench.goose  # benchmark on 10 MB buffer
LICENSE          # MIT
```
