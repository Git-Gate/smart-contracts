// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyTokenERC20 is ERC20 {
    constructor(address _dest) ERC20("MyToken", "MTK") {
        _mint(_dest, 100000 * 10**decimals());
    }
}