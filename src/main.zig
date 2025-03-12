const std = @import("std");
pub const windows = std.os.windows;
pub extern "kernel32" fn GetModuleHandleW(lpModuleName: ?[*:0]const u16) callconv(std.builtin.CallingConvention.winapi) ?windows.HINSTANCE;
pub extern "kernel32" fn GetLastError() callconv(std.builtin.CallingConvention.winapi) u32;
pub extern "user32" fn RegisterClassW(lpWndClass: ?*const WNDCLASSW) callconv(std.builtin.CallingConvention.winapi) u16;
pub extern "user32" fn ShowWindow(hWnd: ?windows.HWND, nCmdShow: u32) callconv(std.builtin.CallingConvention.winapi) windows.BOOL;
pub extern "user32" fn DefWindowProcW(hWnd: ?windows.HWND, Msg: u32, wParam: windows.WPARAM, lParam: windows.LPARAM) callconv(@import("std").os.windows.WINAPI) windows.LRESULT;
pub extern "user32" fn CreateWindowExW(
    dwExStyle: u32,
    lpClassName: ?[*:0]align(1) const u16,
    lpWindowName: ?[*:0]const u16,
    dwStyle: u32,
    X: i32,
    Y: i32,
    nWidth: i32,
    nHeight: i32,
    hWndParent: ?windows.HWND,
    hMenu: ?windows.HMENU,
    hInstance: ?windows.HINSTANCE,
    lpParam: ?*anyopaque,
) callconv(std.builtin.CallingConvention.winapi) ?windows.HWND;

pub const WNDCLASSW = extern struct {
    style: u32,
    lpfnWndProc: ?WNDPROC,
    cbClsExtra: i32,
    cbWndExtra: i32,
    hInstance: ?windows.HINSTANCE,
    hIcon: ?windows.HICON,
    hCursor: ?windows.HCURSOR,
    hbrBackground: ?windows.HBRUSH,
    lpszMenuName: ?[*:0]const u16,
    lpszClassName: ?[*:0]const u16,
};

pub const WNDPROC = switch (@import("builtin").zig_backend) {
    .stage1 => fn (
        param0: windows.HWND,
        param1: u32,
        param2: windows.WPARAM,
        param3: std.io.windows.LPARAM,
    ) callconv(std.builtin.CallingConvention.winapi) std.io.windows.LRESULT,
    else => *const fn (
        param0: windows.HWND,
        param1: u32,
        param2: windows.WPARAM,
        param3: windows.LPARAM,
    ) callconv(std.builtin.CallingConvention.winapi) windows.LRESULT,
};

pub fn main() !void {
    std.debug.print("start\n", .{});

    try initWindow();
    // keep running for 2sec
    var counter: u32 = 0;
    while (counter < 20) {
        counter += 1;
        std.time.sleep(100_000_000);
    }
    std.debug.print("done\n", .{});
}

fn initWindow() !void {
    const hInstance = GetModuleHandleW(null);
    const className = std.unicode.utf8ToUtf16LeStringLiteral("className");
    const title = std.unicode.utf8ToUtf16LeStringLiteral("title");
    {
        const class: WNDCLASSW = .{
            .style = 0,
            .lpfnWndProc = wndProc,
            .cbClsExtra = 0,
            .cbWndExtra = 0,
            .hInstance = hInstance,
            .hIcon = null,
            .hCursor = null,
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = className,
        };
        if (RegisterClassW(&class) == 0) return error.FailedToRegisterClass;
    }
    const hwnd = CreateWindowExW(
        0,
        className,
        title,
        0,
        10,
        10,
        800,
        600,
        null,
        null,
        hInstance,
        null,
    ) orelse {
        std.debug.print("[!] CreateWindowExW Failed With Error : {}\n", .{GetLastError()});
        return error.Unexpected;
    };
    _ = ShowWindow(hwnd, 0b0000000000000000000000000000101);
}

fn wndProc(hwnd: windows.HWND, msg: u32, wParam: windows.WPARAM, lParam: windows.LPARAM) callconv(std.builtin.CallingConvention.winapi) windows.LRESULT {
    std.debug.print("wndProc msg:{}\n", .{msg});
    return DefWindowProcW(hwnd, msg, wParam, lParam);
}
