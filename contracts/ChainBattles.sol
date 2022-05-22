// SPDX-License-Identifier: MIT
//0x696e1aF3b2750d6CbEFa5Afe17150253aD461e73
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    struct NFTData{
        uint level;
        uint speed;
        uint strength;
        uint life;
    }
    mapping(uint256 => NFTData) public tokenIdToLevels;

    constructor() ERC721 ("Chain Battles", "CBTLS"){
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % 100;
    }
    
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId] = NFTData(random(),random(),random(),random());
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function generateCharacter(uint256 tokenId) public view returns(string memory){
    NFTData memory level = getLevels(tokenId);
    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",level.level.toString(),'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",level.speed.toString(),'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",level.strength.toString(),'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",level.life.toString(),'</text>',
        '</svg>'
    );
    return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        )    
    );  
    }

    function getLevels(uint256 tokenId) public view returns (NFTData memory) {
    NFTData memory levels = tokenIdToLevels[tokenId];
    return levels;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Chain Battles #', tokenId.toString(), '",',
            '"description": "Battles on chain",',
            '"image": "', generateCharacter(tokenId), '"',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
    }

     function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        NFTData storage currentLevel = tokenIdToLevels[tokenId];
        tokenIdToLevels[tokenId].level = currentLevel.level + 1;
        tokenIdToLevels[tokenId].strength = currentLevel.strength + 1;
        tokenIdToLevels[tokenId].speed = currentLevel.speed + 1;
        tokenIdToLevels[tokenId].life = currentLevel.life + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}