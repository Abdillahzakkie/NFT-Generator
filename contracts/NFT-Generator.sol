// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "hardhat/console.sol";

contract NftGenerator is ERC721, ERC721URIStorage, ERC721Burnable, Ownable, ReentrancyGuard {    
    uint256 public Fee;

    string[] private _alphabets = [
        "A", "B", "C", "D", "E", 
        "F", "G", "H", "I", "J", 
        "K", "L", "M", "N", "O", 
        "P", "Q", "R", "S", "T", 
        "U", "V", "W", "X", "Y", 
        "Z"
    ];

    mapping(uint256 => string) public wordLists;
    mapping(string => bool) private _used;

    event Claimed(address indexed user, uint256 tokenId, uint256 timestamp);

    constructor() ERC721("NftGenerator", "N-GEN") { 
        Fee = 0.05 ether;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function claim(string memory _tokenURI) external payable nonReentrant {
        require(msg.value >= Fee, "NftGenerator: Claim fee must be equal to 0.05 ether");
        string memory _randomWord = random();

        require(!_used[_randomWord], "NftGenerator: TokenID has already been claimed");

        uint256 _tokenId = uint256(keccak256(abi.encode(_randomWord)));

        _used[_randomWord] = true;
        wordLists[_tokenId] = _randomWord;
        _safeMint(_msgSender(), _tokenId);
        _setTokenURI(_tokenId, _tokenURI);

        emit Claimed(_msgSender(), _tokenId, block.timestamp);
    }

    function random() public view returns(string memory _random) {
        uint256[4] memory _randomID;

        for(uint256 i = 0; i < 4; ++i) {
            uint256 _id = uint256(keccak256(abi.encodePacked(i, _msgSender(), block.timestamp))) % _alphabets.length;
            _randomID[i] = _id;
        }

        _random = string(
            abi.encodePacked(
                _alphabets[_randomID[0]], 
                " ", 
                _alphabets[_randomID[1]], 
                " ", 
                _alphabets[_randomID[2]], 
                " ", 
                _alphabets[_randomID[3]]
            )
        );
        console.log("Random string", _random);
        return _random;
    }

    function withdraw(uint256 _amount) external onlyOwner {
        (bool _success, ) = payable(owner()).call{value: _amount}("");
        require(_success, "NftGenerator: Ether withdrawal failed");
    }
}