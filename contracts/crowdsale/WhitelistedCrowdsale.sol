pragma solidity 0.4.24;


import "../access/Whitelist.sol";
import "./BaseCrowdsale.sol";


contract WhitelistedCrowdsale is Whitelist, BaseCrowdsale {
    /**
    * @dev Extend parent behavior requiring beneficiary to be in whitelist.
    * @param _beneficiary Token beneficiary
    * @param _weiAmount Amount of wei contributed
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyIfWhitelisted(_beneficiary) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}