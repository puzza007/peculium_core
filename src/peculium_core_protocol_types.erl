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
%%% @doc Bitcoin Protocol Type Encoders and Decoders.
%%% This module contains utilities to encode and decode between types used by
%%% the Bitcoin protocol.
%%% @end
%%% ----------------------------------------------------------------------------
-module(peculium_core_protocol_types).

%% API.
-export([int8_t/1, int16_t/1, int32_t/1, int64_t/1, uint8_t/1, uint16_t/1,
        uint32_t/1, uint64_t/1, var_int/1, var_string/1, net_addr/1,
        net_addr/2, net_addr/3, bool/1, inv/1, block_header/1,
        transaction_input/1, transaction_output/1, transaction_outpoint/1,
        transaction/1, block/1]).

%% Types.
-type int8_t() :: peculium_core_types:int8_t().
-type int16_t() :: peculium_core_types:int16_t().
-type int32_t() :: peculium_core_types:int32_t().
-type int64_t() :: peculium_core_types:int64_t().
-type uint8_t() :: peculium_core_types:uint8_t().
-type uint16_t() :: peculium_core_types:uint16_t().
-type uint32_t() :: peculium_core_types:uint32_t().
-type uint64_t() :: peculium_core_types:uint64_t().
-type network_address() :: peculium_core_types:network_address().
-type inv() :: peculium_core_types:inv().
-type block() :: peculium_core_types:block().
-type block_header() :: peculium_core_types:block_header().
-type transaction() :: peculium_core_types:transaction().
-type transaction_outpoint() :: peculium_core_types:transaction_outpoint().
-type transaction_input() :: peculium_core_types:transaction_input().
-type transaction_output() :: peculium_core_types:transaction_output().

-include("peculium_core.hrl").

-include_lib("kernel/include/inet.hrl").

%% Tests.
-include("peculium_core_test.hrl").

-spec int8_t(int8_t()) -> integer();
            (binary()) -> int8_t().
int8_t(X) when is_integer(X) ->
    <<X:8/little-signed-integer>>;
int8_t(<<X:8/little-signed-integer>>) ->
    X.

-spec int16_t(int16_t()) -> integer();
             (binary()) -> int16_t().
int16_t(X) when is_integer(X) ->
    <<X:16/little-signed-integer>>;
int16_t(<<X:16/little-signed-integer>>) ->
    X.

-spec int32_t(int32_t()) -> integer();
             (binary()) -> int32_t().
int32_t(X) when is_integer(X) ->
    <<X:32/little-signed-integer>>;
int32_t(<<X:32/little-signed-integer>>) ->
    X.

-spec int64_t(int64_t()) -> integer();
             (binary()) -> int64_t().
int64_t(X) when is_integer(X) ->
    <<X:64/little-signed-integer>>;
int64_t(<<X:64/little-signed-integer>>) ->
    X.

-spec uint8_t(uint8_t()) -> non_neg_integer();
             (binary()) -> uint8_t().
uint8_t(X) when is_integer(X) ->
    <<X:8/little-unsigned-integer>>;
uint8_t(<<X:8/little-unsigned-integer>>) ->
    X.

-spec uint16_t(uint16_t()) -> non_neg_integer();
              (binary()) -> uint16_t().
uint16_t(X) when is_integer(X) ->
    <<X:16/little-unsigned-integer>>;
uint16_t(<<X:16/little-unsigned-integer>>) ->
    X.

-spec uint32_t(uint32_t()) -> non_neg_integer();
              (binary()) -> uint32_t().
uint32_t(X) when is_integer(X) ->
    <<X:32/little-unsigned-integer>>;
uint32_t(<<X:32/little-unsigned-integer>>) ->
    X.

-spec uint64_t(uint64_t()) -> non_neg_integer();
              (binary()) -> uint64_t().
uint64_t(X) when is_integer(X) ->
    <<X:64/little-unsigned-integer>>;
uint64_t(<<X:64/little-unsigned-integer>>) ->
    X.

-spec var_int(binary()) -> {ok, integer(), binary()} | {error, {invalid_var_int, any()}};
             (integer()) -> {ok, iolist()} | {error, any()}.
var_int(<<X:8/little-unsigned-integer, Rest/binary>>) when X < 16#fd ->
    {ok, X, Rest};
var_int(<<16#fd:8, X:16/little-unsigned-integer, Rest/binary>>) ->
    {ok, X, Rest};
var_int(<<16#fe:8, X:32/little-unsigned-integer, Rest/binary>>) ->
    {ok, X, Rest};
var_int(<<16#ff:8, X:64/little-unsigned-integer, Rest/binary>>) ->
    {ok, X, Rest};
var_int(X) when is_integer(X), X < 16#fd ->
    {ok, [uint8_t(X)]};
var_int(X) when is_integer(X), X =< 16#fff ->
    {ok, [uint8_t(16#fd), uint16_t(X)]};
var_int(X) when is_integer(X), X =< 16#ffffffff ->
    {ok, [uint8_t(16#fe), uint32_t(X)]};
var_int(X) when is_integer(X) ->
    {ok, [uint8_t(16#ff), uint64_t(X)]};
var_int(X) ->
    {error, {invalid_var_int, X}}.

-spec var_string(binary()) -> {ok, binary(), binary()} | {error, any()}.
var_string(X) when is_binary(X) ->
    case var_int(X) of
        {ok, Length, Rest} ->
            case Rest of
                <<Result:Length/binary, Rest2/binary>> ->
                    {ok, Result, Rest2};
                _Otherwise ->
                    {error, {invalid_var_int, insufficient_data}}
            end;
        {error, _} = Error ->
            Error
    end;
var_string(String) when is_list(String) ->
    {ok, VarInt} = var_int(string:len(String)),
    [VarInt, String].

-spec map_to_v6(inet:ip_address()) -> {ok, inet:ip6_address()} | {error, term()}.
map_to_v6({A, B, C, D}) ->
    {ok, {0, 0, 0, 0, 0, 16#ffff, (A bsl 8) + B, (C bsl 8) + D}};
map_to_v6(Address) when is_tuple(Address), tuple_size(Address) == 8 ->
    {ok, Address};
map_to_v6(X) ->
    {error, {invalid_address, X}}.

-spec unpack_address(binary()) -> [integer()].
unpack_address(<<>>) ->
    [];
unpack_address(<<X:16/big, Rest/binary>>) ->
    [X | unpack_address(Rest)].

-spec net_addr(binary()) -> {ok, network_address()}.
net_addr(<<Time:4/binary, Services:8/binary, Address:16/binary, Port:2/binary>>) ->
    {ok, #network_address {
        time = uint32_t(Time),
        services = uint64_t(Services),
        address = list_to_tuple(unpack_address(Address)),
        port = uint16_t(Port)
    } };
net_addr(<<X:26/binary>>) ->
    net_addr(<<0, 0, 0, 0, X/binary>>).

-spec net_addr(Address :: inet:ip_address(), Port :: inet:port_number()) -> iolist().
net_addr(Address, Port) ->
    {ok, V6MappedAddress} = map_to_v6(Address),
    EncodedAddress = [<<X:8/big-unit:2>> || X <- tuple_to_list(V6MappedAddress)],
    [uint64_t(60001), EncodedAddress, <<Port:16/big-unsigned-integer>>].

-spec net_addr(Timestamp :: non_neg_integer(), Address :: inet:ip_address(), Port :: inet:port_number()) -> iolist().
net_addr(Timestamp, Address, Port) ->
    [uint32_t(Timestamp) | net_addr(Address, Port)].

-spec bool(uint8_t()) -> boolean().
bool(X) ->
    uint8_t(X) =/= 0.

-spec inv(binary()) -> {ok, inv()}.
inv(<<Type:4/binary, Hash:32/binary>>) ->
    {ok, TypeAtom} = peculium_core_protocol_utilities:inv_to_atom(uint32_t(Type)),
    {ok, #inv {
        type = TypeAtom,
        hash = Hash
    } };

inv(#inv { type = Type, hash = Hash }) ->
    {ok, IntType} = peculium_core_protocol_utilities:atom_to_inv(Type),
    [uint32_t(IntType), Hash].

-spec block_header(binary()) -> {ok, block_header()} | {error, term()}.
block_header(<<RawVersion:4/binary, PreviousBlock:32/binary, MerkleRoot:32/binary, RawTimestamp:4/binary, RawBits:4/binary, RawNonce:4/binary, RawTransactionCount:1/binary>>) ->
    {ok, #block_header {
        version = uint32_t(RawVersion),
        previous_block = PreviousBlock,
        merkle_root = MerkleRoot,
        timestamp = uint32_t(RawTimestamp),
        bits = uint32_t(RawBits),
        nonce = uint32_t(RawNonce),
        transaction_count = uint8_t(RawTransactionCount)
    } }.

-spec transaction_outpoint(binary()) -> {ok, transaction_outpoint()};
                          (transaction_outpoint()) -> iolist().
transaction_outpoint(<<Hash:32/binary, Index:4/binary>>) ->
    {ok, #transaction_outpoint {
        index = uint32_t(Index),
        hash = Hash
    } };
transaction_outpoint(#transaction_outpoint { index = Index, hash = Hash }) ->
    [Hash, uint32_t(Index)].

-spec transaction_input(binary()) -> {ok, transaction_input()} | {error, term()};
                       (transaction_input()) -> iolist().
transaction_input(<<RawOutpoint:36/binary, X/binary>>) ->
    {ok, Outpoint} = transaction_outpoint(RawOutpoint),
    case var_int(X) of
        {ok, Length, Rest} ->
            case Rest of
                <<Script:Length/binary, Sequence:4/binary, Rest1/binary>> ->
                    {ok, #transaction_input {
                        previous_output = Outpoint,
                        script = Script,
                        sequence = uint32_t(Sequence)
                    }, Rest1};
                {error, _} = Error ->
                    Error
            end;
        {error, _} = Error ->
            Error
    end;
transaction_input(#transaction_input { previous_output = PreviousOutput, script = Script, sequence = Sequence }) ->
    {ok, ScriptLength} = var_int(byte_size(Script)),
    [transaction_outpoint(PreviousOutput), ScriptLength, Script, uint32_t(Sequence)].

-spec transaction_output(binary()) -> {ok, transaction_output()} | {error, term()};
                        (transaction_output()) -> iolist().
transaction_output(<<Value:8/binary, X/binary>>) ->
    case var_int(X) of
        {ok, Length, Rest} ->
            case Rest of
                <<Script:Length/binary, Rest1/binary>> ->
                    {ok, #transaction_output {
                        value = int64_t(Value),
                        script = Script
                    }, Rest1};
                {error, _} = Error ->
                    Error
            end;
        {error, _} = Error ->
            Error
    end;
transaction_output(#transaction_output { value = Value, script = Script }) ->
    {ok, ScriptLength} = var_int(byte_size(Script)),
    [int64_t(Value), ScriptLength, Script].

%% @doc Encode transaction.
-spec transaction(Transaction :: transaction()) -> iolist();
                 (WireTransaction :: binary()) -> {ok, transaction()} | {error, term()}.
transaction(#transaction { version = Version, transaction_inputs = Inputs, transaction_outputs = Outputs, lock_time = LockTime }) ->
    {ok, InputsLength} = var_int(length(Inputs)),
    {ok, OutputsLength} = var_int(length(Outputs)),
    [uint32_t(Version), InputsLength, lists:map(fun transaction_input/1, Inputs), OutputsLength, lists:map(fun transaction_output/1, Outputs), uint32_t(LockTime)];

transaction(WireTransaction) ->
    case decode_transaction(WireTransaction) of
        {ok, Transaction, <<>>} ->
            {ok, Transaction};

        {error, _} = Error ->
            Error
    end.

%% @doc Encode or decode block.
-spec block(Block :: block()) -> iolist();
           (RawBlock :: binary()) -> {ok, block()} | {error, term()}.
block(#block { version = Version, previous_block = PreviousBlock, merkle_root = MerkleRoot, timestamp = Timestamp, bits = Bits, nonce = Nonce, transactions = Transactions }) ->
    {ok, TransactionsLength} = var_int(length(Transactions)),
    [uint32_t(Version), PreviousBlock, MerkleRoot, uint32_t(Timestamp), uint32_t(Bits), uint32_t(Nonce), TransactionsLength, lists:map(fun transaction/1, Transactions)];
block(WireBlock) ->
    decode_block(WireBlock).

%% @private
-spec decode_block(binary()) -> {ok, block()} | {error, term()}.
decode_block(<<Version:4/binary, PreviousBlock:32/binary, MerkleRoot:32/binary, Timestamp:4/binary, Bits:4/binary, Nonce:4/binary, X/binary>>) ->
    case peculium_core_protocol_types:var_int(X) of
        {ok, Count, Rest} ->
            case peculium_core_protocol_utilities:decode_dynamic_vector(Rest, Count, fun decode_transaction/1) of
                {ok, Transactions, <<>>} ->
                    {ok, #block {
                        version = peculium_core_protocol_types:uint32_t(Version),
                        previous_block = PreviousBlock,
                        merkle_root = MerkleRoot,
                        timestamp = peculium_core_protocol_types:uint32_t(Timestamp),
                        bits = peculium_core_protocol_types:uint32_t(Bits),
                        nonce = peculium_core_protocol_types:uint32_t(Nonce),
                        transactions = Transactions
                    }};

                {error, _} = Error ->
                    Error
            end;
        {error, _} = Error ->
            Error
    end.

%% @private
decode_transaction(<<Version:4/binary, X/binary>>) ->
    case decode_transaction_input_vector(X) of
        {ok, TransactionInputs, Rest} ->
            case decode_transaction_output_vector(Rest) of
                {ok, TransactionOutputs, <<LockTime:4/binary, Rest1/binary>>} ->
                    {ok, #transaction {
                        version = peculium_core_protocol_types:uint32_t(Version),
                        transaction_inputs = TransactionInputs,
                        transaction_outputs = TransactionOutputs,
                        lock_time = peculium_core_protocol_types:uint32_t(LockTime)
                    }, Rest1};
                {error, _} = Error ->
                    Error
            end;
        {error, _} = Error ->
            Error
    end.

%% @private
-spec decode_transaction_input_vector(binary()) -> {ok, [transaction_input()], binary()}.
decode_transaction_input_vector(X) ->
    case peculium_core_protocol_types:var_int(X) of
        {ok, Count, Rest} ->
            peculium_core_protocol_utilities:decode_dynamic_vector(Rest, Count, fun transaction_input/1);
        {error, _} = Error ->
            Error
    end.

%% @private
-spec decode_transaction_output_vector(binary()) -> {ok, [transaction_output()], binary()}.
decode_transaction_output_vector(X) ->
    case peculium_core_protocol_types:var_int(X) of
        {ok, Count, Rest} ->
            peculium_core_protocol_utilities:decode_dynamic_vector(Rest, Count, fun transaction_output/1);
        {error, _} = Error ->
            Error
    end.

-ifdef(TEST).

-spec prop_bool() -> any().
prop_bool() ->
    ?FORALL(X, peculium_core_triq:uint8_t(),
        bool(X) =:= (X > 0)).

-spec prop_uint8_t_inverse() -> any().
prop_uint8_t_inverse() ->
    ?FORALL(X, peculium_core_triq:uint8_t(),
        uint8_t(uint8_t(X)) =:= X).

-spec prop_uint8_t_from_uint16_t() -> any().
prop_uint8_t_from_uint16_t() ->
    ?FORALL(X, peculium_core_triq:uint16_t(),
        uint8_t(uint8_t(X)) =:= X band 16#00ff).

-spec prop_uint16_t_inverse() -> any().
prop_uint16_t_inverse() ->
    ?FORALL(X, peculium_core_triq:uint16_t(),
        uint16_t(uint16_t(X)) =:= X).

-spec prop_uint16_t_from_uint32_t() -> any().
prop_uint16_t_from_uint32_t() ->
    ?FORALL(X, peculium_core_triq:uint32_t(),
        uint16_t(uint16_t(X)) =:= X band 16#0000ffff).

-spec prop_uint32_t_inverse() -> any().
prop_uint32_t_inverse() ->
    ?FORALL(X, peculium_core_triq:uint32_t(),
        uint32_t(uint32_t(X)) =:= X).

-spec prop_uint32_t_from_uint64_t() -> any().
prop_uint32_t_from_uint64_t() ->
    ?FORALL(X, peculium_core_triq:uint64_t(),
        uint32_t(uint32_t(X)) =:= X band 16#00000000ffffffff).

-spec prop_uint64_t_inverse() -> any().
prop_uint64_t_inverse() ->
    ?FORALL(X, peculium_core_triq:uint64_t(),
        uint64_t(uint64_t(X)) =:= X).

-spec prop_int8_t_inverse() -> any().
prop_int8_t_inverse() ->
    ?FORALL(X, peculium_core_triq:int8_t(),
        int8_t(int8_t(X)) =:= X).

-spec prop_int16_t_inverse() -> any().
prop_int16_t_inverse() ->
    ?FORALL(X, peculium_core_triq:int16_t(),
        int16_t(int16_t(X)) =:= X).

-spec prop_int32_t_inverse() -> any().
prop_int32_t_inverse() ->
    ?FORALL(X, peculium_core_triq:int32_t(),
        int32_t(int32_t(X)) =:= X).

-spec prop_int64_t_inverse() -> any().
prop_int64_t_inverse() ->
    ?FORALL(X, peculium_core_triq:int64_t(),
        int64_t(int64_t(X)) =:= X).

-endif.
