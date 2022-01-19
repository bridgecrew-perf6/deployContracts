// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract CappedERCNFTOne is ERC721URIStorage, Ownable, AccessControl {
    using Counters for Counters.Counter;
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    Counters.Counter private _tokenIds;
    mapping (uint256 => string) private _tokenURIs;
    uint256 private _cap;
    mapping (address => bool) public Tokenholders;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 cap_
    )
        ERC721(name_, symbol_)
    {
        require(cap_ > 0, "CappedERCNFT#constructor: ZERO_CAP");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OPERATOR_ROLE, msg.sender);
        _cap = cap_;
    }

    /**
     * @dev Override supportInterface.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Restricted to members of the admin role.
     */
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CappedERCNFT#onlyAdmin: CALLER_NO_ADMIN_ROLE");
        _;
    }

    /**
     * @dev Restricted to members of the operator role.
     */
    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, msg.sender), "CappedERCNFT#onlyOperator: CALLER_NO_OPERATOR_ROLE");
        _;
    }

    /**
     * @dev Add an account to the operator role.
     * @param account address
     */
    function addOperator(
        address account
    )
        public
        onlyAdmin
    {
        require(!hasRole(OPERATOR_ROLE, account), "CappedERCNFT#addOperator: ALREADY_OERATOR_ROLE");
        grantRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Remove an account from the operator role.
     * @param account address
     */
    function removeOperator(
        address account
    )
        public
        onlyAdmin
    {
        require(hasRole(OPERATOR_ROLE, account), "CappedERCNFT#removeOperator: NO_OPERATOR_ROLE");
        revokeRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Check if an account is operator.
     * @param account address
     */
    function checkOperator(
        address account
    )
        public
        view
        returns (bool)
    {
        return hasRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Set a token URI.
     * @param tokenId uint256
     * @param tokenURI string
     */
    function setTokenURI(
        uint256 tokenId,
        string memory tokenURI
    )
        public
        virtual
        onlyOperator
    {
        require(_exists(tokenId), "CappedERCNFT#setTokenURI: NON_EXISTENT_TOKEN");
        _tokenURIs[tokenId] = tokenURI;
    }

    /**
     * @dev Get a token URI.
     * @param tokenId uint256
     */
    function getTokenURI(
        uint256 tokenId
    )
        public
        virtual
        view
        returns (string memory)
    {
        require(_exists(tokenId), "CappedERCNFT#getTokenURI: NON_EXISTENT_TOKEN");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Transfer ownership to a new address.
     * @dev Restricted to admin.
     * @param newOwner address
     */
    function transferOwnership(
        address newOwner
    )
        public
        override
        onlyAdmin
    {
        renounceRole(DEFAULT_ADMIN_ROLE, owner());
        _setupRole(DEFAULT_ADMIN_ROLE, newOwner);
        if (!hasRole(OPERATOR_ROLE, newOwner)) {
            _setupRole(OPERATOR_ROLE, newOwner);
        }
        super.transferOwnership(newOwner);
    }

    /**
     * @dev Mint a new token.
     * @param recipient address.
     * @param tokenURI string.
     */
    function mintNFT(
        address recipient,
        string memory tokenURI
    )
        public
        onlyOperator
    {
        _mint(recipient, tokenURI);
        Tokenholders[recipient]=true;
    }

    /**
     * @dev Mint multiple new tokens.
     * @param recipients array of recipient address.
     * @param tokenURIs array of token URI.
     */
    function mintBatchNFT(
        address[] memory recipients,
        string[] memory tokenURIs
    )
        public
        onlyOperator
    {
        require(recipients.length == tokenURIs.length, "CappedERCNFT#mintBatchNFT: PARAMS_LENGTH_MISMATCH");
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], tokenURIs[i]);
        }
    }

    /**
     * @dev Check if address has an NFT
     * @param addressClaiming is address claiming to have one.
     */
    function isTokenholder(
        address addressClaiming
    )
        public
        view returns (bool)
    {
        return Tokenholders[addressClaiming];
    }

    /**
     * @dev Mint a new token.
     * @param recipient recipient address.
     * @param tokenURI token URI of a new token.
     */
    function _mint(
        address recipient,
        string memory tokenURI
    )
        internal
        virtual
    {
        _tokenIds.increment();
        require(_tokenIds.current() <= _cap, "CappedERCNFT#_mint: CAP_OVERFLOW");
        uint256 newTokenId = _tokenIds.current();
        super._mint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
    }
}
