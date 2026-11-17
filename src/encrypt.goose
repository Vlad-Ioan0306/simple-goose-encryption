namespace encrypt;

import os;
import std;

fn generate_seed() -> u16 {
    let seed: u16 = random_seed() as u16;
    return seed;
}

fn generate_key(seed: const u16) -> u64 {
    let r = rng { s: seed };
    let key: u64 = rand_u64(r);
    return key;
}

fn crypt(data: const u8[:], key: const u64) -> u8[>..] {
    var state: u64     = key;
    var out:   u8[>..] = [];

    for c in data {
        state = state ^ (state << 13);
        state = state ^ (state >> 7);
        state = state ^ (state << 17);
        let ks: const u8 = state as u8;
        out.push(c ^ ks);
    }

    return out;
}
