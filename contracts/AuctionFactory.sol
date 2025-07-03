// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Auction.sol";
import "./AuctionProxy.sol";

contract AuctionFactory {
    address[] public auctions;
    mapping(address => bool) public isAuction;
    
    event AuctionCreated(address indexed auction, address indexed seller, address indexed nftContract);
    
    function createAuction(
       address _nftContract,
       uint256 _tokenId,
       uint256 _duration,
       address _priceFeed
    ) external returns (address) {
       Auction auctionLogic = new Auction();
        AuctionProxy auctionProxy = new AuctionProxy(address(auctionLogic), "");

        emit AuctionCreated(address(auctionProxy), msg.sender, _nftContract);
        return address(auctionProxy);
}
    
    function getAllAuctions() external view returns (address[] memory) {
        return auctions;
    }
}