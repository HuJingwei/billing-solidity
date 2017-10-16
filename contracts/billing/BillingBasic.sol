pragma solidity ^0.4.11;

contract BillingBasic {

    function billing(
        uint _callID,
        address _from,
        uint _tokens
    )
        public
        returns (bool);

    function getPrice(
        uint _callID
    ) 
        public
        returns (uint);

    function lockPrice(
        uint _callID
    ) 
        returns (bool);

    function takeFee(
        uint _callID
    ) 
        returns (bool);

    function unLockPrice(
        uint _callID
    ) 
        returns (bool);

}