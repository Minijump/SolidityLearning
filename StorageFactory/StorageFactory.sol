// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {SimpleStorage} from "./SimpleStorage.sol";

contract StorageFactory {

    SimpleStorage public simpleStorage;
    SimpleStorage[] public listOfSimpleStorage;

    function createSimpleStorageContract() public{
        SimpleStorage myNewSimpleStorage = new SimpleStorage();
        simpleStorage = myNewSimpleStorage;
        listOfSimpleStorage.push(myNewSimpleStorage);
    }

    function sfStore(uint256 _simpleStorageIndex, uint256 _newSimpleStorageNumber) public {
        SimpleStorage mySimpleStorage = listOfSimpleStorage[_simpleStorageIndex];
        mySimpleStorage.store(_newSimpleStorageNumber);
    }

    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256) {
        SimpleStorage mySimpleStorage = listOfSimpleStorage[_simpleStorageIndex];
        return mySimpleStorage.retrieve_var();
    }
}
