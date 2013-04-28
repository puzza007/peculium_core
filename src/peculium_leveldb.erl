%%%
%%% Copyright (c) 2013 Fearless Hamster Solutions.
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%%
%%% * Redistributions of source code must retain the above copyright notice, this
%%%   list of conditions and the following disclaimer.
%%%
%%% * Redistributions in binary form must reproduce the above copyright notice,
%%%   this list of conditions and the following disclaimer in the documentation
%%%   and/or other materials provided with the distribution.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%%% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%%% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%%% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%%% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%%% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%%% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%
%%% ----------------------------------------------------------------------------
%%% @author     Alexander Færøy <ahf@0x90.dk>
%%% @doc        Peculium LevelDB Utilities.
%%% ----------------------------------------------------------------------------
-module(peculium_leveldb).

%% API.
-export([open/1, close/1, put/3, get/2, delete/2]).
-export([open_options/1, read_options/0, write_options/0]).

%% @doc Open LevelDB database.
-spec open(Path :: string()) -> {ok, eleveldb:db_ref()} | {error, any()}.
open(Path) ->
    eleveldb:open(Path, open_options(peculium_config:cache_size())).

%% @doc Close LevelDB database.
-spec close(Database :: eleveldb:db_ref()) -> ok | {error, any()}.
close(Database) ->
    eleveldb:close(Database).

%% @doc Get value from a given key.
-spec get(Database :: eleveldb:db_ref(), Key :: binary()) -> {ok, binary()} | not_found | {error, any()}.
get(Database, Key) ->
    eleveldb:get(Database, Key, read_options()).

%% @doc Insert element.
-spec put(Database :: eleveldb:db_ref(), Key :: binary(), Value :: binary()) -> ok | {error, any()}.
put(Database, Key, Value) ->
    eleveldb:put(Database, Key, Value, write_options()).

%% @doc Delete element.
-spec delete(Database :: eleveldb:db_ref(), Key :: binary()) -> ok | {error, any()}.
delete(Database, Key) ->
    eleveldb:delete(Database, Key, write_options()).

%% @doc Get default database opening options.
-spec open_options(CacheSize :: non_neg_integer()) -> eleveldb:open_options().
open_options(CacheSize) ->
    [
        %% Create the database if it's missing.
        {create_if_missing, true},

        %% Set block size.
        {block_size, CacheSize / 2},

        %% Enable bloom filter.
        {use_bloomfilter, true},

        %% Write buffer size.
        {write_buffer_size, CacheSize / 4}
    ].

%% @doc Get default database read options.
-spec read_options() -> eleveldb:read_options().
read_options() ->
    [
        %% Enable checksum verification.
        {verify_checksums, true}
    ].

%% @doc Get default database write options.
-spec write_options() -> eleveldb:write_options().
write_options() ->
    [
        %% Sync.
        {sync, true}
    ].
