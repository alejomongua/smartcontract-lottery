// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract Lottery {
    uint256 public entrance;
    address public owner;
    AggregatorV3Interface public priceFeed;

    address payable[] public players;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _priceFeed, uint8 _entranceUsd) public {
        owner = msg.sender;
        entrance = _entranceUsd * 10**18;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function enter() public payable {
        require(
            getConversionRate(msg.value) >= entrance,
            "Not enough ETH! to enter"
        );
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 price = getPrice();
        uint256 precision = 10**18;
        return (entrance * precision) / price;
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function startLottery() public onlyOwner {}

    function endLottery() public onlyOwner {}
}
