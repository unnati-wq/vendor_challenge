pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, address buyer);
  uint256 public constant tokensPerEth = 100;
  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable returns (uint256 tokenAmount){
    // checks if sender has enough ETH to buy tokens
    require(msg.value > 0, "Please send ETH to buy tokens.");
    uint256 buyAmount = msg.value * tokensPerEth;
    // checks if vendor has enough tokens
    require(yourToken.balanceOf(address(this)) >= buyAmount, "Vendor does not have enough tokens");
    // send tokens to buyer
    (bool sent) = yourToken.transfer(msg.sender, buyAmount);
    require(sent, "Failed to transfer token to user");
    // emit buy event
    emit BuyTokens(msg.sender, msg.value, buyAmount);
    return buyAmount;
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner does not have balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 sellAmount) public {
    // Check that the requested amount of tokens to sell is more than 0
    require(sellAmount > 0, "Specify an amount of token greater than zero");

    // Check that the user's token balance is enough to do the swap
    require(yourToken.balanceOf(msg.sender) >= sellAmount, "Your balance is lower than the amount of tokens you want to sell");
    uint256 amount = yourToken.allowance(msg.sender, address(this));
    require(sellAmount <= amount, "There is no approval to sell this number of tokens");
    // Check that the Vendor's balance is enough to do the swap
    require(address(this).balance >= sellAmount / tokensPerEth, "Vendor has not enough funds to accept the sell request");
    // transfer tokens from seller to the vendor
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), sellAmount);
    require(sent, "Failed to transfer tokens from user to vendor");

    // transfer eth to seller from vendor
    (sent,) = msg.sender.call{value: sellAmount / tokensPerEth}("");
    require(sent, "Failed to send ETH to the user");
    // emit sell tokens event
    emit SellTokens(msg.sender, sellAmount, address(this));
  }

}
