// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import  "./utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Zoot is ERC721, ERC721URIStorage, ERC721Burnable {
    using Counters for Counters.Counter;
    using Base64 for *;

    Counters.Counter private _totalSupply;
    string[] private _alphabets = [
        "A", "B", "C", "D", "E", 
        "F", "G", "H", "I", "J", 
        "K", "L", "M", "N", "O", 
        "P", "Q", "R", "S", "T", 
        "U", "V", "W", "X", "Y", 
        "Z"
    ];

    mapping(uint256 => string) public wordLists;
    mapping(string => uint256) public wordToID;

    constructor() ERC721("ZOOT", "ZOOT") {  }

    receive() external  payable {
        revert();
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        string[3] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: helvetica; font-size: 25px; }</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="base">';
        parts[1] = wordLists[tokenId];
        parts[2] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2])
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Zoot ',
                        wordLists[tokenId],
                        '", "description": "Zoot is the first random letter generator.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function mint() external {
        require(_totalSupply.current() <= 10_000, "Zoot: Maximum of 10,000 NFT minted");
        string memory _randomWord = random();
        require(wordToID[_randomWord] == 0, "Zoot: TokenID has already been claimed");

        uint256 _tokenId = _totalSupply.current();
        _totalSupply.increment();

        wordLists[_tokenId] = _randomWord;
        wordToID[_randomWord] = _tokenId;
        _safeMint(_msgSender(), _tokenId);
    }

    function random() internal view returns(string memory) {
        uint256[4] memory _randomID;

        for(uint256 i = 0; i < 4; ++i) 
            _randomID[i] = uint256(keccak256(abi.encodePacked(i, _msgSender(), block.timestamp))) % _alphabets.length;

        return string(
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
    }
}