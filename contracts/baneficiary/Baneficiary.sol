pragma solidity ^0.4.11;

import "../lib/Ownable.sol";
import "../lib/ERC20.sol";
import "../lib/SafeMath.sol";

contract Baneficiary is Ownable {
    using SafeMath for uint256;

    address beneficiary;
    address att;
    uint profitTokens = 0;

    event ProfitTokensWithdrawn(address indexed _beneficiary, uint256 _amount);

    function Baneficiary(address _beneficiary, address _att) {
        beneficiary = _beneficiary;
        att = _att;
    }

    function withdrawProfit(uint _amount) onlyOwner public returns(bool isSucc) {
        require(_amount <= profitTokens);
        uint256 balance = ERC20(att).balanceOf(address(this));
        require(profitTokens <= balance);
        isSucc = ERC20(att).transfer(beneficiary, _amount);
        if (isSucc) {
            profitTokens = profitTokens.sub(_amount);
        }else {
            revert();
        }
        ProfitTokensWithdrawn(owner, _amount);
        return isSucc;
    }

    function increaseProfit(uint _amount) onlyOwner public {
        profitTokens = profitTokens.add(_amount);
    }

    function approve(address _spender, uint256 _value) onlyOwner public returns (bool) {
        return ERC20(att).approve(_spender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
        return ERC20(att).transferFrom(_from, _to, _value);
    }

}