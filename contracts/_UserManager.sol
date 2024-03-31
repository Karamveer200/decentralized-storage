// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract UserManager {
    constructor() {}

    receive() external payable {}

    struct User {
        bool registered;
        uint104 tier;
        // In GB
        uint256 storageAllocated;
        uint256 storageUsed;
        uint256 subscriptionEndTime;
    }

    struct UserPayments {
        uint256 amountPaid;
        uint256 paidTime;
    }

    uint104 constant FREE_TIER = 0;
    uint104 constant ADVANCED_TIER = 1;

    mapping(address => User) internal users;

    // Subscription fees and rates
    uint256 constant advancedFee = 1 gwei; // Placeholder, set based on current ETH price

    uint256 constant advancedStorage = 100; // 100GB for advanced users
    uint256 constant freeStorage = 1; // 100GB for free users

    address[] userAddresses;

    // Events
    event UserRegistered(address user, uint104 tier);
    event SubscriptionChanged(address user, uint104 newTier);

    // Function to register a new user
    function registerUser(address _userAddress) public {
        require(!users[_userAddress].registered, "User already registered.");

        users[_userAddress] = User(
            true,
            FREE_TIER,
            GBToBytes(freeStorage),
            0,
            0
        );

        emit UserRegistered(_userAddress, FREE_TIER);
    }

    // Payable function to upgrade subscription
    function upgradeSubscription(address _userAddress) public payable {
        require(users[_userAddress].registered, "User not registered.");

        console.log("Amount recieved - ", advancedFee, msg.value);

        uint256 moneyValue = msg.value;

        require(
            moneyValue == advancedFee,
            "Incorrect payment for Advanced tier."
        );
        users[_userAddress].tier = ADVANCED_TIER;
        users[_userAddress].storageAllocated = GBToBytes(advancedStorage);

        // 30 days for a month, in seconds
        users[_userAddress].subscriptionEndTime = block.timestamp + 30 days;

        emit SubscriptionChanged(_userAddress, ADVANCED_TIER);
    }

    function GBToBytes(uint256 gb) public pure returns (uint256) {
        // 1 GB = 1e9 * 1024 bytes
        return gb * 1e9 * 1024;
    }

    function getUserContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to get user tier
    function getUserTier(address _userAddress) public view returns (uint104) {
        require(users[_userAddress].registered, "User not registered.");
        return users[_userAddress].tier;
    }

    function getAdvancedTier() public pure returns (uint104) {
        return ADVANCED_TIER;
    }

    function getFreeStorageAmount() public pure returns (uint256) {
        return freeStorage;
    }

    // Function to get user storage usage
    function getUserStorageUsed(address _userAddress)
        public
        view
        returns (uint256)
    {
        require(users[_userAddress].registered, "User not registered.");
        return users[_userAddress].storageUsed;
    }

    function getUserStorageallocated(address user)
        public
        view
        returns (uint256)
    {
        require(users[user].registered, "User not registered.");
        return users[user].storageAllocated;
    }

    // Function to transfer Ether from this contract to an address
    function transferEther(address payable _to, uint256 _amount) public {
        require(
            address(this).balance >= _amount,
            "Insufficient balance to transfer"
        );

        // Recommended way to send Ether as of Solidity 0.6.x and later
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to add an address if it doesn't already exist in the array
    function addUserAddresses(address newUser) public {
        if (!addressExists(newUser)) {
            userAddresses.push(newUser);
        }
    }

    // Private function to check if an address exists in the array
    function addressExists(address userAddress) private view returns (bool) {
        for (uint256 i = 0; i < userAddresses.length; i++) {
            if (userAddresses[i] == userAddress) {
                return true;
            }
        }
        return false;
    }
}
