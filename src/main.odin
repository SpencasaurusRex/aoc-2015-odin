package main

import "core:fmt"
import "file"

main :: proc()
{
    file_name : string = "..\\src\\main.odin";
    
    text, err := file.read_all_text(file_name);
    if err == 0 do fmt.println(text);
    delete(text);
}