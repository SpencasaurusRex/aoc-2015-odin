package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:container"

read_input_file :: proc(index: int) -> (string, bool) 
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

day_one :: proc(input: string) 
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
        do fmt.println("Invalid character:", c);

        if pt2 && !reached_basement
        {
            if floor < 0 
            {
                fmt.println("Reached basement at position:", position);
                reached_basement = true;
            }
            position = position + 1;
        }
    }

    fmt.println("Final floor: ", floor);
}

min_two :: proc(a: int, b: int) -> int
{ 
    m := a;
    if b < m do m = b;
    return m;
}

min_three :: proc(a: int, b: int, c: int) -> int
{ 
    m := a;
    if b < m do m = b;
    if c < m do m = c;
    return m;
}

min :: proc
{
    min_two,
    min_three
};

day_two :: proc(input: string) 
{
    pt2 :: true;
    
    // Array of l,w,h, l,w,h, ...
    box_sizes := make([dynamic]int);
    defer delete(box_sizes);

    // Parse individual numbers via slicing
    num_start_index := 0;
    char_index := 0;
    
    for c in input 
    {
        switch c 
        {
            case 'x':
                fallthrough;
            case '\n':
                size := strconv.atoi(input[num_start_index : char_index]);
                append(&box_sizes, size);
                num_start_index = char_index + 1;
        }
        char_index = char_index + 1;
    }

    // Calculate surface areas + slack
    wrapping_paper := 0;
    ribbon := 0;

    for box_index := 0; box_index < len(box_sizes); box_index = box_index + 3
    {
        l := box_sizes[box_index];
        w := box_sizes[box_index + 1];
        h := box_sizes[box_index + 2];

        l_w := l * w;
        w_h := w * h;
        l_h := l * h;

        surface := 2 * (l_w + w_h + l_h);
        slack := min(l_w, w_h, l_h);

        wrapping_paper += surface + slack;

        if pt2
        {
            perimeter_l_w := 2 * (l + w);
            perimeter_w_h := 2 * (w + h);
            perimeter_l_h := 2 * (l + h);

            ribbon = ribbon + min(perimeter_l_w, perimeter_w_h, perimeter_l_h) + l * w * h;
        }
    }

    fmt.println("Total wrapping paper required:", wrapping_paper, "sq ft.");
    if pt2 do fmt.println("Total ribbon needed:", ribbon, "ft.");
}

print_binary :: proc(num: int)
{
    bit_mask : int = 1 << 62;
    i : uint = 62;
    for
    {
        digit := (num & bit_mask) >> i;
        fmt.print(digit);
        bit_mask = bit_mask >> 1;
        if i == 0 
        {
            fmt.println();
            return;
        }
        i = i - 1;
    }
}

// Custom hashing algorithm, putting y into left 32 bits and x into right 32 bits
hash_2D :: proc(x: int, y: int) -> i64
{
    mask_32 := 1 << 32 - 1;

    x_32 := i64(x & mask_32);
    y_32 := i64(y & mask_32);

    hash : i64 = y_32 << 32 + x_32;

    return hash;
}


day_three :: proc(input: string)
{
    pt2 :: true;

    // Record coordinates as we go
    m := make(map[i64]int);

    if !pt2
    {
        x := 0;
        y := 0;
        houses := 1;

        // Record visiting 0
        m[hash_2D(x, y)] = 1;

        for c in input 
        {
            switch c 
            {
                case '^':
                    y = y + 1;
                case 'v':
                    y = y - 1;
                case '>':
                    x = x + 1;
                case '<':
                    x = x - 1;
            }

            hash := hash_2D(x, y);

            exists := hash in m;
            if !exists 
            {
                m[hash] = 1;
                houses = houses + 1;
            }
            else
            {
                m[hash] = m[hash] + 1;
            }
        }

        fmt.println("Unique houses visited:", houses);    
    }
    else
    {
        x_santa := 0;
        y_santa := 0;
        x_robo  := 0;
        y_robo  := 0;
        santa   := true;
        houses := 1;

        // Record visiting 0
        m[hash_2D(0, 0)] = 2;

        for c in input 
        {
            switch c 
            {
                case '^':
                    if santa do y_santa = y_santa + 1;
                    else do y_robo = y_robo + 1;
                case 'v':
                    if santa do y_santa = y_santa - 1;
                    else do y_robo = y_robo - 1;
                case '>':
                    if santa do x_santa = x_santa + 1;
                    else do x_robo = x_robo + 1;
                case '<':
                    if santa do x_santa = x_santa - 1;
                    else do x_robo = x_robo - 1;
            }
            

            hash : i64;
            if santa do hash = hash_2D(x_santa, y_santa);
            else do hash = hash_2D(x_robo, y_robo);

            exists := hash in m;
            if !exists 
            {
                m[hash] = 1;
                houses = houses + 1;
            }
            else
            {
                m[hash] = m[hash] + 1;
            }

            santa = !santa;
        }

        fmt.println("Unique houses visited:", houses); 
    }
}

is_vowel :: proc(c: rune) -> bool
{
    if c == 'a' do return true;
    if c == 'e' do return true;
    if c == 'i' do return true;
    if c == 'o' do return true;
    if c == 'u' do return true;
    return false;
}

is_naughty_string :: proc(prev_c: rune, c: rune) -> bool
{
    // ab, cd, pq, or xy
    if prev_c == 'a' && c == 'b' do return true;
    if prev_c == 'c' && c == 'd' do return true;
    if prev_c == 'p' && c == 'q' do return true;
    if prev_c == 'x' && c == 'y' do return true;
    return false;
}

has_double_pair :: proc(data: []i64) -> bool
{
    for i:=0; i < len(data); i=i+1
    {
        if data[i] == 0 do continue;
        for j:=i+1; j < len(data); j=j+1
        {
            if data[j] == 0 do continue;

            // If the pair are the same hash
            same_hash := data[i] == data[j];
            overlapping := j - i == 1;

            if same_hash && !overlapping do return true;
        }
    }
    return false;
}

day_five :: proc(input: string)
{
    pt2 :: true;

    nice_word_count := 0;

    if !pt2
    {
        prev_c := ' ';
        duplicate := false;
        vowel_count := 0;
        invalid := false;

        for c in input 
        {
            switch c
            {
                case '\n':
                    // Check conditions
                    if !invalid && vowel_count >= 3 && duplicate 
                    {
                        nice_word_count = nice_word_count + 1;
                    }

                    prev_c = ' ';
                    duplicate = false;
                    vowel_count = 0;
                    invalid = false;
                case:
                    if is_vowel(c) do vowel_count = vowel_count + 1;
                    if prev_c == c do duplicate = true;
                    if is_naughty_string(prev_c, c) do invalid = true;
                    prev_c = c;
            }
        }    
    }
    else
    {
        pairs := make([]i64, 15);
        defer delete(pairs);

        prev_prev_c := ' ';
        prev_c := ' ';
        stagger := false;
        char_pos := 0;

        for c in input
        {
            switch c 
            {
                case '\r':
                    ;
                case '\n':
                    // Check conditions
                    dd := has_double_pair(pairs);
                    // fmt.println("Stagger:", stagger, "DD:", dd);
                    if stagger && dd 
                    {
                        nice_word_count = nice_word_count + 1;
                    }

                    prev_prev_c = ' ';
                    prev_c = ' ';
                    stagger = false;
                    char_pos = 0;
                case:
                    // fmt.print(prev_prev_c, prev_c, c);
                    if prev_prev_c == c do stagger = true;
                    // fmt.print(" Stagger:", stagger);
                    if char_pos >= 1 
                    {
                        pairs[char_pos - 1] = hash_2D(int(prev_c), int(c));
                    }
                    
                    // fmt.print(" pair: ");
                    // for i:=0; i<len(pairs);i=i+1
                    // {
                    //     fmt.print(pairs[i], "|");
                    // }

                    prev_prev_c = prev_c;
                    prev_c = c;
                    char_pos = char_pos + 1;
                    // fmt.println();
            }
        }
    }

    fmt.println("Number of nice words:", nice_word_count);
}

CommandType :: enum 
{
    turn_on,
    turn_off,
    toggle
}

Command :: struct
{
    type : CommandType,
    lower_x : int,
    lower_y : int,
    upper_x : int,
    upper_y : int
}

parse_commands :: proc(input: string) -> [dynamic]Command
{
    start_index := 0;
    current_index := 0;

    commands := make([dynamic]Command);

    comma_index := 0;

    // State 0 : command
    // State 1 : first coordinate pair
    // State 2 : through
    // State 3 : second coordinate pair
    state := 0;

    command : Command;

    debug :: false;

    for c in input
    {
        if debug do fmt.print("Character:", c, "State:", state);

        if debug 
        {
            fmt.print("\"");
            fmt.print(input[start_index:current_index]);
            fmt.print("\"");
        }

        if input[current_index] == '\n'
        {
            state = 0;
            start_index = current_index + 1;
        }
        else if state == 0
        {
            if input[start_index : current_index] == "turn on "
            {
                command.type = CommandType.turn_on;
                state = state + 1;
                start_index = current_index;
            }
            else if input[start_index : current_index] == "turn off "
            {
                command.type = CommandType.turn_off;
                state = state + 1;
                start_index = current_index;
            }
            else if input[start_index : current_index] == "toggle "
            {
                command.type = CommandType.toggle;
                state = state + 1;
                start_index = current_index;
            }
            if debug do fmt.print(" CommandType:", command.type);
        }
        else if state == 1 || state == 3
        {
            // Check for comma
            letter := input[current_index];
            if letter == ',' do comma_index = current_index;
            if letter == ' ' || letter == '\r'
            {
                // Parse x
                x,_ := strconv.parse_int(input[start_index:comma_index]);

                // Parse y
                y,_ := strconv.parse_int(input[comma_index+1: current_index]);

                if state == 1
                {
                    command.lower_x = x;
                    command.lower_y = y;
                    state = state + 1;
                }
                else if state == 3
                {
                    command.upper_x = x;
                    command.upper_y = y;

                    if debug do fmt.println();
                    if debug do fmt.println(command.lower_x, command.lower_y, command.upper_x, command.upper_y, command.type);

                    append(&commands, command);
                    state = 0;
                }

                start_index = current_index + 1;
            }
        }
        else if state == 2
        {
            if input[current_index] == ' '
            {
                state = state + 1;
                start_index = current_index + 1;
            }
        }
    
        current_index = current_index + 1;
        if debug do fmt.println();
    }

    return commands;
}

to_index :: proc(x: int, y: int) -> int
{
    return y * 1000 + x;
}

max :: proc(a: int, b: int) -> int
{
    m := a;
    if b > a do m = b;
    return m;
}

day_six :: proc(input: string)
{
    commands:= parse_commands(input);
    defer delete(commands);

    pt2 :: true;

    if !pt2
    {
        lights := make([]bool, 1_000_000);
        defer delete(lights);

        // Execute all commands
        for i := 0; i < len(commands); i=i+1
        {
            command := commands[i];
            for y := command.lower_y; y <= command.upper_y; y=y+1
            {
                for x := command.lower_x; x <= command.upper_x; x=x+1 
                {
                    index := to_index(x, y);
                    if command.type == CommandType.turn_on
                    {
                        lights[index] = true;
                    }
                    else if command.type == CommandType.turn_off
                    {
                        lights[index] = false;
                    }
                    else if command.type == CommandType.toggle
                    {
                        lights[index] = !lights[index];
                    }
                }    
            }
        }

        number_of_lights_on := 0;
        for i := 0; i < len(lights); i=i+1
        {
            if lights[i] do number_of_lights_on = number_of_lights_on + 1;
        }

        fmt.println("Total number of lights on:", number_of_lights_on);    
    }
    
    {
        lights := make([]int, 1_000_000);
        defer delete(lights);

        // Execute all commands
        for i := 0; i < len(commands); i=i+1
        {
            command := commands[i];
            for y := command.lower_y; y <= command.upper_y; y=y+1
            {
                for x := command.lower_x; x <= command.upper_x; x=x+1 
                {
                    index := to_index(x, y);
                    current := lights[index];
                    if command.type == CommandType.turn_on 
                    {
                        lights[index] = current + 1;
                    }
                    else if command.type == CommandType.turn_off
                    {
                        lights[index] = max(current - 1, 0);
                    }
                    else if command.type == CommandType.toggle
                    {
                        lights[index] = current + 2;
                    }
                }
            }
        }

        total_brightness := 0;
        for i := 0; i < len(lights); i=i+1
        {
            total_brightness = total_brightness + lights[i];
        }

        fmt.println("Total brightness:", total_brightness);
    }
}

TokenType :: enum
{
    VALUE,
    IDENTIFIER,
    AND,
    OR,
    RSHIFT,
    LSHIFT,
    NOT,
    ARROW,
    NEWLINE
}

Token :: struct
{
    type: TokenType,
    value: string
}

OperationType :: enum
{
    AND,
    OR,
    RSHIFT,
    LSHIFT,
    NOT,
    ASSIGN
}

Operation :: struct
{
    operand_1: ^Token,
    operand_2: ^Token,
    type: OperationType,
    result: ^Token
}

day_seven_parse :: proc(tokens: ^[dynamic]Token, operations: ^[dynamic]Operation)
{
    next_token :: proc(tokens: ^[dynamic]Token, i: ^int) -> (bool, ^Token)
    {
        i^ = i^ + 1;
        valid := len(tokens) > i^;
        token := &tokens^[i^ - 1] if valid else nil;
        return valid, token;
    }

    i := 0;
    token_set : [6]^Token;
    next := true;

    MAX_TOKENS :: 6;

    for next
    {
        // Form operation
        op: Operation;

        fmt.println();
        for j:=0; j < MAX_TOKENS && next; j = j + 1
        {
            next, token_set[j] = next_token(tokens, &i);
            fmt.println(token_set[j]);
            if !next || token_set[j].type == .NEWLINE
            {
                break;
            }
        }

        op.operand_1 = token_set[0];
        op.operand_2 = token_set[2];
        op.result = token_set[4];

        #partial switch token_set[1].type
        {
            case TokenType.AND:
                op.type = OperationType.AND;
            case TokenType.OR:
                op.type = OperationType.OR;
            case TokenType.LSHIFT:
                op.type = OperationType.LSHIFT;
            case TokenType.RSHIFT:
                op.type = OperationType.RSHIFT; 
            case TokenType.ARROW: 
                op.operand_1 = token_set[0];
                op.operand_2 = nil;
                op.result = token_set[2];
                op.type = OperationType.ASSIGN;
            case:
                if token_set[0].type == TokenType.NOT && token_set[1].type == TokenType.IDENTIFIER
                {
                    op.operand_1 = token_set[1];
                    op.operand_2 = nil;
                    op.result = token_set[3];
                    op.type = OperationType.NOT;
                }
                else 
                {
                    fmt.println("Aaaaaaah, unknown operation");
                }  
        }

        fmt.println(op);
        append(operations, op);
    }
}

create_token :: proc(value: string) -> Token
{
    using TokenType;

    token : Token;
    token.value = value;

    switch value 
    {
        case "NOT":
            token.type = NOT;
        case "AND":
            token.type = AND;
        case "OR":
            token.type = OR;
        case "RSHIFT":
            token.type = RSHIFT;
        case "LSHIFT":
            token.type = LSHIFT;
        case "->":
            token.type = ARROW;
        case "\n":
            token.type = NEWLINE;
        case: 
            switch value[0]
            {
                case 'a'..'z':
                    token.type = IDENTIFIER;
                case '0'..'9':
                    token.type = VALUE;
                case:
                    fmt.println("Uh oh");
            }
    }
    //fmt.println(token.value, token.type);
    return token;
}

day_seven :: proc(input : string)
{

    pt2 :: true;

    tokens := make([dynamic]Token);
    operations := make([dynamic]Operation);
    operation_lookup := make(map[string]Operation);

    fmt.println("Tokenizing");
    left := 0;
    right := 0;
    for c in input
    {
        switch c
        {
            case ' ': fallthrough;
            case '\r':
                append(&tokens, create_token(input[left:right]));
                left = right + 1;
            
            case '\n': 
                append(&tokens, create_token("\n"));
                left = right + 1;       
        }

        right = right + 1;
    }

    fmt.println("Parsing");
    day_seven_parse(&tokens, &operations);

    
    fmt.println("Simulating");
    using OperationType;
    values := make(map[string]int);

    for operation in operations 
    {
        operation_lookup[operation.result^.value] = operation;
    }

    if pt2
    {
        operation_lookup["b"].operand_1.value = "956";
    }

    fmt.println(get_value("a", &operations, &operation_lookup, &values));
}

get_value :: proc(key: string, operations: ^[dynamic]Operation, operation_lookup: ^map[string]Operation, values: ^map[string]int) -> int
{
    operation := operation_lookup[key];
    //fmt.println("Operation that results in", key, ":", operation);

    result := operation.result.value;

    operand_1 : int;
    operand_2 : int;

    if operation.operand_1 != nil
    {
        if operation.operand_1.type == TokenType.VALUE
        {
            operand_1,_ = strconv.parse_int(operation.operand_1.value);
        }
        else if operation.operand_1.value in values^
        {
            operand_1 = values[operation.operand_1.value];
        }
        else
        {
            operand_1 = get_value(operation.operand_1.value, operations, operation_lookup, values);
        }
        values[operation.operand_1.value] = operand_1;
    }
    if operation.operand_2 != nil
    {
        if operation.operand_2.type == TokenType.VALUE
        {
            operand_2,_ = strconv.parse_int(operation.operand_2.value);
        }
        else if operation.operand_2.value in values^
        {
            operand_2 = values[operation.operand_2.value];
        }
        else
        {
            operand_2 = get_value(operation.operand_2.value, operations, operation_lookup, values);
        }
        values[operation.operand_2.value] = operand_2;
    }

    if operation.type == OperationType.ASSIGN
    {
        fmt.println("Assigning", operand_1, "to", result);
        return operand_1;
    }
    else if operation.type == OperationType.AND
    {
        fmt.println("Assigning", operand_1, "AND", operand_2, operand_1 & operand_2, "to", result);
        return operand_1 & operand_2;
    }
    else if operation.type == OperationType.OR
    {
        fmt.println("Assigning", operand_1, "OR", operand_2, ":", operand_1 | operand_2, "to", result);
        return operand_1 | operand_2;
    }
    else if operation.type == OperationType.NOT
    {
        fmt.println("Assigning NOT", operand_1, ":", 65535 - operand_1, "to", result);
        return 65535 - operand_1;
    }
    else if operation.type == OperationType.LSHIFT 
    {
        fmt.println("Assigning", operand_1, "LSHIFT", operand_2, ":", operand_1 << u32(operand_2), "to", result);
        return operand_1 << u32(operand_2);
    }
    else
    {
        fmt.println("Assigning", operand_1, "RSHIFT", operand_2, ":", operand_1 >> u32(operand_2), "to", result);
        return operand_1 >> u32(operand_2);
    }
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
        delete(lower_user_input);

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
            case 2:
                day_two(input);
            case 3:
                day_three(input);
            case 5:
                day_five(input);
            case 6:
                day_six(input);
            case 7:
                day_seven(input);
            // case 8:
            //     day_eight(input);
            // case 9:
            //     day_nine(input);
            // case 10:
            //     day_ten(input);
            // case 11:
            //     day_eleven(input);
            // case 12:
            //     day_twelve(input);
            // case 13:
            //     day_thirteen(input);
            case 8..25:
                fmt.println("Day not implemented");
            case :
                fmt.println("Please enter a valid number day");
        }

        delete(input);
    }
}

/*
1 AND C -> B
B RSHIFT D -> A
NOT 2 -> C
4 LSHIFT 2 -> D

     4
    /
   D - LSHIFT
  / \
 /   2
A - RSHIFT
 \   1
  \ /
   B - AND
    \   2
     \ /
      C - NOT

Node A
    name:  A
    type:  RSHIFT
    left:  B
    right: D

Node B
    name:  A
    type:  AND
    left:  B
    right: D

Node C
    name:  A
    type:  RSHIFT
    left:  B
    right: D

Node D
    name:  A
    type:  RSHIFT
    left:  B
    right: D
    */