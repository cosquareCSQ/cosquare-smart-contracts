pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./BaseCrowdsale.sol";


contract PausableCrowdsale is Pausable, BaseCrowdsale {
    /**
    * @dev Extend parent behavior requiring contract not to be paused
    * @param _beneficiary Token beneficiary
    * @param _weiAmount Amount of wei contributed
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}