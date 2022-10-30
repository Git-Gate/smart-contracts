// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./POGM.sol";
import "./POGMRegistry.sol";
import "hardhat/console.sol";

/// @title    POGM (Proof Of Github Membership) token Factory contract
/// @author   GitGate - developed by @francescocirulli

contract POGMFactory {
    // address of the POGMRegistry. POGMRegistry tracks all the tokenized repos and their requirements
    address public POGMRegistryAddress;
    // mapping storing the soulbound POGM address for a specific tokenized repo
    mapping(uint256 => address) public POGMs;

    event newPOGMCollection(address POGMAddress, uint256 tokenizedRepo);

    error Already_Created(address POGMAddress);
    error Not_Existing_Repo();

    /**
     * @dev Constructor
     * @dev The GitGate wallet should deploy and initialize the POGMFactory
     * @param _POGMRegistry The address of the previoulsy deployed POGMRegistry
     */
    constructor(address _POGMRegistry) {
        POGMRegistryAddress = _POGMRegistry;
    }

    /**
     * @dev the owner of a tokenized repo can use this function to create the soulbound POGM contract
     * @param tokenizedRepoId The id of the previoulsy created tokenized repo
     * @return POGMAddress The address of the newly deployed POGM token
     */
    function createPOGMToken(uint256 tokenizedRepoId)
        external
        returns (address)
    {
        if (POGMs[tokenizedRepoId] != address(0))
            revert Already_Created(POGMs[tokenizedRepoId]);

        POGMRegistry instanceRegistry = POGMRegistry(POGMRegistryAddress);
        address repoOwner = instanceRegistry.getTokenizedRepoOwner(
            tokenizedRepoId
        );
        string memory tokenizedRepoName = instanceRegistry.getTokenizedRepoName(
            tokenizedRepoId
        );
        string memory POGMBaseUri = instanceRegistry.getSoulBoundBaseURI(
            tokenizedRepoId
        );

        if (repoOwner == address(0)) revert Not_Existing_Repo();

        address POGMAddress = address(
            new POGMToken(
                tokenizedRepoName,
                tokenizedRepoId,
                POGMRegistryAddress,
                POGMBaseUri
            )
        );

        _setTokenizedRepoPOGMAddress(tokenizedRepoId, POGMAddress);
        POGMs[tokenizedRepoId] = POGMAddress;

        emit newPOGMCollection(POGMAddress, tokenizedRepoId);

        return POGMAddress;
    }

    /**
     * @dev this internal function is used to set the POGM address within the tokenized repo of the POGMRegistry
     * @param tokenizedRepoId The id of the previoulsy created tokenized repo
     * @param POGMAddress The address of the created POGM token
     */
    function _setTokenizedRepoPOGMAddress(
        uint256 tokenizedRepoId,
        address POGMAddress
    ) internal {
        POGMRegistry instanceRegistry = POGMRegistry(POGMRegistryAddress);
        instanceRegistry.setSoulboundAfterCreation(
            tokenizedRepoId,
            POGMAddress
        );
    }
}
