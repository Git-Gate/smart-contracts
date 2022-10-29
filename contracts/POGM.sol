// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title    POGM (Proof Of Github Membership) token contract
/// @author   GitGate - developed by @francescocirulli

contract POGMToken is ERC721, Ownable, EIP712, ERC721Votes, ERC721Burnable {
    
    // defines the POGM token "name" parameter
    string public POGMName;
    // address of the POGMRegistry. POGMRegistry tracks all the tokenized repos and their requirements
    address public POGMRegistryAddress;
    // tokenized repo id previously created within the POGMRegistry
    uint256 public tokenizedRepoId;
    // POGM baseURI. All POGM ids of the same contract share the same baseUri
    string public baseUri;
    // stores the holder address of a specific POGM id
    mapping(address => uint256) public POGMHolders;

    // OpenZeppelin counters used to increment POGM ids
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    error Already_Has_POGM(uint256 POGMId);
    error Doesnt_Has_Requirements();

    // modifier used to check if the msg.sender is the POGMRegistry address
    modifier onlyRegistry() {
        require(msg.sender == POGMRegistryAddress);
        _;
    }

 /**
   * @dev Constructor
   * @dev The POGM Factory address deploys and initializes the POGM token contract
   * @param repoName The name of the tokenized repo. This string will is used to define the token "name" parameter aka POGMName
   * @param _tokenizedRepoId The id of the previoulsy created tokenized repo
   * @param _POGMRegistry Address of the POGMRegistry
   * @param _uri The uri of the POGM contract shared by all POGM ids of this contract
   */
    constructor(string memory repoName, uint256 _tokenizedRepoId, address _POGMRegistry, string memory _uri) 
    ERC721(POGMName = string(abi.encodePacked("ProofOfGithubMembership",repoName)), "POGM") EIP712(POGMName, "1") 
    {
        tokenizedRepoId = _tokenizedRepoId;
        POGMRegistryAddress = _POGMRegistry;
        baseUri = _uri;
    }

 /**
   * @dev this function can be used by an address to mint its POGM soulbound token. It must respect the tokenized repo requirements defined in the POGMRegistry
   * @param receiver The address receiver of the POGM token
   */
    function safeMint(address receiver) public {
        if (POGMHolders[receiver] != 0) revert Already_Has_POGM(POGMHolders[receiver]);
        //if (POGMRegistry.checkUserRequirements(receiver)) revert Doesnt_Has_Requirements();
    
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(receiver, tokenId);
    }

 /**
   * @dev This fuction is an override of the standard OpenZeppelin burn function to let the POGMRegistry address burning POGM ids held by blacklisted addresses
   * @dev The burn methdod can be called by the POGM id owner, an approved operator address or the POGMRegistry address
   * @param tokenId The POGM id to burn
   */
    function burn(uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId) || msg.sender == POGMRegistryAddress, "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }

    // The following function is an override required by Solidity
    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId);
    }

    // The following function is an override in order to make the POGM token an actual soulbound. Only transfers from and to address(0) are allowed
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721) {
      require(from == address(0) || to == address(0), "this token is a soulbound");
      super._beforeTokenTransfer(from, to, tokenId);
   }

    // The following function is an override in order to return the same baseUri string for all POGM ids of this contract
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }
}