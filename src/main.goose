import encrypt;
import os;
import std;
import base64;

enum Mode { Encrypt, Decrypt }

fn parse_u64(s: const u8[:]) -> u64, bool {
    if s.len == 0 { return 0, false; }
    var value: u64 = 0;
    for c in s {
        if c < '0' || c > '9' { return 0, false; }
        value = value * 10 + (c - '0');
    }
    return value, true;
}

fn u64_to_string(v: u64) -> u8[>..] {
    if v == 0 {
        var out: u8[>..] = [];
        out.push('0');
        return out;
    }
    var temp: u8[>..] = [];
    var n:    u64     = v;
    while n > 0 {
        temp.push((('0') + (n % 10)) as u8);
        n = n / 10;
    }
    var out: u8[>..] = [];
    for i in 0..temp.len {
        out.push(temp[temp.len - 1 - i]);
    }
    return out;
}

fn u64_to_bytes(v: u64) -> u8[>..] {
    var out: u8[>..] = [];
    var i: u64 = 0;
    while i < 8 {
        out.push((v >> (i * 8)) as u8);
        i = i + 1;
    }
    return out;
}

fn bytes_to_u64(b: const u8[:]) -> u64 {
    var v: u64 = 0;
    var i: u64 = 0;
    while i < 8 {
        v = v | ((b[i] as u64) << (i * 8));
        i = i + 1;
    }
    return v;
}

fn parse_seed_pair(s: const u8[:]) -> u64, u64, bool {
    var i: u64 = 0;

    while i < s.len && (s[i] < '0' || s[i] > '9') { i = i + 1; }

    var a: u64 = 0;
    var found_a: bool = false;
    while i < s.len && s[i] >= '0' && s[i] <= '9' {
        a = a * 10 + (s[i] - '0');
        found_a = true;
        i = i + 1;
    }
    if !found_a { return 0, 0, false; }

    while i < s.len && (s[i] < '0' || s[i] > '9') { i = i + 1; }

    var b: u64 = 0;
    var found_b: bool = false;
    while i < s.len && s[i] >= '0' && s[i] <= '9' {
        b = b * 10 + (s[i] - '0');
        found_b = true;
        i = i + 1;
    }
    if !found_b { return 0, 0, false; }

    return a, b, true;
}

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
            var ct_bytes: u8[>..] = [];
            var i: u64 = 0;
            while i < 8 { nonce_bytes.push(raw[i]); i = i + 1; }
            while i < raw.len { ct_bytes.push(raw[i]); i = i + 1; }
            let nonce = bytes_to_u64(nonce_bytes);

            let dec = encrypt::crypt(ct_bytes, seed0, seed1, nonce);
            write_stdout(dec);
        },
    }
}
