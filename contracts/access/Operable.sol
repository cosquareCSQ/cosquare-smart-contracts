pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/ownership/rbac/RBAC.sol";


contract Operable is Ownable, RBAC {
    // role key
    string public constant ROLE_OPERATOR = "operator";

    /**
     * @dev Reverts in case account is not Owner or Operator role
     */
    modifier hasOwnerOrOperatePermission() {
        require(msg.sender == owner || hasRole(msg.sender, ROLE_OPERATOR), "Access denied.");
        _;
    }

    /**
     * @dev Getter to determine if address is in whitelist
     */
    function operator(address _operator) public view returns (bool) {
        return hasRole(_operator, ROLE_OPERATOR);
    }

    /**
     * @dev Method to add accounts with Operator role
     * @param _operator Address that will receive Operator role access
     */
    function addOperator(address _operator) public onlyOwner {
        addRole(_operator, ROLE_OPERATOR);
    }

    /**
     * @dev Method to remove accounts with Operator role
     * @param _operator Address that will loose Operator role access
     */
    function removeOperator(address _operator) public onlyOwner {
        removeRole(_operator, ROLE_OPERATOR);
    }
}