import encrypt;
import os;

enum Mode { Encrypt, Decrypt }

fn parse_mode(args: u8[:][>..]) -> Mode, bool {
    if args.len < 2 { return Mode.Encrypt, false; }

    let a = args[1];
    // compare bytes — you need an equality check on u8[:]
    if a == "--encrypt" { return Mode.Encrypt, true; }
    if a == "--decrypt" { return Mode.Decrypt, true; }
    return Mode.Encrypt, false;
}

fn main() {
    let args = args();
    let mode, ok = parse_mode(copy(args));
    if !ok {
        write_stderr("Usage: file-encryptor --encrypt|--decrypt\n");
        exit(1);
    }

    print("Please enter the text: ");
    var line: u8[>..] = [];
    if !read_line(line) {
        print("Failed to read input!");
        exit(1);
    }

    let seed: const u16 = encrypt::generate_seed();
    let key:  const u64 = encrypt::generate_key(seed);

    match mode {
        Encrypt => {
            let enc = encrypt::crypt(line, key);
            write_stdout(enc);
        },
        Decrypt => {
            let dec = encrypt::crypt(line, key);
            write_stdout(dec);
        },
    }
}
