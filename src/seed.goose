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
    var i:   u64     = 0;
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

    var a:       u64  = 0;
    var found_a: bool = false;
    while i < s.len && s[i] >= '0' && s[i] <= '9' {
        a = a * 10 + (s[i] - '0');
        found_a = true;
        i = i + 1;
    }
    if !found_a { return 0, 0, false; }

    while i < s.len && (s[i] < '0' || s[i] > '9') { i = i + 1; }

    var b:       u64  = 0;
    var found_b: bool = false;
    while i < s.len && s[i] >= '0' && s[i] <= '9' {
        b = b * 10 + (s[i] - '0');
        found_b = true;
        i = i + 1;
    }
    if !found_b { return 0, 0, false; }

    return a, b, true;
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
