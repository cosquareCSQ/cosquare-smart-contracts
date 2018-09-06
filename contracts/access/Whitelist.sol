pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "./Operable.sol";


contract Whitelist is RBAC, Operable {
    // role key
    string public constant ROLE_WHITELISTED = "whitelist";

    /**
    * @dev Throws if operator is not whitelisted.
    * @param _operator Operator address
    */
    modifier onlyIfWhitelisted(address _operator) {
        checkRole(_operator, ROLE_WHITELISTED);
        _;
    }

    /**
    * @dev Add an address to the whitelist
    * @param _operator Operator address
    */
    function addAddressToWhitelist(address _operator) public hasOwnerOrOperatePermission {
        addRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev Getter to determine if address is in whitelist
    * @param _operator The address to be added to the whitelist
    * @return True if the address is in the whitelist
    */
    function whitelist(address _operator) public view returns (bool) {
        return hasRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev Add addresses to the whitelist
    * @param _operators Operators addresses
    */
    function addAddressesToWhitelist(address[] _operators) public hasOwnerOrOperatePermission {
        for (uint256 i = 0; i < _operators.length; i++) {
            addAddressToWhitelist(_operators[i]);
        }
    }

    /**
    * @dev Remove an address from the whitelist
    * @param _operator Operator address
    */
    function removeAddressFromWhitelist(address _operator) public hasOwnerOrOperatePermission {
        removeRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev Remove addresses from the whitelist
    * @param _operators Operators addresses
    */
    function removeAddressesFromWhitelist(address[] _operators) public hasOwnerOrOperatePermission {
        for (uint256 i = 0; i < _operators.length; i++) {
            removeAddressFromWhitelist(_operators[i]);
        }
    }
}