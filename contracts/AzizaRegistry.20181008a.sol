pragma solidity ^0.4.24;

/**
 * 
 * Aziza CHECKER Smart Contract
 * 
 */


contract AzizaRegistry { 



  
    /**
     * Modifiers
     * 
     */
	modifier onlySuperUser {
		if (msg.sender != superUser) revert();
		_;
	}
	
	
	modifier onlyTreasurer {
		if (msg.sender != treasurer) revert();
		_;
	}


	modifier onlyAdmin {
		if (msg.sender != admin ) revert();
		_;
	}

 	
	modifier paused {
		if (!contractPaused) revert();
		_;
	}
	
	modifier notPaused {
		if (contractPaused) revert();
		_;
	}
	

	modifier contractOpen {
		require(contractState == ContractStateType.OPEN);

		_;
	}

	modifier contractClosed {
		require(contractState == ContractStateType.CLOSED);

		_;

	}

	modifier contractPRIVATE {
		require(contractState == ContractStateType.PRIVATE);

		_;
    }
    
 
    /**
     * 
     * EVENTS and DATA
     * 
     */
    



    /**
     *  Events
     */
    
     
    event NewTreasurerAccount(address newTreasurer);
    event NewSuperUserAccount(address superUser);
    event NewAdminAccount(address newAdmin);

    event ContractStateChange(ContractStateType  newContractState);
    event ContractPaused();
    event ContractUnpaused();
    

	event AccountRegistered(address acct);
    event AccountDeregistered(address acct);

    event AccountIsVesting(address acct, uint256 vestingEndTime);
    event AccountVestingEnded(address acct);
    
    event AccountMarkedForConfiscation(address acct);
    event AccountUnmarkedForConfiscation(address acct);

    event AccountUpdated(address acct, accountChangeCode reason );
    event InvestorNationalityUpdated(address acct, investorNationality newNationality );
    event InvestorTypeUpdated(address acct, investorType newType );


    /**
     *  Data
     */

    // Contract State Variables 
    // PAUSED: No transfers  allowed 
    // PRIVATE: Not on public sale
	// OPEN: Transfers allowed


	enum  ContractStateType{ CLOSED, PRIVATE, OPEN } 
	ContractStateType public contractState;
    ContractStateType  _oldContractState;
    bool contractPaused;
	
	// account addresses
	// admin accounts
	address public superUser;		
	address public treasurer;				
	address public admin;

    // reserved token holder accounts
    address public developerAccount;        
    address public teamAccount;
    address public foundationAccount;
    address public aneAccount;
    address public reserveAccount;

    uint256 constant ONEYEAR = 31536000;
    uint256 constant MONTH = 2628000;
 


    enum investorNationality {OTHER, USA, UK, RSA, ROW}
    enum investorType {
        INTERNAL, 
        TREASURER,
        ACCREDITED,
        CORPORATE,
        SOPHISTICATED, 
        UNSOPHISTICATED, 
        FOUNDATION, 
        ANE, 
        ANEINVESTOR
    }
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

    enum accountChangeCode {
        AccountIsFrozen,
        AccountIsUnfrozen,
        AccountIsLocked,
        AccountIsUnlocked,
        AccountisConfiscationTrue,
        AccountisConfiscationFalse,
        AccountisVestingTrue,
        AccountisVestingFalse,
        NationalityChanged
    }
    
    //Struct for investor List -
	struct InvestorDetail {
        uint256 uniqueID;                   // Unique Investor ID
		uint256 registeredAccountNumber; 	// Record of registered Account number
		bool isActive; 					// this set to true when record created
		bool isRegistered;
		bool isLocked;  
		bool isFrozen;
        bool isConfiscation;
        bool isVesting;
        investorNationality nationality;
        investorType accountType;
        uint256 vestingEndTime;
        
	}
	// mapping for AccountDetails Account registered, buying tokens, trading
	mapping (address => InvestorDetail) public investor;

  
	

	uint256 public 						numberOfLastRegisteredAccount; //
	uint256 public 						actualNumberOfRegisterAccounts;
	mapping (uint256 => address) public registeredAccountList;


    address checkerContractAddress; // address of the checkerContract

    /**
     * 
     * End of Data
     * 
     */

    
    /**
     * 
     * Contract admin functions
     * 
     */

    // super user functions
    // change super user
    function transferSuperUser(address _superUser) external onlySuperUser {
        superUser = _superUser;
        emit NewSuperUserAccount(_superUser);
    }  


    //  Change contract management account
    function transferTreasurership(address _newTreasurer) external  onlySuperUser {
        treasurer = _newTreasurer;
               
        emit NewTreasurerAccount(_newTreasurer);
        
    }  


    // Treasurer functions 

    // change admin account
    function changeAdminAccount(address _newAdmin ) external  onlyTreasurer {

        admin = _newAdmin;
        emit NewAdminAccount(_newAdmin);

    }  



    // Contract State functions





    function pauseContract ()  external onlyTreasurer   returns (bool success){

        contractPaused = true;
        // log change of state
        emit ContractPaused();
        return true;
    }
    function unPauseContract () external  onlyTreasurer   returns (bool success){

        contractPaused = false;
        // log change of state
        emit ContractUnpaused();
        return true;
    }
        

    function changeContractState (ContractStateType  _newContractState) external onlyTreasurer   returns (bool success){

        contractState = _newContractState;
        emit ContractStateChange(_newContractState);
        return true;
    }


    
    /**
     * 
     * Token Holder admin functions
     * 
     */
    
    /* register, deregister and change accounts */

    function _registerAccount(   address _account, 
                                            investorNationality _nationality,  
                                            investorType _investorType,
                                            uint256 _uniqueID
                                            ) internal   {

        //is Account already registered? If so, quit. Save gas.
        //require(!investor[account].isRegistered);
        if (investor[_account].isRegistered) revert();
        // add to serial list of Accounts
        actualNumberOfRegisterAccounts += 1;
        numberOfLastRegisteredAccount += 1;
        registeredAccountList[ numberOfLastRegisteredAccount ] = _account;

        // Register account
        investor[_account].uniqueID = _uniqueID;
        investor[_account].isRegistered = true;
        investor[_account].isActive = true;
        investor[_account].registeredAccountNumber = numberOfLastRegisteredAccount;
        investor[_account].accountType = _investorType;
        investor[_account].nationality = _nationality;
        // send event
        emit AccountRegistered(_account);
    }


    function registerAccount(address _account, investorNationality _nationality,  investorType _investorType) public  onlyAdmin notPaused {

        _registerAccount(_account, _nationality, _investorType);

    }
            
        
    function deregisterAccount(address _account) external  onlyAdmin notPaused {
        uint _registeredAccountIndex; 

        require(investor[_account].isActive);
        require(investor[_account].isRegistered);
        require(investor[_account].isFrozen);
    

        _registeredAccountIndex = investor[_account].registeredAccountNumber;	

        if (registeredAccountList[_registeredAccountIndex] == _account) {
            registeredAccountList[_registeredAccountIndex] = 0;
        }
        investor[_account].isRegistered = false;
        investor[_account].registeredAccountNumber = 0;
        actualNumberOfRegisterAccounts -= 1;
        
        
        emit AccountDeregistered(_account);
    }



    /**
     * TREASURER FUNCTIONS
     */

    /**
     * markForCofiscation
     */
    function markForConfiscation(address _account) public onlyTreasurer notPaused returns (bool) {
        
        /* check token holder */ 

        require(investor[_account].isRegistered);
        require(investor[_account].isFrozen == true );
       

        investor[_account].isConfiscation = true;

        emit AccountMarkedForConfiscation(_account);
    }

    function unmarkForConfiscation(address _account) public onlyTreasurer notPaused returns (bool) {
        require(investor[_account].isConfiscation);
        
        investor[_account].isConfiscation = false;

        emit AccountUnmarkedForConfiscation(_account);
    }





    function lockAccount (address _account) public onlyAdmin notPaused returns (bool) {
        /* check token holder */
        require(investor[_account].isRegistered);
        /* lockAccount */
        investor[_account].isLocked = true;
        emit AccountUpdated(_account, accountChangeCode.AccountIsLocked);
        return true;

    }


    function unlockAccount (address _account) public onlyAdmin notPaused returns (bool) {
        /* check token holder */
        require(investor[_account].isRegistered);
        /* lockAccount */
        investor[_account].isLocked = false;
        emit AccountUpdated(_account, accountChangeCode.AccountIsUnlocked);
        return true;

    }


    function freezeAccount  (address _account) public onlyAdmin notPaused returns (bool) {
        /* check token holder */
        require(investor[_account].isRegistered);
        /* lockAccount */
        investor[_account].isFrozen = true;
        emit AccountUpdated(_account, accountChangeCode.AccountIsFrozen);
        return true;

    }
    
    function unFreezeAccount  (address _account) public onlyAdmin notPaused returns (bool) {
        /* check token holder */
        require(investor[_account].isRegistered);
        /* lockAccount */
        investor[_account].isFrozen = false;
        emit AccountUpdated(_account, accountChangeCode.AccountIsUnfrozen);
        
        return true;

    }

    function setVestingPeriod  (address _account, uint256 _vestingLengthMonths ) public onlyAdmin notPaused returns (bool) {
        uint256 _vestingEndTime;

        if (!investor[_account].isRegistered) revert();
        if (_vestingLengthMonths > 60 ) revert();
        
        /* set up vesting end date in seconds from time now */
        
        _vestingEndTime= MONTH * _vestingLengthMonths;
        _vestingEndTime += now;

        investor[_account].isVesting = true;
        investor[_account].vestingEndTime = _vestingEndTime;

        emit AccountIsVesting(_account,  _vestingEndTime);
        
        return true;
    }

    function endVesting  (address _account ) public onlyAdmin notPaused returns (bool) {

        require(investor[_account].isVesting);
        
        investor[_account].isVesting = false;
        investor[_account].vestingEndTime = 0;

        emit AccountVestingEnded(_account);
        
        return true;

        
    }

            
    function setNationality  (address _account, investorNationality _newNationality ) public onlyAdmin notPaused returns (bool) {
        

        require(investor[_account].isRegistered);
        
        investor[_account].nationality = _newNationality;

        emit InvestorNationalityUpdated(_account, _newNationality );
        
        return true;
    }

    function setInvestorType (address _account, investorType _newInvestorType ) public onlyAdmin notPaused returns (bool) {
        

        require(investor[_account].isRegistered);
        
        investor[_account].accountType = _newInvestorType;

        emit InvestorTypeUpdated(_account, _newInvestorType );
        
        return true;
    }
  


    /**
     * CHECK FUNCTIONS
     */




    function _openStateCheck(address _from, address _to, uint256 _amount)  internal view returns (checkReasonCode reason) {
        if (_amount == 0 ) return checkReasonCode.FAILED_NIL_VALUE;
        /* check if contract paused */
        if (contractPaused) {
            return checkReasonCode.FAILED_CONTRACT_PAUSED;
        } 

        /* check for registered and unlocked and unfrozen accounts */
        /* check account is registered */
        if (!investor[_from].isRegistered) {
            return checkReasonCode.FAILED_FROM_ACCT_NOT_REGISTERED;
        } 
        if (!investor[_to].isRegistered) {
            return checkReasonCode.FAILED_TO_ACCT_NOT_REGISTERED;
        } 

        
        /* check for accounts LOCKED or FROZEN */
        if (investor[_from].isLocked) {
            return checkReasonCode.FAILED_FROM_ACCT_LOCKED;
        }
        if (investor[_from].isFrozen) {
            return checkReasonCode.FAILED_FROM_ACCT_FROZEN;
        }
        
        if (investor[_to].isLocked) {
            return checkReasonCode.FAILED_TO_ACCT_LOCKED;
        }
        if (investor[_to].isFrozen) {
            return checkReasonCode.FAILED_TO_ACCT_FROZEN;
        }
        if (investor[_to].isConfiscation) {
            return checkReasonCode.FAILED_TO_ACCT_CONFISCATED;
        }
        if (investor[_from].isConfiscation) {
            return checkReasonCode.FAILED_FROM_ACCT_CONFISCATED;
        }      

    }


    function _privateStateCheck(address _from, address _to, uint256 _amount)  internal view returns (checkReasonCode reason) {
        
        checkReasonCode _openStateCheckResult;
   
        _openStateCheckResult = _openStateCheck(_from, _to, _amount);

        if (_openStateCheckResult != checkReasonCode.OK) {
            return _openStateCheckResult;
        }
        
        /* check that if _to account is US _from account is also US */
        if (investor[_to].nationality == investorNationality.USA) {
            if (investor[_from].nationality != investorNationality.USA) {
                return checkReasonCode.FAILED_NON_USA_ACCOUNT;
            }
        }




        /* check vesting period */
        if (investor[_from].isVesting) {
            if (investor[_from].vestingEndTime < now ) {
                return checkReasonCode.FAILED_FROM_ACCT_VESTING;
            }
        }
        /* check vesting period */
        if (investor[_to].isVesting) {
            if (investor[_to].vestingEndTime < now ) {
                return checkReasonCode.FAILED_TO_ACCT_VESTING;
            }
        }
        
        return checkReasonCode.OK;
    }
        
        //return checkReasonCode.OK;
    //}

    function _closedStateCheck(address _from, address _to, uint256 _amount)  internal view returns (checkReasonCode reason) {
        /* check if reserved account */

        if (investor[_from].accountType == investorType.TREASURER ) {
            return _privateStateCheck(_from, _to, _amount);
        }

        return checkReasonCode.FAILED_CONTRACT_CLOSED;
    }



    function check(address _from, address _to, uint256 _amount)  external view returns (checkReasonCode reason) {
            
        /* check if contract paused */
        if (contractPaused) {
            return checkReasonCode.FAILED_CONTRACT_PAUSED;
        } 

        /* check contract state */
        if (contractState == ContractStateType.CLOSED) {
           return _closedStateCheck(_from, _to, _amount);
        } else {
            if (contractState == ContractStateType.PRIVATE){
                return _privateStateCheck(_from, _to, _amount);
            } else {
                /* contract state OPEN */
                return _openStateCheck(_from, _to, _amount);
            }
        }
    }




    



    function checkConfiscationAllowed(address _from)  external view returns (checkReasonCode reason) {
        
        /* check contract state */
        if (contractPaused) {
            return checkReasonCode.FAILED_CONTRACT_PAUSED;
        }
        
        if (investor[_from].isConfiscation) {
            return checkReasonCode.OK;
            }   
        else {
            return checkReasonCode.FAILED_ACCT_NOT_CONFISCATED;
        }
    }







    /**
     * 
     * constructor
     */

    constructor (address _reserveAccount, 
        address _developerAccount,    
        address _foundationAccount ) public        
    {
   

        // set up superUers, admin and treasurer accounts
        superUser = msg.sender;
        treasurer = msg.sender;
        admin = msg.sender;
        

        
        // make sure treasurer is not team or fees or Foundation
        if (msg.sender == _reserveAccount) revert();
        if (msg.sender == _developerAccount) revert();
        if (msg.sender == _foundationAccount) revert();

        // set token holder counters
        numberOfLastRegisteredAccount = 0; 
        actualNumberOfRegisterAccounts = 0;


        // set contract state
        contractState = ContractStateType.PRIVATE;
        contractPaused = false; 


        emit ContractUnpaused();
        emit ContractStateChange( contractState );    


        
        // set up beniciary addresses
        reserveAccount = _reserveAccount;
        developerAccount = _developerAccount;
        foundationAccount = _foundationAccount;
        _registerAccount(  _reserveAccount, investorNationality.OTHER, investorType.INTERNAL);
        _registerAccount(  _developerAccount, investorNationality.OTHER, investorType.INTERNAL);
        _registerAccount(  _foundationAccount, investorNationality.OTHER, investorType.INTERNAL);

 


    }

} /* end of azizaChecker_001 contract */