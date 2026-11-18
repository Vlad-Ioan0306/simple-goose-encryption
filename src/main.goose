import encrypt;
import seed;
import os;
import std;
import base64;

enum Mode { Encrypt, Decrypt }

fn parse_mode(args: u8[:][>..]) -> Mode, bool {
    if args.len < 2 { return Mode.Encrypt, false; }

    let a = args[1];
    if a == "--encrypt" { return Mode.Encrypt, true; }
    if a == "--decrypt" { return Mode.Decrypt, true; }
    return Mode.Encrypt, false;
}

fn strip_padding(s: const u8[:]) -> u8[>..] {
    var out: u8[>..] = [];
    for c in s {
        if c != '=' { out.push(c); }
    }
    return out;
}

fn add_padding(s: const u8[:]) -> u8[>..] {
    var out: u8[>..] = [];
    for c in s { out.push(c); }
    while out.len % 4 != 0 {
        out.push('=');
    }
    return out;
}

fn main() {
    let args = args();
    let mode, ok = parse_mode(copy(args));
    if !ok {
        write_stderr("Usage: file-encryptor --encrypt|--decrypt\n");
        exit(1);
    }

    var seed0: u64 = 0;
    var seed1: u64 = 0;
    var nonce: u64 = 0;

    match mode {
        Encrypt => {
            let s0, s1 = encrypt::generate_seed();
            seed0 = s0;
            seed1 = s1;
            nonce = random_seed();
            var seed_text: u8[>..] = [];
            for c in u64_to_string(seed0) { seed_text.push(c); }
            seed_text.push(' ');
            for c in u64_to_string(seed1) { seed_text.push(c); }
            if !write_file(".seed", seed_text) {
                write_stderr("Failed to write seed file\n");
                exit(1);
            }
            print("Generated seed: ");
            print(u64_to_string(seed0));
            print(" ");
            print(u64_to_string(seed1));
            print(" nonce: ");
            print(u64_to_string(nonce));
            print("\n");
        },
        Decrypt => {
            var seed_text: u8[>..] = [];
            if !read_file(".seed", seed_text) {
                write_stderr("No .seed file found. Run --encrypt first to generate a seed.\n");
                exit(1);
            }
            let s0, s1, ok = parse_seed_pair(seed_text);
            if !ok {
                write_stderr("Invalid seed in .seed file\n");
                exit(1);
            }
            seed0 = s0;
            seed1 = s1;
        },
    }

    print("Please enter the text: ");
    var line: u8[>..] = [];
    if !read_line(line) {
        print("Failed to read input!");
        exit(1);
    }

    match mode {
        Encrypt => {
            let enc = encrypt::crypt(line, seed0, seed1, nonce);
            let nonce_bytes = u64_to_bytes(nonce);
            var combined: u8[>..] = [];
            for c in nonce_bytes { combined.push(c); }
            for c in enc { combined.push(c); }
            let enc_text: u8[>..] = [];
            base64::encode(enc_text, combined);
            let clean = strip_padding(enc_text);
            write_stdout(clean);
        },
        Decrypt => {
            let padded = add_padding(line);
            var raw: u8[>..] = [];
            if !base64::decode(raw, padded) {
                write_stderr("Invalid base64 input\n");
                exit(1);
            }
            if raw.len < 8 {
                write_stderr("Ciphertext too short for nonce\n");
                exit(1);
            }
            var nonce_bytes: u8[>..] = [];
            var ct_bytes:    u8[>..] = [];
            var i:           u64     = 0;
            while i < 8 { nonce_bytes.push(raw[i]); i = i + 1; }
            while i < raw.len { ct_bytes.push(raw[i]); i = i + 1; }
            let nonce = bytes_to_u64(nonce_bytes);

            let dec = encrypt::crypt(ct_bytes, seed0, seed1, nonce);
            write_stdout(dec);
        },
    }
}
