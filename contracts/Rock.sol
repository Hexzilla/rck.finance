/**
 *Submitted for verification at BscScan.com on 2021-08-04
*/

pragma solidity >=0.6.12;

import './IBEP20.sol';
import './SafeMath.sol';
import './SafeBEP20.sol';
import './Address.sol';

import
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor  () public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, 'EnumerableSet: index out of bounds');
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

contract RockPreSale is ReentrancyGuard, Context, Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _buyerlist;
    bool public claimReady;
    uint256 private constant _jazzLimit = 100 * 1e18;

    struct PriceRate {
        uint256 nominator;
        uint256 denominator;
    }

    struct ClaimStatus {
        bool jazzHolder;
        bool claimed;
        uint256 jazzAmount;
        uint256 buyAmount;
    }

    mapping (address => ClaimStatus) private _claimStatus;
    uint8 public maxPhase;

    struct IcoBalance {
        uint256 depositAmount;
        uint256 remainAmount;
        uint256 depositForJazzHolderAmount;
        uint256 remainForJazzHolderAmount;
        uint256 airdropAmount;
        uint256 remainAirdropAmount;
    }
    IcoBalance icoBalance;

    struct Phase {
        bool  isRunning;
        PriceRate price;
        uint256 endDate;
    }
    mapping (uint8 => Phase) private _phaseList;

    struct PhaseForJazz {
        bool  isRunning;
        PriceRate price;
        uint256 endDate;
    }

    PhaseForJazz  jazzPhase;

    uint8 public currentPhaseNum;

    IBEP20 private _token;
    IBEP20 public aceptableToken;

    address payable private _wallet;

    uint256 public endICO;
    bool public icoLive;
    bool public saleTojazzHolderLive;
    bool public swapLive;
    event JazzBurn(address _burner, uint256 jazzAmount);
    event TokensPurchased(address indexed purchaser, uint256 amount);
    event AirdropClaimed(address receiver, uint256 amount);
    event TokenDevlivered(uint256 amount);

    modifier icoActive() {
        require(icoLive, "ICO must be active");
        _;
    }
    modifier airdropActive() {
        require(saleTojazzHolderLive, "Sale to jazz holders must be active");
        _;
    }
    modifier swapActive() {
        require(swapLive, "Airdrop must be active");
        _;
    }
    modifier icoNotActive() {
        require(!icoLive, 'ICO should not be active');
        _;
    }
    modifier airdropNotActive() {
        require(!saleTojazzHolderLive, "Sale to jazz holders should not be active");
        _;
    }
    modifier swapNotActive() {
        require(!swapLive, "Airdrop should not be active");
        _;
    }
    modifier claimActive() {
        require(claimReady, "Claiming should be active");
        _;
    }
    constructor (address payable wallet) public {
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        _wallet = wallet;
        maxPhase = 4;
        //_token = IBEP20(0xddd2F9FcA0c6b22B2F6CD34E7DB42B6E922D0840);
        //aceptableToken = IBEP20(0x6c69eDc86b3746185596B6c7127B5AA1f34BA019);
    }

    // Manage buyer list
    function addBuyerTolist(address _buyer) public onlyOwner returns (bool) {
        return _addBuyerTolist(_buyer);
    }

    function _addBuyerTolist(address _buyer) private returns (bool) {

        require(_buyer != address(0), "Pre-Sale: buyer address is the zero address");
        return EnumerableSet.add(_buyerlist, _buyer);
    }

    function delBuyerFromlist(address _buyer) public onlyOwner returns (bool) {
        require(_buyer != address(0), "Pre-Sale:  buyer address is the zero address");
        return EnumerableSet.remove(_buyerlist, _buyer);
    }

    function getBuyerlistLength() public view returns (uint256) {
        return EnumerableSet.length(_buyerlist);
    }

    function isBuyer(address _buyer) public view returns (bool) {
        return EnumerableSet.contains(_buyerlist, _buyer);
    }

    function getBuyer(uint256 _index) public view returns (address){
        require(_index <= getBuyerlistLength() - 1, "SwapMining: index out of bounds");
        return EnumerableSet.at(_buyerlist, _index);
    }

    // Manage phase
    function updatePhase(uint8 phaseNum,uint256 priceN, uint256 priceD, uint256 endDate) public onlyOwner returns (bool) {
        require (priceN>0&&priceD>0, "Pre-Sale:Price should be not zero.");
        _phaseList[phaseNum].price = PriceRate(priceN, priceD);
        _phaseList[phaseNum].endDate = endDate;
    }

    function updatePhaseForJazzHolders(uint256 priceN, uint256 priceD, uint256 endDate) public onlyOwner returns (bool) {
        require (priceN>0&&priceD>0, "Pre-Sale:Price should be not zero.");
        jazzPhase.price= PriceRate(priceN, priceD);
        jazzPhase.endDate= endDate;
    }

    function getPhase(uint8 _phaseNum) public view returns (
        bool  isRunning,
        uint256 priceN,
        uint256 priceD,
        uint256 endDate) {
        require (_phaseNum >0 && _phaseNum < 9, "Pre-Sale: Phase number must be small than 9.");
        isRunning = _phaseList[_phaseNum].isRunning;
        priceN = _phaseList[_phaseNum].price.nominator;
        priceD = _phaseList[_phaseNum].price.denominator;
        endDate = _phaseList[_phaseNum].endDate;
    }

    function forwardPhase () public onlyOwner {
        _forwardPhase();
    }

    function _forwardPhase() private icoActive returns(bool)  {

        require (currentPhaseNum <= maxPhase, "ICO is over");

        for (uint8 i = 1; i <= maxPhase; i++) {
            if(now < _phaseList[i].endDate){
                _phaseList[currentPhaseNum].isRunning = false;
                currentPhaseNum = i;
                _phaseList[currentPhaseNum].isRunning = true;
                return true;
            }
        }

        _stopICO();

        return false;

    }

    function icoAmount()  public view returns(uint256) {
        uint256 amt = icoBalance.depositAmount;
        return amt;
    }
    function airdropAmount()  public view returns(uint256) {
        uint256 amt = icoBalance.airdropAmount;
        return amt;
    }
    function icoAmountForJazzHolder()  public view returns(uint256) {
        uint256 amt = icoBalance.depositForJazzHolderAmount;
        return amt;
    }
    function icoRemainAmount()  public view returns(uint256) {
        uint256 amt = icoBalance.remainAmount;
        return amt;
    }
    function airdropRemainAmount()  public view returns(uint256) {
        uint256 amt = icoBalance.remainAirdropAmount;
        return amt;
    }
    function icoRemainAmountForJazzHolder()  public view returns(uint256) {
        uint256 amt = icoBalance.remainForJazzHolderAmount;
        return amt;
    }
    //Start Pre-Sale
    function startICO(uint endDate) public onlyOwner icoNotActive() {
        require(endDate > now, 'duration should be > 0');

        endICO = endDate;
        currentPhaseNum = 1;
        _phaseList[1].isRunning = true;
        jazzPhase.isRunning = true;
        icoLive = true;
        saleTojazzHolderLive = true;
        swapLive = true;
    }

    function stopICO() public onlyOwner icoActive(){
        _stopICO();
        jazzPhase.isRunning = false;
        swapLive = false;
        saleTojazzHolderLive = false;
    }

    function _stopICO() private icoActive(){
        currentPhaseNum = maxPhase + 1;
        endICO = 0;
        for (uint8 i = 1; i <= maxPhase; i++) {
            _phaseList[i].isRunning = false;
        }

        icoLive = false;
    }

    receive() external payable {
        require (icoLive == true , "Pre-Sale: cant receive  while current Airdrop is not running.");
        buyTokens();
    }

    // Manage remain
    function withdrawRemainToken () public onlyOwner {
        uint256 remaining = _token.balanceOf(address(this));
        require(remaining  > 0 , 'Contract has no token');
        _token.safeTransfer(owner(), remaining);
    }

    function withdraw() public onlyOwner {
        require(address(this).balance > 0, 'Contract has no money');
        _wallet.transfer(address(this).balance);
    }

    function BurnJazz () public onlyOwner returns(bool res)   {
        uint256 jazzAmount = aceptableToken.balanceOf(address(this));
        aceptableToken.transfer(0x000000000000000000000000000000000000dEaD, jazzAmount);
        emit JazzBurn(_msgSender(), jazzAmount);
        return true;
    }

    //Pre-Sale
    function buyTokens() public nonReentrant icoActive payable {
        require (_phaseList[currentPhaseNum].isRunning, "Pre-Sale: Current phase is not running.");

        if(now > _phaseList[currentPhaseNum].endDate) _forwardPhase();

        if(!isBuyer(_msgSender())) _addBuyerTolist(_msgSender());

        uint256 weiAmount = msg.value;
        uint256 tokenAmount = _getTokenAmount(weiAmount);
        uint256 buyTokenAmount = tokenAmount  > icoBalance.remainAmount ? icoBalance.remainAmount : tokenAmount;
        uint256 refundEthAmount  = _getETHAmount(tokenAmount.sub(buyTokenAmount));
        uint256 receiveEthAmount = weiAmount.sub(refundEthAmount);

        _claimStatus[_msgSender()].buyAmount = _claimStatus[_msgSender()].buyAmount.add(buyTokenAmount);

        icoBalance.remainAmount = icoBalance.remainAmount.sub(buyTokenAmount);
        emit TokensPurchased(_msgSender(), buyTokenAmount);

        payable(owner()).transfer(receiveEthAmount.mul(30).div(100));
        _wallet.transfer(receiveEthAmount.mul(70).div(100));
        if(refundEthAmount > 0) _msgSender().transfer(refundEthAmount);

        if(icoBalance.remainAmount == 0) {
            icoLive = false;
        }
    }

    function buyTokensToJazzHolders() public nonReentrant airdropActive payable{
        uint256 swapJazzAmount = aceptableToken.balanceOf(_msgSender());
        require (jazzPhase.isRunning&&saleTojazzHolderLive, "Pre-Sale: Airdrop is over.");

        require (now < jazzPhase.endDate, "Pre-Sale: Airdrop is out date.");

        require (_jazzLimit <= swapJazzAmount || _claimStatus[_msgSender()].jazzHolder, "Pre-Sale: Jazz amount is not enough.");

        if(!isBuyer(_msgSender())) _addBuyerTolist(_msgSender());

        uint256 weiAmount = msg.value;
        uint256 tokenAmount = _getAirdropTokenAmount(weiAmount);
        uint256 buyTokenAmount = tokenAmount  > icoBalance.remainForJazzHolderAmount ? icoBalance.remainForJazzHolderAmount : tokenAmount;
        uint256 refundEthAmount  = _getAirdropETHAmount(tokenAmount.sub(buyTokenAmount));
        uint256 receiveEthAmount = weiAmount.sub(refundEthAmount);

        _claimStatus[_msgSender()].buyAmount = _claimStatus[_msgSender()].buyAmount.add(buyTokenAmount);

        icoBalance.remainForJazzHolderAmount = icoBalance.remainForJazzHolderAmount.sub(buyTokenAmount);
        emit TokensPurchased(_msgSender(), buyTokenAmount);

        payable(owner()).transfer(receiveEthAmount.mul(30).div(100));
        _wallet.transfer(receiveEthAmount.mul(70).div(100));
        if(refundEthAmount > 0) _msgSender().transfer(refundEthAmount);

        if(icoBalance.remainForJazzHolderAmount == 0) {
            saleTojazzHolderLive = false;
        }
    }

    function airdropForJazzHolders(uint256 swapJazzAmount) public nonReentrant swapActive {
        require (jazzPhase.isRunning&&swapLive, "Pre-Sale: Airdrop is over.");

        require (now < jazzPhase.endDate, "Pre-Sale: Airdrop is out date.");

        require (aceptableToken.allowance(_msgSender(), address(this)) >= swapJazzAmount, "Pre-Sale: Allowance is not enough.");

        if(!isBuyer(_msgSender())) _addBuyerTolist(_msgSender());

        uint256 tokenAmount = _getSwapTokenAmount(swapJazzAmount);
        uint256 swapTokenAmount = tokenAmount  > icoBalance.remainAirdropAmount ? icoBalance.remainAirdropAmount : tokenAmount;
        uint256 refundJazzAmount  = _getJazzAmount(tokenAmount.sub(swapTokenAmount));
        uint256 receiveJazzAmount = swapJazzAmount.sub(refundJazzAmount);

        aceptableToken.safeTransferFrom(_msgSender() ,  address(this), receiveJazzAmount);
        _claimStatus[_msgSender()].jazzAmount = _claimStatus[_msgSender()].jazzAmount.add(receiveJazzAmount);

        if(!_claimStatus[_msgSender()].jazzHolder && _claimStatus[_msgSender()].jazzAmount >= _jazzLimit)
            _claimStatus[_msgSender()].jazzHolder = true;
        _claimStatus[_msgSender()].buyAmount = _claimStatus[_msgSender()].buyAmount.add(swapTokenAmount);

        icoBalance.remainAirdropAmount = icoBalance.remainAirdropAmount.sub(swapTokenAmount);
        emit TokensPurchased(_msgSender(), swapTokenAmount);

        if(icoBalance.remainAirdropAmount  == 0) {
            swapLive = false;
        }
    }

    //token Deliver
    function SetToken(IBEP20 addr) public onlyOwner returns(bool res)  {
        require (address(addr)!=address(0), 'Token is zero address.');
        _token = addr;
        //require(icoAmount() > 0 && icoAmount() <= _token.balanceOf(address(this)), 'Deposited tokens must be great than presale amount');
        return true;
    }

    function SetICOAmount(uint256 amount_, uint256 jazzSaleAmount_,uint256 jazzSwapAmount_) public onlyOwner returns(bool res)  {
        icoBalance.depositAmount = amount_;
        icoBalance.depositForJazzHolderAmount = jazzSaleAmount_;
        icoBalance.airdropAmount = jazzSwapAmount_;
        icoBalance.remainAmount = amount_;
        icoBalance.remainForJazzHolderAmount = jazzSaleAmount_;
        icoBalance.remainAirdropAmount = jazzSwapAmount_;
        return true;
    }

    function SetAcceptableToken(IBEP20 addr) public onlyOwner returns(bool res)  {
        require (address(addr)!=address(0), 'Token is zero address.');
        aceptableToken = addr;
        //require(icoAmount() > 0 && icoAmount() <= _token.balanceOf(address(this)), 'Deposited tokens must be great than presale amount');
        return true;
    }

    function getDeliverAmount (address buyer) public view returns(uint256)  {
        uint256 amount = _claimStatus[buyer].buyAmount;
        return amount;
    }

    function SetClaimReady(bool val) public onlyOwner returns(bool res)  {
        claimReady = val;
        return true;
    }

    function Claim() public claimActive {
        require (address(_token)!=address(0), 'Token is not set.');
        require (!_claimStatus[_msgSender()].claimed, 'You are already claimed.');
        address buyer = _msgSender();
        uint256 amount = getDeliverAmount( _msgSender());
        _deliverTokens(buyer, amount);
        _claimStatus[buyer].claimed =  true;
        emit TokenDevlivered(amount);
    }

    //Airdrop v2

    function _deliverTokens(address beneficiary, uint256 tokenAmount) private {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    //Adviser
    function _getTokenAmount(uint256 weiAmount) private view returns (uint256) {
        return weiAmount.mul(_phaseList[currentPhaseNum].price.nominator).div(_phaseList[currentPhaseNum].price.denominator);
    }

    function _getETHAmount(uint256 tokenAmount) private view returns (uint256) {
        return tokenAmount.mul(_phaseList[currentPhaseNum].price.denominator).div(_phaseList[currentPhaseNum].price.nominator);
    }
    // for airdrop
    function _getAirdropTokenAmount(uint256 weiAmount) private view returns (uint256) {
        return weiAmount.mul(jazzPhase.price.nominator).div(jazzPhase.price.denominator);
    }

    function _getAirdropETHAmount(uint256 tokenAmount) private view returns (uint256) {
        return tokenAmount.mul(jazzPhase.price.denominator).div(jazzPhase.price.nominator);
    }

    function _getSwapTokenAmount(uint256 tokenAmount) private pure returns (uint256) {
        return tokenAmount.div(6);
    }

    function _getJazzAmount(uint256 tokenAmount) private pure returns (uint256) {
        return tokenAmount.mul(6);
    }

    function wallet() public view returns (address payable) {
        return _wallet;
    }

    function getJazzPhase() public view returns (
        bool  isRunning,
        uint256 priceN,
        uint256 priceD,
        uint256 endDate
        ) {
        isRunning = jazzPhase.isRunning;
        priceN = jazzPhase.price.nominator;
        priceD = jazzPhase.price.denominator;
        endDate = jazzPhase.endDate;
    }

}
