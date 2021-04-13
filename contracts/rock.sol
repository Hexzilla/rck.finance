// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

contract Context {
    // Empty internal constructor
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
      return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        return msg.data;
    }
}

contract Coin {
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    mapping (address => uint) public balances;

    // Events allow clients to react to specific
    // contract changes you declare
    event Sent(address from, address to, uint amount);

    // Constructor code is only run when the contract
    // is created
    constructor() {
        minter = msg.sender;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
    }

    // Errors allow you to provide information about
    // why an operation failed. They are returned
    // to the caller of the function.
    error InsufficientBalance(uint requested, uint available);

    // Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        if (amount > balances[msg.sender])
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Transfers ownership of the contract.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function preMineSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 value);
}

library SafeMath {

}

library Address {
    function isContract(address account) internal view returns (bool) {
        return false;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
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
    }
    IcoBalance icoBalance;

    struct Phase {
        bool  isRunning;
        PriceRate price;
        uint256 endDate;
    }
    mapping (uint8 => Phase) private _phaseList;

    uint8 public currentPhaseNum;
    IBEP20 private _token;
    IBEP20 public aceptableToken;


    modifier swapActive() {
        require(swapLive, "Airdrop must be active");
        _;
    }

    function addBuyerTolist(address _buyer) public onlyOwner returns (bool) {
        return _addBuyerTolist(_buyer);
    }

    function _addBuyerTolist(address _buyer) private returns (bool) {
        require(_buyer != address(0), "Pre-Sale: buyer address is the zero address");
        return EnumerableSet.add(_buyerlist, _buyer);
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

        icoBalance.remainForJazzHolderAmount = icoBalance.remainForJazzHolderAmount.sub(buyTokenAmount);
        emit TokensPurchased(_msgSender(), buyTokenAmount);

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

        if(icoBalance.remainAirdropAmount  == 0) {
            swapLive = false;
        }
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
