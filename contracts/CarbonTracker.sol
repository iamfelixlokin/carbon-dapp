// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CarbonToken.sol";

contract CarbonTracker {
    struct Record {
        uint256 kWh;
        uint256 greenRatio;
        uint256 reward;
        uint256 timestamp;
        address user;
    }

    CarbonToken public carbonToken;
    Record[] public records;

    event Recorded(address indexed user, uint256 kWh, uint256 greenRatio, uint256 reward, uint256 timestamp);

    constructor(address tokenAddress) {
        carbonToken = CarbonToken(tokenAddress);
    }

    function recordData(uint256 kWh, uint256 greenRatio) external {
        require(greenRatio <= 100, "Invalid ratio");

        // Quadratic reward model
        // reward = (kWh * (greenRatio^2) / 1000) * 1e18
        uint256 reward = (kWh * (greenRatio * greenRatio) / 1000) * 1e18;

        records.push(
            Record({
                kWh: kWh,
                greenRatio: greenRatio,
                reward: reward,
                timestamp: block.timestamp,
                user: msg.sender
            })
        );

        carbonToken.mint(msg.sender, reward);

        emit Recorded(msg.sender, kWh, greenRatio, reward, block.timestamp);
    }

    function getRecordCount() external view returns (uint256) {
        return records.length;
    }
}
