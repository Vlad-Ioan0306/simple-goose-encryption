namespace cli;

fn parse_args(args: u8[:][>..]) -> bool, bool, u8[>..], u8[>..], u8[>..], bool {
    // returns: ok, is_encrypt, input_path, output_path, key_str, benchmark
    var is_encrypt: bool = false;
    var mode_set: bool = false;
    var input_path: u8[>..] = [];
    var output_path: u8[>..] = [];
    var key_str: u8[>..] = [];
    var benchmark: bool = false;
    var i: u64 = 1;

    while i < args.len {
        if args[i] == "--encrypt" {
            is_encrypt = true;
            mode_set = true;
            i = i + 1;
        }
        else if args[i] == "--decrypt" {
            is_encrypt = false;
            mode_set = true;
            i = i + 1;
        }
        else if args[i] == "--input" {
            i = i + 1;
            if i < args.len {
                input_path = args[i];
                i = i + 1;
            }
        }
        else if args[i] == "--output" {
            i = i + 1;
            if i < args.len {
                output_path = args[i];
                i = i + 1;
            }
        }
        else if args[i] == "--key" {
            i = i + 1;
            if i < args.len {
                key_str = args[i];
                i = i + 1;
            }
        }
        else if args[i] == "--benchmark" {
            benchmark = true;
            i = i + 1;
        }
        else {
            i = i + 1;
        }
    }

    if !mode_set && !benchmark {
        return false, is_encrypt, input_path, output_path, key_str, benchmark;
    }
    return true, is_encrypt, input_path, output_path, key_str, benchmark;
}
