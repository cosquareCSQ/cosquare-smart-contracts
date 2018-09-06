pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../utils/Time.sol";


contract CosquareToken is Time, StandardToken, DetailedERC20, Ownable {
    using SafeMath for uint256;

    /**
    * Describes locked balance
    * @param expires Time when tokens will be unlocked
    * @param value Amount of the tokens is locked
    */
    struct LockedBalance {
        uint256 expires;
        uint256 value;
    }

    // locked balances specified be the address
    mapping(address => LockedBalance[]) public lockedBalances;

    // sale wallet (65%)
    address public saleWallet;
    // reserve wallet (15%)
    address public reserveWallet;
    // team wallet (15%)
    address public teamWallet;
    // strategic wallet (5%)
    address public strategicWallet;

    // end point, after which all tokens will be unlocked
    uint256 public lockEndpoint;

    /**
    * Event for lock logging
    * @param who The address on which part of the tokens is locked
    * @param value Amount of the tokens is locked
    * @param expires Time when tokens will be unlocked
    */
    event LockLog(address indexed who, uint256 value, uint256 expires);

    /**
    * @param _saleWallet Sale wallet
    * @param _reserveWallet Reserve wallet
    * @param _teamWallet Team wallet
    * @param _strategicWallet Strategic wallet
    * @param _lockEndpoint End point, after which all tokens will be unlocked
    */
    constructor(address _saleWallet, address _reserveWallet, address _teamWallet, address _strategicWallet, uint256 _lockEndpoint) 
      DetailedERC20("cosquare", "CSQ", 18) public {
        require(_lockEndpoint > 0, "Invalid global lock end date.");
        lockEndpoint = _lockEndpoint;

        _configureWallet(_saleWallet, 65000000000000000000000000000); // 6.5e+28
        saleWallet = _saleWallet;
        _configureWallet(_reserveWallet, 15000000000000000000000000000); // 1.5e+28
        reserveWallet = _reserveWallet;
        _configureWallet(_teamWallet, 15000000000000000000000000000); // 1.5e+28
        teamWallet = _teamWallet;
        _configureWallet(_strategicWallet, 5000000000000000000000000000); // 0.5e+28
        strategicWallet = _strategicWallet;
    }

    /**
    * @dev Setting the initial value of the tokens to the wallet
    * @param _wallet Address to be set up
    * @param _amount The number of tokens to be assigned to this address
    */
    function _configureWallet(address _wallet, uint256 _amount) private {
        require(_wallet != address(0), "Invalid wallet address.");

        totalSupply_ = totalSupply_.add(_amount);
        balances[_wallet] = _amount;
        emit Transfer(address(0), _wallet, _amount);
    }

    /**
    * @dev Throws if the address does not have enough not locked balance
    * @param _who The address to transfer from
    * @param _value The amount to be transferred
    */
    modifier notLocked(address _who, uint256 _value) {
        uint256 time = _currentTime();

        if (lockEndpoint > time) {
            uint256 index = 0;
            uint256 locked = 0;
            while (index < lockedBalances[_who].length) {
                if (lockedBalances[_who][index].expires > time) {
                    locked = locked.add(lockedBalances[_who][index].value);
                }

                index++;
            }

            require(_value <= balances[_who].sub(locked), "Not enough unlocked tokens");
        }        
        _;
    }

    /**
    * @dev Overridden to check whether enough not locked balance
    * @param _from The address which you want to send tokens from
    * @param _to The address which you want to transfer to
    * @param _value The amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public notLocked(_from, _value) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Overridden to check whether enough not locked balance
    * @param _to The address to transfer to
    * @param _value The amount to be transferred
    */
    function transfer(address _to, uint256 _value) public notLocked(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
    * @dev Gets the locked balance of the specified address
    * @param _owner The address to query the locked balance of
    * @param _expires Time of expiration of the lock (If equals to 0 - returns all locked tokens at this moment)
    * @return An uint256 representing the amount of locked balance by the passed address
    */
    function lockedBalanceOf(address _owner, uint256 _expires) external view returns (uint256) {
        uint256 time = _currentTime();
        uint256 index = 0;
        uint256 locked = 0;

        if (lockEndpoint > time) {       
            while (index < lockedBalances[_owner].length) {
                if (_expires > 0) {
                    if (lockedBalances[_owner][index].expires == _expires) {
                        locked = locked.add(lockedBalances[_owner][index].value);
                    }
                } else {
                    if (lockedBalances[_owner][index].expires >= time) {
                        locked = locked.add(lockedBalances[_owner][index].value);
                    }
                }

                index++;
            }
        }

        return locked;
    }

    /**
    * @dev Locks part of the balance for the specified address and for a certain period (3 periods expected)
    * @param _who The address of which will be locked part of the balance
    * @param _value The amount of tokens to be locked
    * @param _expires Time of expiration of the lock
    */
    function lock(address _who, uint256 _value, uint256 _expires) public onlyOwner {
        uint256 time = _currentTime();
        require(_who != address(0) && _value <= balances[_who] && _expires > time, "Invalid lock configuration.");

        uint256 index = 0;
        bool exist = false;
        while (index < lockedBalances[_who].length) {
            if (lockedBalances[_who][index].expires == _expires) {
                exist = true;
                break;
            }

            index++;
        }

        if (exist) {
            lockedBalances[_who][index].value = lockedBalances[_who][index].value.add(_value);
        } else {
            lockedBalances[_who].push(LockedBalance({
                expires: _expires,
                value: _value
            }));
        }

        emit LockLog(_who, _value, _expires);
    }
}