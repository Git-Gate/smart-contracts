// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyTokenERC721 is ERC721 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(address _dest) ERC721("MyToken", "MTK") {
        for(uint i = 0; i < 100; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(_dest, tokenId);
        }
    }
}