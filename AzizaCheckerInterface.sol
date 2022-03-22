pragma solidity ^0.4.24;

/**
 * 
 * Aziza CHECKER Interface Smart Contract
 * 
 */


contract AzizaChecker { 


    enum checkReasonCode {
        OK, 
        FAILED_FROM_ACCT_NOT_REGISTERED,
        FAILED_FROM_ACCT_LOCKED, 
        FAILED_FROM_ACCT_FROZEN, 
        FAILED_FROM_ACCT_CONFISCATED,
        FAILED_TO_ACCT_NOT_REGISTERED,
        FAILED_TO_ACCT_LOCKED,
        FAILED_TO_ACCT_FROZEN,
        FAILED_TO_ACCT_CONFISCATED,
        FAILED_ACCT_NOT_CONFISCATED,
        FAILED_FROM_ACCT_VESTING,
        FAILED_TO_ACCT_VESTING,
        FAILED_NON_USA_ACCOUNT,
        FAILED_CONTRACT_PAUSED,
        FAILED_CONTRACT_CLOSED,
        FAILED_NIL_VALUE
    }




    /**
     * CHECK FUNCTIONS
     */



    function check(address _from, address _to, uint256 _amount)  external view returns (checkReasonCode reason) {
            

            return checkReasonCode.OK;

    }




    



    function checkConfiscationAllowed(address _from)  external view returns (checkReasonCode reason) {
            

            return checkReasonCode.OK;

    }



} /* end of azizaChecker_001 contract */