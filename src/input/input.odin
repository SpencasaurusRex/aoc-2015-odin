package input

// import "core:sys/win32"

// input_record :: struct
// {
//     event_type : u16,
//     event : union { 
//         key_event_record, 
//         mouse_event_record, 
//         window_buffer_size_record, 
//         menu_event_record, 
//         focus_event_record
//     }
// }

// key_event_record :: struct
// {

// }

// mouse_event_record :: struct
// {

// }

// window_buffer_size_record :: struct 
// {

// }

// menu_event_record :: struct 
// {

// }

// focus_event_record :: struct
// {

// }

// foreign import Kernel32 "system:Kernel32.lib"
// foreign Kernel32
// {
//     @(link_name="CreateConsoleScreenbuffer")

//     @(link_name="ReadConsoleInput") read_console_input :: proc(
//         console_input : win32.Handle, 
//         input_record : ^input_record,
//         length : u32,
//         num_events_read : ^&u32
//     )
// }