-module(test2).
-export([parse/0, bench/2, bench/4]).

parse() ->
    http:parse_request("GET /home.html HTTP/1.1\r\nUser-Agent: Test\r\nAccept: anything\r\n\r\nBody").

bench(Host, Port) ->
    bench(Host, Port, 3, 15).

bench(Host, Port, C, N) ->
    Start = now(),
    parallel(C, Host, Port, N, self()),
    collect(C),
    Finish = now(),
    T = timer:now_diff(Finish, Start),
    io:format(" ~wx~w requests in ~w ms~n", [C,N, (T div 1000)]).



parallel(0, _, _, _, _) ->
    ok;
parallel(C, Host, Port, N, Ctrl) ->
    spawn(fun() -> report(N, Host, Port, Ctrl) end),
    parallel(C-1, Host, Port, N, Ctrl).


report(N, Host, Port, Ctrl) ->
    run(N, Host, Port),
    Ctrl ! ok.


collect(0) ->
    ok;
collect(N) ->    
    receive 
	ok ->
	    collect(N-1)
    end.

run(0, _, _) ->
    ok;
run(N, Host, Port) ->
    request(Host, Port),
    run(N-1, Host, Port).



request(Host, Port) ->
    {ok, Server} = gen_tcp:connect(Host, Port, [list, {active, false}, {reuseaddr, true}]),
    gen_tcp:send(Server, http:get("/home.html")),
    Recv = gen_tcp:recv(Server, 0),
    case Recv of
     	{ok, _} ->
     	    ok;
     	{error, Error} ->
     	    io:format("test: error: ~w~n", [Error])
    end,
    gen_tcp:close(Server).
    
    


