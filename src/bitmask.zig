const std = @import("std");

pub fn Bitmask(comptime size: u16) type {
    return packed struct {
        bits: std.meta.Int(.unsigned, size),
    };
}

test "packed bitmask size" {
    const mask_type = Bitmask(1024);
    try std.testing.expectEqual(1024, @bitSizeOf(mask_type));
}
