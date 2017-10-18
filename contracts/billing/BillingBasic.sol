pragma solidity ^0.4.11;

contract BillingBasic {

    function billing(
        address _from
    )
        public
        returns (bool isSucc, uint callID);

    function getPrice(
        uint _callID, 
        address _from
    ) 
        public
        returns (uint);

    function lockToken(
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