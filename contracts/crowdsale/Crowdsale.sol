pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../lifecycle/Lockable.sol";
import "../access/Operable.sol";
import "../lifecycle/Withdrawal.sol";
import "./PriceStrategy.sol";
import "./LockableCrowdsale.sol";
import "./WhitelistedCrowdsale.sol";
import "./PausableCrowdsale.sol";
import "../token/CosquareToken.sol";


contract Crowdsale is Lockable, Operable, Withdrawal, PriceStrategy, LockableCrowdsale, WhitelistedCrowdsale, PausableCrowdsale {
    using SafeMath for uint256;

    /**
    * @param _rateETHtoCHF Cost of ETH in CHF
    * @param _minInvestmentInCHF Minimal allowed investment in CHF
    * @param _withdrawWallet Address to which funds will be withdrawn
    * @param _token Address of the token being sold
    */
    constructor(uint256 _rateETHtoCHF, uint256 _minInvestmentInCHF, address _withdrawWallet, CosquareToken _token)
        PriceStrategy(_rateETHtoCHF, _minInvestmentInCHF)
        Withdrawal(_withdrawWallet)
        BaseCrowdsale(_token) public {
    }  

    /**
    * @dev Distributes tokens for wei investments
    * @param _beneficiary Address performing the token purchase
    * @param _ethAmount Investment value in ETH
    * @param _type Type of investment channel
    */
    function distributeTokensForInvestment(address _beneficiary, uint256 _ethAmount, string _type) public hasOwnerOrOperatePermission {
        _buyTokens(_beneficiary, _ethAmount, _type);
    }

    /**
    * @dev Distributes tokens manually
    * @param _beneficiary Address performing the tokens distribution
    * @param _tokensAmount Amount of tokens distribution
    */
    function distributeTokensManual(address _beneficiary, uint256 _tokensAmount) external hasOwnerOrOperatePermission {
        _preValidatePurchase(_beneficiary, _tokensAmount);

        _deliverTokens(_beneficiary, _tokensAmount);
        emit TokensPurchaseLog("MANUAL", _beneficiary, 0, _tokensAmount, 0);

        _postPurchaseUpdate(_beneficiary, _tokensAmount);
    }
}