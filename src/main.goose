import encrypt;
import os;
import base64;

enum Mode { Encrypt, Decrypt }

fn parse_u16(s: const u8[:]) -> u16, bool {
    if s.len == 0 { return 0, false; }
    var value: u16 = 0;
    for c in s {
        if c < '0' || c > '9' { return 0, false; }
        value = value * 10 + (c - '0');
    }
    return value, true;
}

fn u16_to_string(v: u16) -> u8[>..] {
    if v == 0 {
        var out: u8[>..] = [];
        out.push('0');
        return out;
    }
    var temp: u8[>..] = [];
    var n:    u16     = v;
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

    var seed: u16 = 0;

    match mode {
        Encrypt => {
            seed = encrypt::generate_seed();
            let seed_text = u16_to_string(seed);
            if !write_file(".seed", seed_text) {
                write_stderr("Failed to write seed file\n");
                exit(1);
            }
            print("Generated seed: ");
            print(seed_text);
            print("\n");
        },
        Decrypt => {
            var seed_text: u8[>..] = [];
            if !read_file(".seed", seed_text) {
                write_stderr("No .seed file found. Run --encrypt first to generate a seed.\n");
                exit(1);
            }
            let parsed, ok = parse_u16(seed_text);
            if !ok {
                write_stderr("Invalid seed in .seed file\n");
                exit(1);
            }
            seed = parsed;
        },
    }

    let key = encrypt::generate_key(seed);

    print("Please enter the text: ");
    var line: u8[>..] = [];
    if !read_line(line) {
        print("Failed to read input!");
        exit(1);
    }

    match mode {
        Encrypt => {
            let enc = encrypt::crypt(line, key);
            let enc_text: u8[>..] = [];
            base64::encode(enc_text, enc);
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
            let dec = encrypt::crypt(raw, key);
            write_stdout(dec);
        },
    }
}
