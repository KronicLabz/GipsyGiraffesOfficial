// SPDX-License-Identifier: MIT
// Creator: Chiru Labs

pragma solidity 0.8.7;

/* Ammended: Dustin - KronicLabz
 ************************************************         
 *               GipsyGiraffes!                 *
 *    Gypsy Giraffes is a unique digital 3D     * 
 *   collectibles collection spending their     * 
 *     lives traveling around from place to     * 
 *    place in the blockchain world with the    *
 *   combination of unique characteristics,     *
 *     different traits in stylish outfits.     *
 *     They are fun-loving and like to eat      *
 *   everything vegetarian. Aren't they the     *
 *    cutest ? So, own a Gypsy Giraffe and      *
 *  spread some cuteness in this crypto world.  * 
 ************************************************/


import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract FlinchNFT is ERC721A, Ownable{
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 5555;
    uint256 public constant MAX_PUBLIC_MINT = 10;
    uint256 public constant PUBLIC_SALE_PRICE = .03 ether;

    string private  baseTokenUri;
    string public   placeholderTokenUri;

    //deploy smart contract, toggle WL, toggle WL when done, toggle publicSale 
    //2 days later toggle reveal
    bool public isRevealed;
    bool public publicSale;
    bool public pause;
    bool public teamMinted;

    mapping(address => uint256) public totalPublicMint;

    constructor() ERC721A("Gipsy Giraffes Official", "GGO"){

    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "");
        _;
    }

    function mint(uint256 _quantity) external payable callerIsUser{
        require(publicSale, "");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "");
        require((totalPublicMint[msg.sender] +_quantity) <= MAX_PUBLIC_MINT, "");
        require(msg.value >= (PUBLIC_SALE_PRICE * _quantity), "");

        totalPublicMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    function teamMint() external onlyOwner{
        require(!teamMinted, "");
        teamMinted = true;
        _safeMint(msg.sender, 50);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    //return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 trueId = tokenId + 1;

        if(!isRevealed){
            return placeholderTokenUri;
        }
        //string memory baseURI = _baseURI();
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, trueId.toString(), ".json")) : "";
    }

    // @dev walletOf() function shouldn't be called on-chain due to gas consumption
    function walletOf() external view returns(uint256[] memory){
        address _owner = msg.sender;
        uint256 numberOfOwnedNFT = balanceOf(_owner);
        uint256[] memory ownerIds = new uint256[](numberOfOwnedNFT);

        for(uint256 index = 0; index < numberOfOwnedNFT; index++){}

        return ownerIds;
    }
    function setTokenUri(string memory _baseTokenUri) external onlyOwner{
        baseTokenUri = _baseTokenUri;
    }
    function setPlaceHolderUri(string memory _placeholderTokenUri) external onlyOwner{
        placeholderTokenUri = _placeholderTokenUri;
    }

    function togglePause() external onlyOwner{
        pause = !pause;
    }

    function togglePublicSale() external onlyOwner{
        publicSale = !publicSale;
    }

    function toggleReveal() external onlyOwner{
        isRevealed = !isRevealed;
    }
      function withdraw() external onlyOwner{
        uint256 withdrawAmount_100 = address(this).balance * 100/100;
        payable(0x3587D4a1773D418B95f519c47dB972B939bC7611).transfer(withdrawAmount_100);
        payable(msg.sender).transfer(address(this).balance);
    }
}
