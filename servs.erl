-module(servs).
-export([start/0]).
-compile([export_all]).


start() ->
    % Start server processes
    Server3 = spawn(servs, serv3, []),
    Server2 = spawn(servs, serv2, [Server3]),
    Server1 = spawn(servs, serv1, [Server2]),

    loop(Server1, Server2, Server3).

loop(Server1, Server2, Server3) ->
    {ok, Message} = io:read("Enter your message: "),

    case Message of 
        % Stop taking messages
        all_done ->
            ok;
        % Send message to server 1
        _Else -> 
            Server1 ! Message,
            loop(Server1, Server2, Server3)
        end.





% Server 1 implementation
serv1(Serv2) -> receive 
    halt -> 
        io:format("(Serv1) Halting~n"),
        Serv2 ! halt;
    % Check if addition
    {add, Val1, Val2} -> 
        Sum = Val1 + Val2,
        io:format("(Serv1) Addition: ~p + ~p = ~p.~n", [Val1, Val2, Sum]),
        serv1(Serv2);
    % Check if subtraction
    {sub, Val1, Val2} -> 
        Subt = Val1 - Val2,
        io:format("(Serv1) Subtraction: ~p - ~p = ~p.~n", [Val1, Val2, Subt]),
        serv1(Serv2);
    % Check if multiplication
    {mul, Val1, Val2} ->
        Mul = Val1 * Val2,
        io:format("(Serv1) Multiplication: ~p x ~p = ~p.~n", [Val1, Val2, Mul]),
        serv1(Serv2);
    % Check if division (using divi because div is a keyword)
    {divi, Val1, Val2} ->
        Divi = Val1 / Val2,
        io:format("(Serv1) Division: ~p / ~p = ~p.~n", [Val1, Val2, Divi]),
        serv1(Serv2);
    % Check if negation
    {neg, Val1} -> 
        Nega = -Val1,
        io:format("(Serv1) Negation: ~p => ~p.~n", [Val1, Nega]),
        serv1(Serv2);
    % Check if square root
    {sqrt, Val1} -> 
        Sqr = math:sqrt(Val1),
        io:format("(Serv1) Negation: ~p => ~p.~n", [Val1, Sqr]),
        serv1(Serv2);
    % Else, send to serv2
    Message -> 
        Serv2 ! Message,
        serv1(Serv2)
    end.





% Server 2 implementation
serv2(Serv3) -> receive 
    halt -> 
        io:format("(Serv2) Halting~n"),
        Serv3 ! halt;
    List when is_list(List) ->
        [H | _T] = List,
        case is_integer(H) of 
            % Check if should add
            true -> 
                NumberList = lists:filter(fun(Val) -> is_integer(Val) or is_float(Val) end, List),
                Sum = lists:sum(NumberList),
                io:format("(Serv2) List sum: ~p~n", [Sum]),
                serv2(Serv3);
            % Check if should multiply
            false -> 
                case is_float(H) of 
                    true -> 
                        NumberList = lists:filter(fun(Val) -> is_integer(Val) or is_float(Val) end, List),
                        Product = lists:foldl(fun(Val, Acc) -> Val * Acc end, 1.0, NumberList),
                        io:format("(Serv2) List product: ~p~n", [Product]),
                        serv2(Serv3);
                    false -> 
                        Serv3 ! List,
                        serv2(Serv3)
                end
        end;
    % Else, send to serv3
    Message -> 
        Serv3 ! Message,
        serv2(Serv3)
    end.





% Server 3 implementation 
serv3() ->  
    accumulator(0).
        
accumulator(Accumulator) -> receive
    halt -> 
        io:format("(Serv3) Halting, ~p handled~n", [Accumulator]),
        ok;
    {error, ErrorMessage} -> 
        io:format("(Serv3) Error:  ~p~n", [ErrorMessage]),
        accumulator(Accumulator);
    _Message -> 
        NewAccumulator = Accumulator + 1,
        io:format("(Serv3) Not handled: ~p~n", [NewAccumulator]),
        accumulator(NewAccumulator)
    end.