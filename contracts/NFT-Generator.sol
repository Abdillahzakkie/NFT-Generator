// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./utils/Base64.sol";
import "./utils/Names.sol";
import "hardhat/console.sol";

contract NameGenerator is ERC721, ERC721URIStorage, Names, Ownable {
    using Counters for Counters.Counter;
    using Base64 for *;
    using Strings for uint256;

    Counters.Counter public totalSupply;
    uint256 public Fee;

    mapping(uint256 => string) public names;
    mapping(string => uint256) public nameToID;

    constructor() ERC721("Name-Generator", "N-GEN") {
        Fee = 0.05 ether;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        string[5] memory parts;

        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: helvetica; font-size: 20px; }</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="base">';
        parts[1] = names[tokenId];
        parts[2] = '</text><text x="10" y="40" class="base">';
        parts[3] = tokenId.toString();
        parts[4] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2])
        );

        output = string(
            abi.encodePacked(output, parts[3], parts[4])
        );


        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "NameGenerator ',
                        names[tokenId],
                        '", "description": "NameGenerator is the first random name generator.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );

        output = string(abi.encodePacked("data:application/json;base64,", json));
        console.log("Name %s", output);
        return output;
    }

    function mint() external payable {
        require(msg.value >= Fee, "NftGenerator: mint fee must be equal to 0.05 ether");
        string memory _randomWord = random();
        require(nameToID[_randomWord] == 0, "NftGenerator: Name has already been issued");

        uint256 _tokenId = totalSupply.current();
        totalSupply.increment();

        nameToID[_randomWord] = _tokenId;
        names[_tokenId] = _randomWord;
        _safeMint(_msgSender(), _tokenId);
    }

    function random() public view returns(string memory _random) {
        uint256[2] memory _randomID;
        string[] memory _nameLists = nameLists();
        
        for(uint256 i = 0; i < 2; ++i) 
            _randomID[i] = uint256(keccak256(abi.encodePacked(i, _msgSender(), block.timestamp))) % _nameLists.length;

        _random = string(
            abi.encodePacked(
                _nameLists[_randomID[0]], 
                " ", 
                _nameLists[_randomID[1]]
            )
        );
        console.log("Random name generated: %s", _random);
        return _random;
    }

    function withdraw(uint256 _amount) external onlyOwner {
        (bool _success, ) = payable(owner()).call{value: _amount}("");
        require(_success, "NftGenerator: Ether withdrawal failed");
    }
}