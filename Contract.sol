// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract QR8NFT is ERC721A, Ownable {
    uint256 MAX_MINTS = 3;
    uint256 MINTS_number;
    uint256 MAX_SUPPLY = 5000;
    uint256 public mintRate = 0.3 ether;
    bool public _isSaleActive = false;
    bool public _revealed = false;
    bool public outputBool = false;
    bool public convertNum = false;
    string[] public outputList;
    string public baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    struct User{
        string Name;
        address UserAddress;
    }
    address [] public userList;
    mapping(address => User) public users;
    event LogUserName(address _address, string _setName);

    constructor(string memory initBaseURI, string memory initNotRevealedUri) ERC721A("QR8NFT", "QR8NFT") {
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
    }

    function mint(uint256 quantity) public payable {
        require(_isSaleActive, "Sale must be active to mint");
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        require(quantity + _numberMinted(msg.sender) <= MAX_MINTS, "Exceeded the limit");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Not enough tokens left");
        require(msg.value >= (mintRate * quantity), "Not enough ether sent");
        _safeMint(msg.sender, quantity);
    }

    function strToUint(string memory _str) public pure returns(uint256 res, bool err) {
        
        for (uint256 i = 0; i < bytes(_str).length; i++) {
            if ((uint8(bytes(_str)[i]) - 48) < 0 || (uint8(bytes(_str)[i]) - 48) > 9) {
                return (0, false);
            }
            res += (uint8(bytes(_str)[i]) - 48) * 10**(bytes(_str).length - i - 1);
        }
        return (res, true);
    }

    function uint2str(uint256 _i) internal  pure  returns (string memory str)
    {
        if (_i == 0){ 
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0)
        {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0)
        {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        //mintRate = 0.03 ether;
        //if (getName()=="MAN") mintRate = 0.02 ether;
        if (_revealed == false) {
            return notRevealedUri;
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(baseURI, uint2str(tokenId), baseExtension));
        //return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId)) : '';  
    }

    function SingleMint() external 
    {
        mint(1);
    }
    function DoubleMint() external 
    {
        mint(2);
    }
    function TripleMint() external 
    {
        mint(3);
    }

    function setName(string memory _setName) external 
    {
        appendUserName(msg.sender,_setName) ;
        (MINTS_number, convertNum)= strToUint(_setName);
        if (convertNum) {mint(MINTS_number);} 
    }
    function appendUserName(address _address, string memory _setName) internal {
        userList.push(_address);
        users[_address].Name = _setName;
    }
    function getCount() public view returns(uint count) {
        return userList.length;
    }
    function UserLoop(string memory _name) public returns(bool){
        // WARN: This unbounded for loop check duplicate
        outputBool = false;
        for (uint i=0; i<userList.length; i++) {
            //emit LogUserName(userList[i], users[userList[i]].Name);
            outputBool = validate(_name, users[userList[i]].Name);
            if (outputBool) {break;}
        }
        return outputBool;
    }
    function getNameByIndex(uint index) public returns (string memory){
        getRow();
        return outputList[index];
    }
    function getRow() internal {    
        for (uint i=0; i<userList.length; i++) {
           outputList[i] = users[userList[i]].Name;
        }
    }
    function validate(string memory _name1, string memory _name2) public pure returns(bool) {
        if (keccak256(abi.encodePacked(_name1)) == keccak256(abi.encodePacked(_name2))) 
            return true;
        else return false;
    }
    function read_Stored_Name(address _address) view internal returns(string memory){
        return users[_address].Name;
    }
    function getName() public view returns (string memory)
    {
        return read_Stored_Name(msg.sender);
    }

    //only owner
    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setMintRate(uint256 _mintRate) public onlyOwner {
        mintRate = _mintRate;
    }

    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }
}
