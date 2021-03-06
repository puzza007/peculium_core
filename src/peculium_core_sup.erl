%%%
%%% Copyright (c) 2013 Alexander Færøy.
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
%%% @doc        Peculium's Primary Supervisor.
%%% ----------------------------------------------------------------------------
-module(peculium_core_sup).
-behaviour(supervisor).

%% API.
-export([start_link/0]).

%% Supervisor callbacks.
-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(SUPERVISOR, ?MODULE).

%% From supervisor.
-type startlink_err() :: {already_started, pid()} | shutdown | term().
-type startlink_ret() :: {ok, pid()} | ignore | {error, startlink_err()}.

-spec start_link() -> startlink_ret().
start_link() ->
    supervisor:start_link({local, ?SUPERVISOR}, ?MODULE, []).

-spec init([]) -> {ok, {{one_for_one, non_neg_integer(), non_neg_integer()}, []}}.
init(_State) ->
    {ok, {{one_for_one, 5, 10}, [
        ?CHILD(peculium_core_config, worker),
        ?CHILD(peculium_core_address_manager, worker),
        ?CHILD(peculium_core_bootstrap_manager, worker),
        ?CHILD(peculium_core_dns_bootstrap_manager, worker),
        ?CHILD(peculium_core_block_index, worker),
        ?CHILD(peculium_core_block_store, worker),
        ?CHILD(peculium_core_peer_sup, supervisor)
    ]}}.
