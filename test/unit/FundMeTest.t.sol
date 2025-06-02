// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // We can use the same contract as the one we want to test!
    // This is a test contract, not a library.
    // We can use the same contract as the one we want to test!
    // This is a test contract, not a library.

    FundMe public fundMe;
    DeployFundMe public deployedFundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 0.1 ETH
    uint256 constant STARTING_BALANCE = 10 ether; // 10 ETH
    uint256 constant GAS_PRICE = 1; // 1 wei, for testing purposes

    function setUp() external {
        deployedFundMe = new DeployFundMe();
        fundMe = deployedFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    // function testOwner() view public {
    //     assertEq(fundMe.i_owner(), address(this));
    // }

    function testPriceFeedVersion() view public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4); // Assuming the version is 4, change it if needed
    }

    function testFundFailsWithoutEnoughEth() public {
        uint256 sendValue = 1; // 1 ETH is less than the minimum USD value
        vm.expectRevert("You need to spend more ETH!");
        // Act
        fundMe.fund{value: sendValue}();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    } 
    function test_FundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundersToArray() public  funded{
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert("FundMe__NotOwner()");
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawalWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundeMeBalance = fundMe.getBalance();

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundeMeBalance = fundMe.getBalance();

        assertEq(endingFundeMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundeMeBalance
        );
    }

    function testWithdrawalFromMultipleFunders() public funded {
        // Arrange
        uint256 numberOfFunders = 10;
        uint160 startFunderIndex = 1; 
        for (uint160 i = startFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); 
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundeMeBalance = fundMe.getBalance();

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundeMeBalance = fundMe.getBalance();

        assertEq(endingFundeMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundeMeBalance
        );
    }

}