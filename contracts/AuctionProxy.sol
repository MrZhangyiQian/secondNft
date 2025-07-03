// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AuctionProxy is ERC1967Proxy {
    constructor(address _logic, bytes memory _data)
        payable
        ERC1967Proxy(_logic, _data)
    {}
    
    // function implementation() public view returns (address) {
    //     return _implementation();
    // }
    
    // 接收 ETH 的回调函数
    receive() external payable {}
}