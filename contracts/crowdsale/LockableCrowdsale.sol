pragma solidity 0.4.24;


import "../utils/Time.sol";
import "../lifecycle/Lockable.sol";
import "../access/Operable.sol";
import "./PriceStrategy.sol";
import "./BaseCrowdsale.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


contract LockableCrowdsale is Time, Lockable, Operable, PriceStrategy, BaseCrowdsale {
    using SafeMath for uint256;

    /**
    * @dev Locks the next purchase for the provision of bonus tokens
    * @param _beneficiary Address for which the next purchase will be locked
    * @param _lockupPeriod The period to which tokens will be locked from the next purchase
    */
    function lockNextPurchase(address _beneficiary, uint256 _lockupPeriod) external hasOwnerOrOperatePermission {
        require(_lockupPeriod == 6 || _lockupPeriod == 12 || _lockupPeriod == 18, "Invalid lock interval");
        Stage memory currentStage = _getCurrentStage();
        require(currentStage.lock, "Lock operation is not allowed.");
        _lock(_beneficiary, _lockupPeriod);      
    }

    /**
    * @dev Executed when a purchase is ready to be executed
    * @param _beneficiary Address receiving the tokens
    * @param _tokensAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokensAmount) internal {
        super._processPurchase(_beneficiary, _tokensAmount);
        uint256 lockedValue = lockedValues[_beneficiary];

        if (lockedValue > 0) {
            uint256 expires = lockupPeriods[lockedValue].expires;
            token.lock(_beneficiary, _tokensAmount, expires);
        }
    }

    /**
    * @dev Counts the number of tokens depending on the funds deposited
    * @param _beneficiary Address for which to get the tokens amount
    * @param _weiAmount Value in wei involved in the purchase
    * @return Number of tokens
    */
    function _getTokensAmount(address _beneficiary, uint256 _weiAmount) internal view returns (uint256 tokens, uint256 bonus) { 
        (tokens, bonus) = getTokensAmount(_weiAmount, lockedValues[_beneficiary], tokensSold);
    }

    /**
    * @dev Changes the contract state after purchase
    * @param _beneficiary Address received the tokens
    * @param _tokensAmount The number of tokens that were purchased
    */
    function _postPurchaseUpdate(address _beneficiary, uint256 _tokensAmount) internal {
        super._postPurchaseUpdate(_beneficiary, _tokensAmount);

        _unlock(_beneficiary);
    }
}