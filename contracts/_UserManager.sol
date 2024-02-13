// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract UserManager {
    struct User {
        bool registered;
        Tier tier;
        // In GB
        uint256 storageAllocated;
        uint256 storageUsed;
        uint256 subscriptionEndTime;
    }

    enum Tier {
        Free,
        Advanced,
        PayAsYouGo
    }

    mapping(address => User) public users;

    // Subscription fees and rates
    uint256 constant advancedFee = 0.00001 gwei; // Placeholder, set based on current ETH price
    uint256 constant payAsYouGoRate = 0.0000004 gwei; // Per GB, placeholder

    uint256 constant advancedStorage = 100; // 100GB for advanced users
    uint256 constant freeStorage = 1; // 100GB for advanced users

    // Events
    event UserRegistered(address user, Tier tier);
    event SubscriptionChanged(address user, Tier newTier);

    constructor() {}

    receive() external payable {}

    // Function to register a new user
    function registerUser() public {
        require(!users[msg.sender].registered, "User already registered.");
        users[msg.sender] = User(true, Tier.Free, GBToBytes(freeStorage), 0, 0);

        emit UserRegistered(msg.sender, Tier.Free);
    }

    // Payable function to upgrade subscription
    function upgradeSubscription(Tier newTier) public payable {
        require(users[msg.sender].registered, "User not registered.");
        require(newTier != Tier.Free, "Cannot upgrade to Free tier.");

        if (newTier == Tier.Advanced) {
            uint moneyValue = convertToGwei(msg.value);
            console.log("valuesadashd - ", advancedFee, moneyValue);

            require(
                moneyValue == advancedFee,
                "Incorrect payment for Advanced tier."
            );
            users[msg.sender].tier = Tier.Advanced;
            users[msg.sender].storageAllocated = GBToBytes(advancedStorage);

            // 30 days for a month, in seconds
            users[msg.sender].subscriptionEndTime = block.timestamp + 30 days;
        } else if (newTier == Tier.PayAsYouGo) {
            // No upfront fee, but need to allocate initial storage or handle billing differently
            require(
                users[msg.sender].tier != Tier.PayAsYouGo,
                "Already on PayAsYouGo tier."
            );
            users[msg.sender].tier = Tier.PayAsYouGo;

            // Initial storage allocation can be handled based on payment
            uint256 initialStorage = msg.value / payAsYouGoRate;
            users[msg.sender].storageAllocated += initialStorage;
        }

        emit SubscriptionChanged(msg.sender, newTier);
    }

    // Add more storage for PayAsYouGo users
    function addStorage() public payable {
        require(users[msg.sender].registered, "User not registered.");
        require(
            users[msg.sender].tier == Tier.PayAsYouGo,
            "Not on PayAsYouGo tier."
        );
        uint256 additionalStorage = msg.value / payAsYouGoRate;
        users[msg.sender].storageAllocated += additionalStorage;
    }

    // Function to check a user's subscription and storage
    function getUser(address user)
        public
        view
        returns (
            User memory
        )
    {
        require(users[user].registered, "User not registered.");
        return (
            users[user]
        );
    }

    function GBToBytes(uint256 gb) public pure returns (uint256) {
        // 1 GB = 1e9 * 1024 bytes
        return gb * 1e9 * 1024;
    }

    function getUserBalance() external view returns (uint256) {
        return address(this).balance;
    }

      function convertToGwei(uint value) public payable returns (uint) {
        return value / 1e9;
    }

        // Function to get user tier
    function getUserTier() public view returns (Tier) {
        require(users[msg.sender].registered, "User not registered.");
        return users[msg.sender].tier;
    }

    // Function to get user storage usage
    function getUserStorageUsed() public view returns (uint256) {
        require(users[msg.sender].registered, "User not registered.");
        return users[msg.sender].storageUsed;
    }

}
