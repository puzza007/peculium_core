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
%%% @copyright  2013 Alexander Færøy
%%% @end
%%% ----------------------------------------------------------------------------
%%% @doc Bitcoin Difficulty Utilities.
%%% This module contains utilities for calculating the Bitcoin difficulty.
%%% @end
%%% ----------------------------------------------------------------------------
-module(peculium_core_difficulty).

%% API.
-export([from_bits/1, block_work/1, target/1, max_difficulty/0]).

%% Types.
-type uint32_t() :: peculium_core_types:uint32_t().

%% Tests.
-include("peculium_core_test.hrl").

%% @doc Calculates the difficulty from the compact bits representation.
-spec from_bits(Bits :: uint32_t()) -> number().
from_bits(Bits) ->
    max_difficulty() / target(Bits).

%% @doc Calculates the amount of block work from the compact bits representation.
-spec block_work(Bits :: uint32_t()) -> number().
block_work(Bits) ->
    Target = from_bits(Bits),
    (1 bsl 256) / (Target + 1).

%% @doc Calculates the target from the compact bits.
-spec target(Bits :: uint32_t()) -> number().
target(Bits) ->
    %% FIXME: This function could easily be optimized using
    %% shift operators instead of the pow call.
    A = Bits bsr 24,
    B = Bits band 16#007fffff,
    B * math:pow(2, 8 * (A - 3)).

%% @doc Returns the max difficulty.
-spec max_difficulty() -> number().
max_difficulty() ->
    target(16#1d00ffff).

-ifdef(TEST).

-spec from_bits_test() -> any().
from_bits_test() ->
    GenesisBlock = peculium_core_block:genesis_block(mainnet),
    ?assertEqual(from_bits(peculium_core_block:bits(GenesisBlock)), 1.0).

-spec block_work_test() -> any().
block_work_test() ->
    GenesisBlock = peculium_core_block:genesis_block(mainnet),
    ?assertEqual(block_work(peculium_core_block:bits(GenesisBlock)), 5.78960446186581e76).

-spec target_test() -> any().
target_test() ->
    GenesisBlock = peculium_core_block:genesis_block(mainnet),
    ?assertEqual(target(peculium_core_block:bits(GenesisBlock)), 2.695953529101131e67).

-endif.
