pragma solidity ^0.4.11;

import "./BillingBasic.sol";
import "../lib/Ownable.sol";
import "../lib/Util.sol";
import "../lib/ERC20.sol";
import "../charges/Charge.sol";
import "../charges/FreeCharge.sol";
import "../charges/TimesCharge.sol";
import "../charges/IntervalCharge.sol";
import "../baneficiary/Baneficiary.sol";

contract DbotBilling is BillingBasic, Ownable, Util {

    enum BillingType {
        Free,
        Times,
        Interval,
        Other
    }

    struct Order {
        address from;
        uint tokens;
        uint fee;
        bool isFrezon;
        bool isPaid;
    }

    address attToken;
    address beneficiary;
    address charge;
    BillingType billingType = BillingType.Free;
    uint arg0;
    uint arg1;
    mapping(uint => Order) orders; 

    modifier notCalled(uint _callID) {
      if (orders[_callID].from != 0) 
          revert();
      _;
    }

    modifier called(uint _callID) {
      if (orders[_callID].from == 0) 
          revert();
      _;
    }

    event Billing(uint _callID, uint _gas, address _from);
    event GetPrice(uint _callID, uint _gas, address _from, uint _price);
    event LockPrice(uint _callID, uint _gas, address _from);
    event TakeFee(uint _callID, uint _gas,address _from);
    
    function DbotBilling(address _att, address _beneficiary,  uint _billingType, uint _arg0, uint _arg1) {
        attToken = _att;
        beneficiary = new Baneficiary(_beneficiary, _att);
        billingType = BillingType(_billingType);
        arg0 = _arg0;
        arg1 = _arg1;
        initCharge();
    }

    function initCharge() internal {
        if ( billingType == BillingType.Free ) {
            charge = new FreeCharge();
        } else if ( billingType == BillingType.Times ) {
            charge = new TimesCharge(arg0, arg1);               //arg0:每次消费ATT数量  arg1:免费次数
        } else if ( billingType == BillingType.Interval ) {
            charge = new IntervalCharge(arg0, arg1);            //arg0:每段时间消费ATT数量  arg1:分段类型
        } else if ( billingType == BillingType.Other ) {
            revert();
        } else {
            revert();
        }
    }

    function billing(uint _callID, address _from, uint _tokens)
        onlyOwner
        notCalled(_callID)
        public
        returns (bool isSucc) 
    {
        orders[_callID] = Order({
            from : _from,
            tokens : _tokens,
            fee : 0,
            isFrezon : false,
            isPaid : false
        });
        uint fee = getPrice(_callID);
        if (fee == 0) {
            return true;
        }
        orders[_callID].fee = fee;
        isSucc = lockPrice(_callID);
        if (!isSucc)
            revert();
        Billing(_callID, msg.gas, msg.sender);
        return isSucc;
    } 

    function getPrice(uint _callID)
        onlyOwner
        called(_callID)
        public
        returns (uint _fee)
    {
        require(isContract(charge));
        Order storage o = orders[_callID];
        _fee = Charge(charge).getPrice(_callID, o.from);
        require(o.tokens >= _fee);
        GetPrice(_callID, msg.gas, msg.sender, _fee);
    }

    function lockPrice(uint _callID)
        onlyOwner
        called(_callID)
        public
        returns (bool isSucc)
    {
        Order storage o = orders[_callID];
        address from = o.from;
        uint tokens = o.tokens;
        uint allowance = ERC20(attToken).allowance(from, beneficiary);
        require(allowance >= tokens);
        isSucc = Baneficiary(beneficiary).onTransferFrom(from, beneficiary, tokens);
        if (!isSucc) {
            revert();
        } else {
            o.isFrezon = true;
        }
        LockPrice(_callID, msg.gas, msg.sender);
        return isSucc;
    }

    function takeFee(uint _callID)
        onlyOwner
        called(_callID)
        public
        returns (bool isSucc)
    {
        Order storage o = orders[_callID];
        if (o.fee == 0) {
            TakeFee(_callID, o.fee, o.from);
            return true;
        }
        require(o.isFrezon == true);
        require(o.isPaid == false);
        address from = o.from;
        require(o.tokens >= o.fee);
        uint refund = o.tokens - o.fee;
        Baneficiary(beneficiary).onApprove(beneficiary, refund);
        isSucc = Baneficiary(beneficiary).onTransferFrom(beneficiary, from, refund);
        if (isSucc) {
            o.isFrezon = false;
            o.isPaid = true;
            Charge(charge).resetToken(o.from);
            Baneficiary(beneficiary).increaseProfit(o.fee);
            TakeFee(_callID, o.fee, o.from);
        } else {
            revert();
        }
        return isSucc;
    }
    
    function unLockPrice(uint _callID)
        onlyOwner
        called(_callID)
        public
        returns (bool isSucc)
    {
        Order storage o = orders[_callID];
        if (o.tokens == 0) {
            return true;
        }
        require(o.isFrezon == true);
        require(o.isPaid == false);
        address from = o.from;
        uint tokens = o.tokens;
        Baneficiary(beneficiary).onApprove(beneficiary, tokens);
        isSucc = Baneficiary(beneficiary).onTransferFrom(beneficiary, from, tokens);
        if (isSucc) {
            o.isFrezon = false;
            o.isPaid = false;
            TakeFee(_callID, o.fee, o.from);
        } else {
            revert();
        }
        return isSucc;
    }

    function billWithdrawProfit(uint _amount) 
        onlyOwner
        public
        returns(bool) 
    {
        return Baneficiary(beneficiary).withdrawProfit(_amount);
    }

    function onApprove(uint _value) public returns(bool isSucc) {
        return ERC20(attToken).approve(beneficiary, _value);
    }
    
}