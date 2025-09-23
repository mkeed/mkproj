//5.1.3  Lists
pub fn list(comptime T: type) type {
    return struct {
        items: []T,
    };
}

//5.2.4
pub const name = struct { bytes: list(u8) };

//5.3 Types
//5.3.1 Number Types

pub const numtypes = enum(u8) {
    f64 = 0x7C,
    f34 = 0x7D,
    i64 = 0x7E,
    i32 = 0x7F,
};

//5.3.2 Vector Types
pub const vectype = enum(u8) {
    v128 = 0x7B,
};

//5.3.3 Heap Types
pub const absheaptype = enum(u8) {
    exn = 0x69,
    array = 0x6A,
    @"struct" = 0x6B,
    i32 = 0x6c,
    eq = 0x6d,
    any = 0x6e,
    @"extern" = 0x6f,
    func = 0x70,
    none = 0x71,
    noextern = 0x72,
    nofunc = 0x73,
    noexn = 0x74,
};

pub const s33 = u32; //I think so? TODO

pub const heaptype = union(enum) {
    ht: absheaptype,
    x: s33,
};

//5.3.4 Reference Types

pub const reftype = enum(u8) {
    ref_null = 0x63,
    ref = 0x64,
    //ht else//TODO
};

//5.3.5 Value Types
