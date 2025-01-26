const std = @import("std");
const assert = std.debug.assert;
const Random = std.Random;

pub fn main() !void {
    const writer = std.io.getStdOut().writer();
    try writer.writeAll("Welcome to ilo pi toki pona!\n");

    var xoshiro: Random.Xoshiro256 = .init(std.crypto.random.int(u64));
    const rng = xoshiro.random();

    var buffer: [32]u8 = undefined;

    loop: while (true) {
        const syllable_count = try inputNum(usize, "How many syllables? : ", &buffer);
        if (syllable_count == 0) {
            try writer.writeAll("The number of syllables needs to be greater than zero.\n");
            continue :loop;
        }

        try writer.writeAll("Your nimisin: \"");
        try nimisin(rng, syllable_count, writer);
        try writer.writeAll("\"\n");
    }
}

fn inputStr(prompt: []const u8, buffer: []u8) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
    try std.io.getStdOut().writeAll(prompt);
    return try stdin.readUntilDelimiter(buffer, '\n');
}

fn inputNum(comptime T: type, prompt: []const u8, buffer: []u8) !T {
    const stdin = std.io.getStdIn().reader();
    while (true) {
        try std.io.getStdOut().writeAll(prompt);
        const inp = try stdin.readUntilDelimiter(buffer, '\n');
        return std.fmt.parseInt(T, inp, 10) catch continue;
    }
}

const vowel_list = "aeiou";
const consonant_list = "jklmnpstw";
const syllable_list = genSyllables();

fn nimisin(rng: Random, syllable_count: usize, writer: anytype) !void {
    if (syllable_count == 0) return;

    const Idx = std.math.IntFittingRange(0, syllable_list.len);

    // The first syllable can omit the consonant
    const first_idx = rng.uintLessThan(Idx, syllable_list.len);
    var last_syllable = syllable_list[first_idx];
    if (rng.boolean()) {
        try writer.writeAll(last_syllable[1..]);
    } else {
        try writer.writeAll(last_syllable);
    }

    for (1..syllable_count) |_| {
        const next_idx = rng.uintLessThan(Idx, syllable_list.len);
        const next_syllable = syllable_list[next_idx];

        // avoid two "n" in a row
        if (next_syllable[0] == last_syllable[last_syllable.len - 1]) {
            assert(last_syllable[last_syllable.len - 1] == 'n');
            assert(next_syllable[0] == 'n');
            try writer.writeAll(next_syllable[1..]);
        } else {
            try writer.writeAll(next_syllable);
        }

        last_syllable = next_syllable;
    }
}

fn genSyllables() []const []const u8 {
    @setEvalBranchQuota(4000);

    var list: []const []const u8 = &.{};

    for (consonant_list) |consonant| {
        for (vowel_list) |vowel| {
            const head: [2]u8 = .{ consonant, vowel };
            if (!disallowed(head)) {
                list = list ++ @as([]const []const u8, &.{&head});
                list = list ++ @as([]const []const u8, &.{&head ++ "n"});
            }
        }
    }

    return list;
}

fn disallowed(syllable_head: [2]u8) bool {
    return std.StaticStringMap(void).initComptime(
        .{ .{"wo"}, .{"wu"}, .{"ji"}, .{"ti"} },
    ).has(&syllable_head);
}
