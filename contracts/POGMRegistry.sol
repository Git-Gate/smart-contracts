// SPDX-License-Identifier: MIT
/// @title    Registry contract
/// @author   GitGate. Luca Di Domenico: twitter.com/luca_dd7

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./POGM.sol";

// import "hardhat/console.sol";

contract POGMRegistry is AccessControl {
    struct RepositoryRequirements {
        uint256 githubRepoId;
        address[] operators;
        uint256[] op;
        address[] blacklistedAddresses;
        address[] collections; //721 e 1155 address //address(0) for erc20
        uint256[] ids; // if erc20 id contains address -> address(uint...)
        uint256[] amounts;
        address soulBoundTokenContract;
        string tokenizedRepoName;
        string soulboundBaseURI;
    }

    mapping(uint256 => RepositoryRequirements) public database;

    bytes32 public NFT_FACTORY_ROLE = keccak256("NFT_FACTORY_ROLE");
    mapping(uint256 => address) public operator;

    uint256 public constant REPOSITORY_OWNER = 0;
    uint256 public constant BLACKLIST_ADMINISTRATOR = 1;
    uint256 public constant REQUIREMENTS_ADMINISTRATOR = 2;

    event RepositoryCreated(uint256 repoId, address owner);
    event SoulboundCreated(uint256 repoId, address soulboundContract);
    event BlacklistedAddressCreated(address _addr);
    event RequirementsChanged(uint256 repoId);
    event RoleChanged(uint256 repoId, address newOperator, uint256 role);

    error WrongSignerAddress(address);
    error RepositoryAlreadyExists(uint256);
    error RepositoryNotExists(uint256);
    error AccessDenied(uint256 githubRepoId, address wallet, uint256 role);
    error GeneralError(string message);

    modifier onlyIfRepoExists(uint256 _repoId) {
        if (getTokenizedRepoOwner(_repoId) == address(0))
            revert RepositoryNotExists(_repoId);
        _;
    }

    modifier onlyRepositoryRole(uint256 _githubRepoId, uint256 _role) {
        if (database[_githubRepoId].operators[_role] != _msgSender())
            revert AccessDenied(_githubRepoId, _msgSender(), _role);
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // TODO check if Metamask adds "\x19Ethereum Signed Message:\n32" or not in the message
    function _recoverSigner(bytes32 hash, bytes memory signature)
        private
        pure
        returns (address)
    {
        bytes32 messageDigest = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
        return ECDSA.recover(messageDigest, signature);
    }

    /**
     * @dev The Github repo owner should sign an off-chain
     * @dev The GitGate Admin wallet calls this method to create a tokenized repo
     * @param newRepo Struct containing all the tokenized repo requirements
     * @param hashedMessage Messagge containing "github repo id " + "_" + "repo owner address”
     * @param signature bytes signature
     */
    function createTokenizedRepo(
        RepositoryRequirements memory newRepo,
        bytes32 hashedMessage,
        bytes memory signature
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (
            newRepo.collections.length == 0 ||
            newRepo.collections.length != newRepo.ids.length ||
            newRepo.collections.length != newRepo.amounts.length
        )
            revert GeneralError(
                "You have to specify at least one between ERC20, ERC721 or ERC1155."
            );
        if (
            _recoverSigner(hashedMessage, signature) !=
            newRepo.operators[REPOSITORY_OWNER]
        ) revert WrongSignerAddress(newRepo.operators[REPOSITORY_OWNER]);

        if (getTokenizedRepoOwner(newRepo.githubRepoId) != address(0))
            revert RepositoryAlreadyExists(newRepo.githubRepoId);

        newRepo.soulBoundTokenContract = address(0);
        database[newRepo.githubRepoId] = newRepo;
        emit RepositoryCreated(
            newRepo.githubRepoId,
            newRepo.operators[REPOSITORY_OWNER]
        );
    }

    /**
     * @dev Retrieve the owner address of a tokenized repo
     * @param _tokenizedRepoId tokenized repo id
     * @return owner owner address of the tokenized repo or address 0 if repo does not exists
     */
    function getTokenizedRepoOwner(uint256 _tokenizedRepoId)
        public
        view
        returns (address owner)
    {
        if (database[_tokenizedRepoId].githubRepoId != 0)
            return database[_tokenizedRepoId].operators[REPOSITORY_OWNER];
        else return address(0);
    }

    /**
     * @dev This function is called by the Factory when a a new POGM contract is created to populate the _soulboundContract param for the tokenized repo
     * @param _repoId tokenized repo id
     * @param _soulboundContract POGM contract address
     */
    function setSoulboundAfterCreation(
        uint256 _repoId,
        address _soulboundContract
    ) external onlyRole(NFT_FACTORY_ROLE) {
        database[_repoId].soulBoundTokenContract = _soulboundContract;
        emit SoulboundCreated(_repoId, _soulboundContract);
    }

    /**
     * @dev This function can be called by the BLACKLIST_ADMINISTRATOR to blacklist new wallet addresses
     * @param _addresses Addresses to blacklist
     * @param _githubRepoId tokenized repo id
     */
    function setBlacklistedAddress(
        address[] memory _addresses,
        uint256 _githubRepoId
    )
        public
        onlyIfRepoExists(_githubRepoId)
        onlyRepositoryRole(_githubRepoId, BLACKLIST_ADMINISTRATOR)
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            database[_githubRepoId].blacklistedAddresses.push(_addresses[i]);
            uint256 _tokenId = POGMToken(
                database[_githubRepoId].soulBoundTokenContract
            ).POGMHolders(_addresses[i]);
            if (_tokenId > 0) {
                POGMToken(database[_githubRepoId].soulBoundTokenContract).burn(
                    _tokenId
                );
            }
            emit BlacklistedAddressCreated(_addresses[i]);
        }
    }

    /**
     * @dev This function is called by the REQUIREMENTS_ADMINISTRATOR to change requirements of the tokenized repo
     * @param _githubRepoId tokenized repo id
     * @param _collections ERC721/1155 Collection addresses. Pass address(0) for ERC20 tokens
     * @param _ids ERC721/1155 ids. Pass the address converted as uint for ERC20 tokens
     * @param _amounts ERC20/1155 amounts. Pass 1 for ERC721 tokens
     */
    function changeRequirements(
        uint256 _githubRepoId,
        address[] memory _collections,
        uint256[] memory _ids,
        uint256[] memory _amounts
    )
        public
        onlyIfRepoExists(_githubRepoId)
        onlyRepositoryRole(_githubRepoId, REQUIREMENTS_ADMINISTRATOR)
    {
        database[_githubRepoId].collections = _collections;
        database[_githubRepoId].ids = _ids;
        database[_githubRepoId].amounts = _amounts;
        emit RequirementsChanged(_githubRepoId);
    }

    /**
     * @dev This function can be called to check if a wallet address respects the tokenized repo requirements
     * @param repoId Tokenized repo id
     * @param user Wallet address to check
     * @return authorized true if the user address respects tokenized repo requirements
     */
    function checkUserRequirements(uint256 repoId, address user)
        public
        view
        returns (bool authorized)
    {
        uint256 ids721 = 0;
        bool is721checkRequired = false;
        for (uint256 i = 0; i < database[repoId].collections.length; i++) {
            if (database[repoId].collections[i] == address(0)) {
                if (
                    IERC20(address(uint160(database[repoId].ids[i]))).balanceOf(
                        user
                    ) < database[repoId].amounts[i]
                ) return authorized = false;
                continue;
            }
            if (
                IERC165(database[repoId].collections[i]).supportsInterface(
                    type(IERC721).interfaceId
                )
            ) {
                is721checkRequired = true;
                if (
                    IERC721(database[repoId].collections[i]).ownerOf(
                        database[repoId].ids[i]
                    ) == user
                ) ids721++;
            }
            if (
                IERC165(database[repoId].collections[i]).supportsInterface(
                    type(IERC1155).interfaceId
                )
            ) {
                if (
                    IERC1155(database[repoId].collections[i]).balanceOf(
                        user,
                        database[repoId].ids[i]
                    ) <= database[repoId].amounts[i]
                ) return authorized = false;
            }
        }
        if (is721checkRequired && ids721 == 0) return authorized = false;
        return authorized = true;
    }

    /**
     * @dev This function can be called to check if a wallet address respects the tokenized repo requirements
     * @param _githubRepoId Tokenized repo id
     * @param _op Operator to change
     * @param _newValue New operator address
     * @return oldValue Old operator address
     */
    function setOperator(
        uint256 _githubRepoId,
        uint256 _op,
        address _newValue
    ) external onlyIfRepoExists(_githubRepoId) returns (address oldValue) {
        if (operator[_op] != _msgSender())
            revert AccessDenied(_githubRepoId, _msgSender(), _op);
        return _setOperator(_githubRepoId, _op, _newValue);
    }

    // private function internally used by setOperator
    function _setOperator(
        uint256 _githubRepoId,
        uint256 _op,
        address _newValue
    ) private returns (address oldValue) {
        if (!(_op > 0 && _op < 3)) revert GeneralError("invalid op");
        oldValue = database[_githubRepoId].operators[_op];
        database[_githubRepoId].operators[_op] = _newValue;
        emit RoleChanged(_githubRepoId, _newValue, _op);
    }

    /**
     * @dev This function must be called by the Admin (GitGate) after contract deployment to set the Factory POGM address
     * @param _factory Factory contract address
     */
    function setFactory(address _factory)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(NFT_FACTORY_ROLE, _factory);
    }

    /**
     * @dev This function can be used to retrieve the tokenized repo name
     * @param repoId Tokenized repo id
     */
    function getTokenizedRepoName(uint256 repoId)
        public
        view
        onlyIfRepoExists(repoId)
        returns (string memory)
    {
        return database[repoId].tokenizedRepoName;
    }

    /**
     * @dev This function can be used to retrieve the base Uri of a tokenized repo
     * @param repoId Tokenized repo id
     */
    function getSoulBoundBaseURI(uint256 repoId)
        public
        view
        onlyIfRepoExists(repoId)
        returns (string memory)
    {
        return database[repoId].soulboundBaseURI;
    }

    /**
     * @dev This function can be used to retrieve the tokenized repo name
     * @param repoId Tokenized repo id
     */
    function getBlacklistedAddresses(uint256 repoId)
        public
        view
        onlyIfRepoExists(repoId)
        returns (address[] memory)
    {
        return database[repoId].blacklistedAddresses;
    }
}
