// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyTokenERC1155 is ERC1155 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(address _dest) ERC1155("MyToken") {
        for(uint i = 0; i < 10; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _mint(_dest, tokenId, 10, "");
        }
    }
}