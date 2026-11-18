import encrypt;
import cli;
import io;
import bench;
import seed;
import os;
import base64;

fn main() {
    let args = args();
    let ok, is_encrypt, input_path, output_path, key_str, benchmark = cli::parse_args(copy(args));
    if !ok {
        write_stderr("Usage: file-encryptor --encrypt|--decrypt [--input FILE] [--output FILE] [--key SEED] [--benchmark]\n");
        exit(1);
    }

    if benchmark {
        let seed0, seed1 = encrypt::generate_seed();
        let nonce = random_seed();
        let ok = bench::run_benchmark(seed0, seed1, nonce);
        if !ok { exit(1); }
        return;
    }

    var seed0: u64 = 0;
    var seed1: u64 = 0;

    if key_str.len > 0 {
        let k, ok = parse_u64(key_str);
        if !ok {
            write_stderr("Invalid --key format. Expected a single u64 seed value.\n");
            exit(1);
        }
        seed0 = k;
        seed1 = k;
    } else if is_encrypt {
        let s0, s1 = encrypt::generate_seed();
        seed0 = s0;
        seed1 = s1;
        var seed_text: u8[>..] = [];
        for c in u64_to_string(seed0) { seed_text.push(c); }
        seed_text.push(' ');
        for c in u64_to_string(seed1) { seed_text.push(c); }
        if !write_file(".seed", seed_text) {
            write_stderr("Failed to write seed file\n");
            exit(1);
        }
    } else {
        var seed_text: u8[>..] = [];
        if !read_file(".seed", seed_text) {
            write_stderr("No .seed file found. Provide --key or run --encrypt first.\n");
            exit(1);
        }
        let s0, s1, ok = parse_seed_pair(seed_text);
        if !ok {
            write_stderr("Invalid seed in .seed file\n");
            exit(1);
        }
        seed0 = s0;
        seed1 = s1;
    }

    if input_path.len == 0 {
        write_stderr("Missing --input\n");
        exit(1);
    }
    if output_path.len == 0 {
        write_stderr("Missing --output\n");
        exit(1);
    }

    if is_encrypt {
        let nonce = random_seed();
        let ok = io::encrypt_file(input_path, output_path, seed0, seed1, nonce);
        if !ok {
            write_stderr("Failed to encrypt file\n");
            exit(1);
        }
        print("Seed: ");
        print(u64_to_string(seed0));
        print(" ");
        print(u64_to_string(seed1));
        print(" Nonce: ");
        print(u64_to_string(nonce));
        print("\n");
    } else {
        let ok = io::decrypt_file(input_path, output_path, seed0, seed1);
        if !ok {
            write_stderr("Failed to decrypt file\n");
            exit(1);
        }
        print("Decrypted successfully\n");
    }
}
