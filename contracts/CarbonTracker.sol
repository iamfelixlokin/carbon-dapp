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
        // uint256 reward = (kWh * (greenRatio * greenRatio) / 1000) * 1e18;
        // uint256 reward = kWh * greenRatio * greenRatio / 10000;   // 不再乘 1e18
        // 舉例：10 kWh + 85% 綠電 → 10 × 85 × 85 ÷ 10000 = 72.25 顆（完美！）
    
        
        // 標準公式：10 kWh + 100% 綠電 = 100 顆 CARBON
        // kWh 是 1e9，greenRatio 是 0~100
        uint256 reward = (kWh * greenRatio * greenRatio * 1e18) / 1e5 / 1e9;

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
