// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    string name;


    function store(string memory file) public {
        name = file;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (string memory){
        return name;
    }

    function pharse() public returns (string memory){

        return encode(name);
    }

    function encode(string memory x) public returns (){
        x = "encoded";
        return;
    }
}