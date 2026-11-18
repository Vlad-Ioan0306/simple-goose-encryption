namespace io;

import os;
import seed;
import encrypt;
import base64;

const CHUNK_SIZE: u64 = 65536;

fn read_all(path: const u8[:]) -> u8[>..], bool {
    var data: u8[>..] = [];
    if !read_file(path, data) { return data, false; }
    return data, true;
}

fn write_all(path: const u8[:], data: const u8[:]) -> bool {
    return write_file(path, data);
}

fn encrypt_file(input_path: const u8[:], output_path: const u8[:], seed0: const u64, seed1: const u64, nonce: const u64) -> bool {
    let data, ok = read_all(input_path);
    if !ok { return false; }

    var out: u8[>..] = [];
    let nonce_bytes = u64_to_bytes(nonce);
    var i: u64 = 0;
    while i < 8 { out.push(nonce_bytes[i]); i = i + 1; }

    var pos: u64 = 0;
    while pos < data.len {
        var chunk_end: u64 = pos + CHUNK_SIZE;
        if chunk_end > data.len as u64 { chunk_end = data.len as u64; }

        var chunk: u8[>..] = [];
        var j: u64 = pos;
        while j < chunk_end { chunk.push(data[j]); j = j + 1; }

        let enc_chunk = encrypt::crypt(chunk, seed0, seed1, nonce);
        var k: u64 = 0;
        while k < enc_chunk.len { out.push(enc_chunk[k]); k = k + 1; }

        pos = chunk_end;
    }

    let enc_text: u8[>..] = [];
    base64::encode(enc_text, out);
    let clean = strip_padding(enc_text);

    return write_all(output_path, clean);
}

fn decrypt_file(input_path: const u8[:], output_path: const u8[:], seed0: const u64, seed1: const u64) -> bool {
    let data, ok = read_all(input_path);
    if !ok { return false; }

    let padded = add_padding(data);
    var raw: u8[>..] = [];
    if !base64::decode(raw, padded) { return false; }

    if raw.len < 8 { return false; }

    var nonce_bytes: u8[>..] = [];
    var ct_bytes: u8[>..] = [];
    var i: u64 = 0;
    while i < 8 { nonce_bytes.push(raw[i]); i = i + 1; }
    while i < raw.len { ct_bytes.push(raw[i]); i = i + 1; }

    let nonce = bytes_to_u64(nonce_bytes);
    let dec = encrypt::crypt(ct_bytes, seed0, seed1, nonce);

    return write_all(output_path, dec);
}
