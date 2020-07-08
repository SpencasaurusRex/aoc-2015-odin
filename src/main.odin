package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

read_input_file :: proc(index : int) -> (string, bool)
{
    // Create filename
    file_name : string;
    {
        inputs_prefix  :: "..\\inputs\\";
        inputs_postfix :: ".txt";
        
        builder := strings.make_builder();
        strings.write_string(&builder, inputs_prefix);
        strings.write_int(&builder, index);
        strings.write_string(&builder, inputs_postfix);

        file_name = strings.to_string(builder);
    }
    
    // Read from file
    data, success := os.read_entire_file(file_name);
    if !success do return "", success;
    return string(data), success;
}

read_user_input :: proc(data: []byte, length: int) -> bool
{
    index := 0;
    for index < length
    {
        _, input_err := os.read(os.stdin, data[index:index+1]);
        if input_err != 0
        {
            return true;
        }

        // Line feed
        if data[index] == 10 
        {
            return false;
        }
        index = index + 1;
    }

    return false;
}

day_one :: proc(input : string)
{
    pt2 :: true;
    position := 1;
    reached_basement := false;

    floor : int;
    for c in input 
    {
        if c == '(' do floor = floor + 1;
        else
        if c == ')' do floor = floor - 1;
        else
        do fmt.println("Invalid character: ", c);

        if pt2 && !reached_basement
        {
            if floor < 0 
            {
                fmt.println("Reached basement at position: ", position);
                reached_basement = true;
            }
            position = position + 1;
        }
    }

    fmt.println("Final floor: ", floor);
}

main :: proc()
{
    user_input := make([]byte, 4);

    for 
    {
        // Get user input
        fmt.print("Enter day number of puzzle to solve: ");
        input_err := read_user_input(user_input, 4);

        if input_err
        {
            fmt.println("Error reading input");
        }

        // Check for attempted exit
        lower_user_input := strings.to_lower(string(user_input));
        if lower_user_input == "stop" || lower_user_input == "exit"
        {
            return;
        }


        day_number, ok := strconv.parse_int(string(user_input));
        if !ok 
        {
            fmt.println("Please enter a valid number day");
            continue;
        }

        input, read_success := read_input_file(day_number);
        if !read_success
        {
            fmt.println("Error occurred while reading input file");
            continue;
        }

        switch (day_number)
        {
            case 1:
                day_one(input);
            case 2..25:
                fmt.println("Day not implemented");
            case :
                fmt.println("Please enter a valid number day");
        }

        delete(input);
    }

}