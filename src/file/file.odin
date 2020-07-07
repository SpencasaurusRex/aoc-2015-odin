package file

import "core:fmt"
import "core:sys/win32"
import w "core:sys/windows"
import "core:strings"

read_all_text :: proc(file_name : string) -> (string, i32)
{
    // Get file handle
    file_handle : win32.Handle;
    {
        path := win32.utf8_to_wstring(file_name);
        access := u32(win32.FILE_GENERIC_READ);
        share := u32(win32.FILE_SHARE_READ);
        security : ^w.SECURITY_ATTRIBUTES = nil;
        creation := u32(win32.OPEN_EXISTING);
        attr := u32(win32.FILE_ATTRIBUTE_NORMAL);
        template : win32.Handle = nil;

        file_handle = win32.create_file_w(path, access, share, security, creation, attr, nil);
        
        if file_handle == win32.INVALID_HANDLE
        {
            return "", win32.get_last_error();
        }

    }
    defer close(file_handle);

    // Get file size
    file_size : i64;
    {
        if !win32.get_file_size_ex(file_handle, &file_size)
        {
            return "", win32.get_last_error();
        }
    }

    // Read data
    data := make([]byte, file_size);
    {
        total_read : i32;
        e := win32.read_file(file_handle, &data[0], u32(file_size), &total_read, nil);
        if !e
        {
            return "", win32.get_last_error();
        }
    }

    return string(data), 0;
}

close :: proc(file_handle : win32.Handle) -> i32
{
    if win32.close_handle(file_handle) != 0
    {
        return win32.get_last_error();
    }
    return 0;
}