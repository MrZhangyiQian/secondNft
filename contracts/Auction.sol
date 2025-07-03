// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/IAuction.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// 改为这个
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Auction is IAuction, Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Bid {
        address bidder;
        uint256 amount;
        uint256 timestamp;
        uint256 usdValue; // 美元价值
    }
    
    struct AuctionItem {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        uint256 highestBidUsd;
        bool ended;
    }
    
    uint256 public constant AUCTION_DURATION = 3600; // 1 hour
    AuctionItem public auction;
    mapping(address => Bid[]) public bids;
    
    AggregatorV3Interface internal ethPriceFeed;
    mapping(address => AggregatorV3Interface) internal erc20PriceFeeds;
    
    event AuctionCreated(
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 startTime,
        uint256 endTime
    );
    
    event BidPlaced(
        address indexed bidder,
        uint256 amount,
        uint256 usdValue
    );
    
    event AuctionEnded(
        address indexed winner,
        uint256 amount,
        uint256 tokenId
    );
    
    event AuctionCancelled();

    event Upgraded(address indexed implementation);

function initialize(
        address _seller,
        address _nftContract,
        uint256 _tokenId,
        uint256 _duration,
        address _priceFeed
    ) public payable override initializer {
        __Ownable_init(_seller);
        __UUPSUpgradeable_init();

        ethPriceFeed = AggregatorV3Interface(_priceFeed);

        auction = AuctionItem({
            seller: _seller,
            nftContract: _nftContract,
            tokenId: _tokenId,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            highestBidder: address(0),
            highestBid: 0,
            highestBidUsd: 0,
            ended: false
        });

        emit AuctionCreated(_seller, _nftContract, _tokenId, block.timestamp, block.timestamp + _duration);
    }

    
    function placeBid() external payable {
        require(block.timestamp <= auction.endTime, "Auction ended");
        require(msg.value > auction.highestBid, "Bid too low");
        require(msg.sender != auction.seller, "Seller cannot bid");
        
        // 获取ETH/USD价格
        (,int256 price,,,) = ethPriceFeed.latestRoundData();
        uint256 usdValue = (msg.value * uint256(price)) / 1e18;
        
        // 更新最高出价
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        auction.highestBidUsd = usdValue;
        
        // 保存出价记录
        bids[msg.sender].push(Bid({
            bidder: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp,
            usdValue: usdValue
        }));
        
        emit BidPlaced(msg.sender, msg.value, usdValue);
    }
    
    function endAuction() external {
        require(block.timestamp >= auction.endTime, "Auction not ended");
        require(!auction.ended, "Auction already ended");
        require(msg.sender == auction.seller || msg.sender == owner(), "Not authorized");
        
        auction.ended = true;
        
        if (auction.highestBidder != address(0)) {
            // 转移NFT给出价最高者
            IERC721(auction.nftContract).transferFrom(
                address(this),
                auction.highestBidder,
                auction.tokenId
            );
            
            // 转移资金给卖家
            payable(auction.seller).transfer(auction.highestBid);
            
            emit AuctionEnded(
                auction.highestBidder,
                auction.highestBid,
                auction.tokenId
            );
        } else {
            // 如果没有出价，将NFT返还给卖家
            IERC721(auction.nftContract).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId
            );
            
            emit AuctionCancelled();
        }
    }
    
    function getEthUsdPrice() public view returns (uint256) {
        (,int256 price,,,) = ethPriceFeed.latestRoundData();
        return uint256(price);
    }
    
    function getBidUsdValue(uint256 ethAmount) public view returns (uint256) {
        (,int256 price,,,) = ethPriceFeed.latestRoundData();
        return (ethAmount * uint256(price)) / 1e18;
    }
    
    // UUPS升级授权
    function _authorizeUpgrade(address) internal virtual override onlyOwner {}
    
    // 为了安全禁止在拍卖结束前转移NFT
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function bindNFT(address _nftContract, uint256 _tokenId) external payable {
      require(auction.nftContract == address(0), "NFT already bound");
      require(IERC721(_nftContract).ownerOf(_tokenId) == address(this), "NFT not in contract");

      auction.nftContract = _nftContract;
      auction.tokenId = _tokenId;
      auction.seller = msg.sender;
      auction.startTime = block.timestamp;
      auction.endTime = block.timestamp + AUCTION_DURATION; // 可以从常量中获取
   }

   function adminUpgradeTo(address newImplementation) external onlyOwner {
    // 100% 可靠的升级实现
        _upgradeTo(newImplementation);
        _authorizeUpgrade(newImplementation);
   }

   function _upgradeTo(address newImplementation) internal {
    // 直接设置实现地址
    assembly {
        sstore(
            0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
            newImplementation
        )
    }
    
    // 触发升级事件
    emit Upgraded(newImplementation);
}
    
}