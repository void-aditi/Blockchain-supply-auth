// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SupplyChain 
{
    struct Product 
    {
        uint id;
        string name;
        string manufacturer;
        uint timestamp;
        address owner;
        string qrCodeHash; // Stores QR code identifier (e.g., IPFS hash)
    }

    mapping(uint => Product) public products; // Stores products by ID
    mapping(string => bool) private qrCodeExists; // Tracks used QR codes
    uint public productCount;

    event ProductAdded(uint id, string name, string manufacturer, address owner, string qrCodeHash);
    event OwnershipTransferred(uint id, address from, address to);

    // Function to check if a QR code is already used
    function isQrCodeUsed(string memory _qrCodeHash) public view returns (bool) 
    {
        return qrCodeExists[_qrCodeHash];
    }

    // Function to add a new product with a unique QR Code
    function addProduct(string memory _name, string memory _manufacturer, string memory _qrCodeHash) public 
    {
        require(!qrCodeExists[_qrCodeHash], "QR Code already used"); // Prevent duplicate QR codes
        require(bytes(_qrCodeHash).length > 0, "QR Code cannot be empty"); // Ensure QR code hash is not empty

        productCount++;
        products[productCount] = Product(productCount, _name, _manufacturer, block.timestamp, msg.sender, _qrCodeHash);
        qrCodeExists[_qrCodeHash] = true; // Mark this QR code as used

        emit ProductAdded(productCount, _name, _manufacturer, msg.sender, _qrCodeHash);
    }

    // Function to transfer product ownership
    function transferOwnership(uint _id, address _newOwner) public 
    {
        require(products[_id].owner != address(0), "Product does not exist"); // Ensure product exists
        require(_newOwner != address(0), "Invalid new owner address"); // Prevent transfers to zero address
        require(products[_id].owner == msg.sender, "You are not the owner"); // Only owner can transfer
        require(msg.sender != _newOwner, "Cannot transfer to yourself"); // Prevent self-transfer

        products[_id].owner = _newOwner;
        emit OwnershipTransferred(_id, msg.sender, _newOwner);
    }

    // Function to retrieve product details
    function getProductDetails(uint _id) public view returns (string memory, string memory, uint, address, string memory) 
    {
        Product memory product = products[_id];
        require(product.owner != address(0), "Product does not exist"); // Ensure product exists

        return (product.name, product.manufacturer, product.timestamp, product.owner, product.qrCodeHash);
    }
}
