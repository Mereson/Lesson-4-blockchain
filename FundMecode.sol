// Get funds from users
// Witdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// 836,661
// 817,119

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUMUSD = 50 * 1e18;

    address [] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;
    // 21,508 - immutable
    // 23,644 - non immutable

    constructor(){
        i_owner = msg.sender;
    }
    
    /*
    PROBLEM
    Using the current ethereum price of $1401, minimum usd of 50 dollars should be 0.035 eth 
    but fund function can accept as low as 0.002 eth without throwing any error.
    */
    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUMUSD, "Didn't send enough");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
        // msg.sender and msg.value are global solidity variables
    }

    function withdraw() public onlyOwner {
        /* starting index; ending index; step amount */
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
        //withdraw the funds

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // msg.sender = address
        // // payable(msg.sender) = payable address

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        // // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance} ("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner {
        //require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }

    receive() external payable { fund(); }

    fallback() external payable { fund(); }
}
