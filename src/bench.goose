namespace bench;

import encrypt;

const BENCH_SIZE: u64 = 10 * 1024 * 1024;

fn run_benchmark(seed0: const u64, seed1: const u64, nonce: const u64) -> bool {
    var data: u8[>..] = [];
    var i: u64 = 0;
    while i < BENCH_SIZE {
        data.push(((i * 2654435761) >> 24) as u8);
        i = i + 1;
    }

    let enc = encrypt::crypt(data, seed0, seed1, nonce);
    let dec = encrypt::crypt(enc, seed0, seed1, nonce);

    print("Benchmark: encrypted+decrypted ");
    print(u64_to_string(BENCH_SIZE));
    print(" bytes\n");
    return true;
}
