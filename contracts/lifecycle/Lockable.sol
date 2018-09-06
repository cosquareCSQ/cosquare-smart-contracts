pragma solidity  0.4.24;


contract Lockable {
    // locked values specified by address
    mapping(address => uint256) public lockedValues;

    /**
    * @dev Method to lock specified value by specified address
    * @param _for Address for which the value will be locked
    * @param _value Value that be locked
    */
    function _lock(address _for, uint256 _value) internal {
        require(_for != address(0) && _value > 0, "Invalid lock operation configuration.");

        if (_value != lockedValues[_for]) {
            lockedValues[_for] = _value;
        }
    }

    /**
    * @dev Method to unlock (reset) locked value
    * @param _for Address for which the value will be unlocked
    */
    function _unlock(address _for) internal {
        require(_for != address(0), "Invalid unlock operation configuration.");
        
        if (lockedValues[_for] != 0) {
            lockedValues[_for] = 0;
        }
    }
}