// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DepositContract {
    // Token to be deposited
    IERC20 public token;

    // Owner of the contract
    address public owner;

    // Whitelist mapping, individual deposit limit and deposits tracker
    mapping (address => bool) public whitelist;
    mapping (address => uint256) public depositLimit;
    mapping (address => uint256) public deposits;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(IERC20 _token) {
        owner = msg.sender;
        token = _token;
    }

    function setToken(IERC20 _token) public onlyOwner {
        token = _token;
    }

    function addToWhitelist(address _address, uint256 _limit) public onlyOwner {
        whitelist[_address] = true;
        depositLimit[_address] = _limit;
    }

    function removeFromWhitelist(address _address) public onlyOwner {
        whitelist[_address] = false;
    }

    function deposit(uint256 _amount) public {
        require(whitelist[msg.sender], "You are not whitelisted");
        require(_amount <= depositLimit[msg.sender], "Deposit exceeds your limit");

        // Update deposits
        deposits[msg.sender] += _amount;

        // Ensure the tokens get transferred here
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
    }

    function getDepositedAmount(address _address) public view returns (uint256) {
        return deposits[_address];
    }
}
