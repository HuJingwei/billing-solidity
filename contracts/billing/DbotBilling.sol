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

    event Billing(uint _callID, uint _gas, address _from);
    event GetPrice(uint _callID, uint _gas, address _from, uint _price);
    event LockPrice(uint _callID, uint _gas, address _from);
    event TakeFee(uint _callID, uint _gas,address _from);

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

    function billing(uint _callID, address _from)
        onlyOwner
        notCalled(_callID)
        public
        returns (bool isSucc) 
    {
        uint fee = getPrice(_callID, _from);
        uint allowance = onAllowance(_from);
        require(allowance >= fee);
        isSucc = lockToken(_callID);
        if (!isSucc)
            revert();
        Billing(_callID, msg.gas, msg.sender);
        return isSucc;
    } 

    function getPrice(uint _callID, address _from)
        onlyOwner
        notCalled(_callID)
        public
        returns (uint _fee)
    {
        orders[_callID] = Order({
            from : _from,
            tokens : 0,
            fee : 0,
            isFrezon : false,
            isPaid : false
        });
        Order storage o = orders[_callID];
        _fee = Charge(charge).getPrice(_callID, o.from);
        o.fee = _fee;
        GetPrice(_callID, msg.gas, msg.sender, _fee);
    }

    function lockToken(uint _callID)
        onlyOwner
        called(_callID)
        public
        returns (bool isSucc)
    {
        Order storage o = orders[_callID];
        require(o.isFrezon == false);
        require(o.isPaid == false);
        address from = o.from;
        uint fee = o.fee;
        uint tokens = ERC20(attToken).allowance(from, beneficiary);
        require(tokens >= fee);
        o.tokens = tokens;
        isSucc = Baneficiary(beneficiary).onTransferFrom(from, beneficiary, tokens);
        if (!isSucc) {
            revert();
        } else {
            if (billingType == BillingType.Interval) {
                o.isFrezon = false;
                o.isPaid = true;
            } else {
                o.isFrezon = true;
            }
            Charge(charge).resetToken(o.from);
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
        if (billingType == BillingType.Interval) {
            if (o.isPaid) {
                return true;
            } else {
                return false;
            }
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
        if (billingType == BillingType.Interval) {
            if (!o.isFrezon) {
                return true;
            } else {
                return false;
            }
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

    function onApprove(uint _tokens) 
        public
        returns(bool isSucc) 
    {
        return ERC20(attToken).approve(beneficiary, _tokens);
    }

    function onAllowance(address _from) returns (uint) {
        return ERC20(attToken).allowance(_from, beneficiary);
    }

    function billWithdrawProfit(uint _amount) 
        onlyOwner
        public
        returns(bool) 
    {
        return Baneficiary(beneficiary).withdrawProfit(_amount);
    }
    
}