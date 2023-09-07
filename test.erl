%% @author eavnvya
%% @doc @todo Add description to test.


-module(test).

-export([bench/2, request/2]).

bench(Host, Port) ->
    N = 100, % Number of test repetitions
    TotalTime = run(N, Host, Port, 0),
    AverageTime = TotalTime / N,
    io:format("Average response time: ~p microseconds~n", [AverageTime]).

run(0, _Host, _Port, TotalTime) ->
    TotalTime;
run(N, Host, Port, TotalTime) ->
    {Start, _} = timer:tc(test, request, [Host, Port]),
    NewTotalTime = TotalTime + Start,
    run(N - 1, Host, Port, NewTotalTime).

request(Host, Port) ->
    Opt = [list, {active, false}, {reuseaddr, true}],
    {ok, Server} = gen_tcp:connect(Host, Port, Opt),
    gen_tcp:send(Server, http:get("/home.html")),
    Recv = gen_tcp:recv(Server, 0),
    case Recv of
        {ok, _} ->
            ok;
        {error, Error} ->
            io:format("test: error: ~w~n", [Error])
    end,
    gen_tcp:close(Server).