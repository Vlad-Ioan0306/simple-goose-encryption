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

fn parse_mode(args: u8[:][>..]) -> Mode, bool {
    if args.len < 2 { return Mode.Encrypt, false; }

    let a = args[1];
    if a == "--encrypt" { return Mode.Encrypt, true; }
    if a == "--decrypt" { return Mode.Decrypt, true; }
    return Mode.Encrypt, false;
}

fn main() {
    let args = args();
    let mode, ok = parse_mode(copy(args));
    if !ok {
        write_stderr("Usage: file-encryptor --encrypt|--decrypt [-seed <seed>]\n");
        exit(1);
    }

    var seed:     u16  = 0;
    var seed_set: bool = false;
    var i:        i64  = 2;
    while i < args.len {
        if args[i] == "--seed" {
            if i + 1 >= args.len {
                write_stderr("Missing seed value\n");
                exit(1);
            }
            let parsed, ok = parse_u16(args[i + 1]);
            if !ok {
                write_stderr("Invalid seed\n");
                exit(1);
            }
            seed = parsed;
            seed_set = true;
            i = i + 2;
        } else {
            write_stderr("Unknown argument\n");
            exit(1);
        }
    }

    if !seed_set {
        seed = encrypt::generate_seed();
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
            write_stdout(enc_text);
        },
        Decrypt => {
            var raw: u8[>..] = [];
            if !base64::decode(raw, line) {
                write_stderr("Invalid base64 input\n");
                exit(1);
            }
            let dec = encrypt::crypt(raw, key);
            write_stdout(dec);
        },
    }
}
