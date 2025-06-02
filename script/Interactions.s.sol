// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script, console} from "forge-std/Script.sol";
// import {Dev}


contract FundFundme is Script {

    uint256 constant SEND_VALUE = 0.1 ether; // 0.1 ETH


    function fundFundme(address mostRecentFundme) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentFundme)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract at address: %s with %s wei", mostRecentFundme, SEND_VALUE);
    }

    function run() external {
        vm.startBroadcast();
        vm.stopBroadcast();
    }
}
