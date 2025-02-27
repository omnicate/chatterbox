-module(double_body_handler).

-include_lib("chatterbox/include/http2.hrl").

-behaviour(h2_stream).

-export([
         init/3,
         on_receive_headers/2,
         on_send_push_promise/2,
         on_receive_data/2,
         on_end_stream/1,
         terminate/1
        ]).

-record(state, {conn_pid :: pid(),
                stream_id :: stream_id()
               }).

-spec init(pid(), stream_id(), list()) -> {ok, any()}.
init(ConnPid, StreamId, _Opts) ->
    {ok, #state{conn_pid=ConnPid,
                stream_id=StreamId}}.

-spec on_receive_headers(
            Headers :: hpack:headers(),
            CallbackState :: any()) -> {ok, NewState :: any()}.
on_receive_headers(_Headers, State) -> {ok, State}.

-spec on_send_push_promise(
            Headers :: hpack:headers(),
            CallbackState :: any()) -> {ok, NewState :: any()}.
on_send_push_promise(_Headers, State) -> {ok, State}.

-spec on_receive_data(
            iodata(),
            CallbackState :: any())-> {ok, NewState :: any()}.
on_receive_data(_Data, State) -> {ok, State}.

-spec on_end_stream(
            CallbackState :: any()) ->
    {ok, NewState :: any()}.
on_end_stream(State=#state{conn_pid=ConnPid,
                                   stream_id=StreamId}) ->
    ResponseHeaders = [
                       {<<":status">>,<<"200">>}
                      ],
    h2_connection:send_headers(ConnPid, StreamId, ResponseHeaders),
    h2_connection:send_body(ConnPid, StreamId, <<"BodyPart1\n">>,
                            [{send_end_stream, false}]),
    h2_connection:send_body(ConnPid, StreamId, <<"BodyPart2">>),
    {ok, State}.

terminate(_State) ->
    ok.
