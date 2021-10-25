// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is VRFConsumerBase, Ownable {
    AggregatorV3Interface public priceFeed;
    // variable of new enum type
    LOTTERY_STATE public lotteryState;
    uint256 public clFee;
    bytes32 clKeyhash;
    uint256 public randomness;

    enum LOTTERY_STATE {
        OPEN, // 0
        CLOSED, // 1
        CALCULATING_WINNER // 2
    }
    uint256 public entrance;
    address payable lastWinner;
    uint256 winnerIndex;
    address payable[] public players;

    constructor(
        address _priceFeed,
        uint8 _entranceUsd,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        clFee = _fee;
        clKeyhash = _keyhash;
        entrance = _entranceUsd * 10**18;
        priceFeed = AggregatorV3Interface(_priceFeed);
        lotteryState = LOTTERY_STATE.CLOSED;
        players = new address payable[](0);
    }

    function enter() public payable {
        require(
            getConversionRate(msg.value) >= entrance,
            "Not enough ETH! to enter"
        );
        players.push(payable(msg.sender));
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

    function startLottery() public onlyOwner {
        require(
            lotteryState == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery yet"
        );
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        require(
            lotteryState == LOTTERY_STATE.OPEN,
            "Can't end this lottery yet"
        );
        lotteryState = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 clRequestId = requestRandomness(clKeyhash, clFee);
    }

    // This function is a callback, gets called by chainlink when
    // it has the random number
    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(
            lotteryState == LOTTERY_STATE.CALCULATING_WINNER,
            "You aren't there yet"
        );
        require(_randomness > 0, "Random number not found");
        winnerIndex = _randomness % players.length;
        lastWinner = players[winnerIndex];
        lastWinner.transfer(address(this).balance);
        // Reset
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}
