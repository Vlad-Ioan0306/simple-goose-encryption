namespace encrypt;

import os;
import std;

fn generate_seed() -> u64, u64 {
    let seed0: u64 = random_seed();
    let seed1: u64 = random_seed();
    return seed0, seed1;
}

fn crypt(data: const u8[:], seed0: const u64, seed1: const u64, nonce: const u64) -> u8[>..] {
    var state0: u64 = seed0 ^ nonce;
    var state1: u64 = seed1 ^ nonce;
    var out:   u8[>..] = [];

    if state0 == 0 { state0 = 1; }
    if state1 == 0 { state1 = 1; }

    state1 = state1 ^ (state1 << 13);
    state1 = state1 ^ (state1 >> 7);
    state1 = state1 ^ (state1 << 17);

    for c in data {
        state0 = state0 ^ (state0 << 13);
        state0 = state0 ^ (state0 >> 7);
        state0 = state0 ^ (state0 << 17);

        state1 = state1 ^ (state1 << 13);
        state1 = state1 ^ (state1 >> 7);
        state1 = state1 ^ (state1 << 17);

        let ks: const u8 = (state0 ^ state1) as u8;
        out.push(c ^ ks);
    }

    return out;
}
