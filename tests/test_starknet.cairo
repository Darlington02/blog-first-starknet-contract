%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.starknet import store_name, get_name

const CALLER = 0x00A596deDe49d268d6aD089B56CC76598af3E949183a8ed10aBdE924de191e48;
const NAME = 322918500091226412576622;

// deploy contract and save address to context
@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    %{context.address = deploy_contract("./src/starknet.cairo", [ids.NAME]).contract_address %}

    return ();
}

// test store_name function
@external
func test_store_name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar contract_address: felt;
    // store deployed address initially in context to contract_address variable
    %{ ids.contract_address = context.address %}

    // start a prank
    %{ stop_prank = start_prank(ids.CALLER) %}
    // call the store_name function
    store_name(NAME);

    // test for emitted events
    %{ expect_events({"name": "stored_name", "data" : [ids.CALLER, ids.NAME]}) %}

    // stop prank
    %{ stop_prank() %}

    return ();
}

@external
func test_get_name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // start prank
    %{ stop_prank = start_prank(ids.CALLER) %}
    // call the store_name function
    store_name(NAME);

    // get name from get_name function
    let (name) = get_name(CALLER);
    // assert name is equal to our NAME variable
    assert NAME = name;

    // stop prank
    %{ stop_prank() %}

    return ();
}