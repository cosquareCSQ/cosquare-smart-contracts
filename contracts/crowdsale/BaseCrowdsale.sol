pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "../token/CosquareToken.sol";


contract BaseCrowdsale {
    using SafeMath for uint256;
    using SafeERC20 for CosquareToken;

    // The token being sold
    CosquareToken public token;
    // Total amount of tokens sold
    uint256 public tokensSold;

    /**
    * @dev Event for tokens purchase logging
    * @param purchaseType Who paid for the tokens
    * @param beneficiary Who got the tokens
    * @param value Value paid for purchase
    * @param tokens Amount of tokens purchased
    * @param bonuses Amount of bonuses received
    */
    event TokensPurchaseLog(string purchaseType, address indexed beneficiary, uint256 value, uint256 tokens, uint256 bonuses);

    /**
    * @param _token Address of the token being sold
    */
    constructor(CosquareToken _token) public {
        require(_token != address(0), "Invalid token address.");
        token = _token;
    }

    /**
    * @dev fallback function ***DO NOT OVERRIDE***
    */
    function () external payable {
        require(msg.data.length == 0, "Should not accept data.");
        _buyTokens(msg.sender, msg.value, "ETH");
    }

    /**
    * @dev low level token purchase ***DO NOT OVERRIDE***
    * @param _beneficiary Address performing the token purchase
    */
    function buyTokens(address _beneficiary) external payable {
        _buyTokens(_beneficiary, msg.value, "ETH");
    }

    /**
    * @dev Tokens purchase for wei investments
    * @param _beneficiary Address performing the token purchase
    * @param _amount Amount of tokens purchased
    * @param _investmentType Investment channel string
    */
    function _buyTokens(address _beneficiary, uint256 _amount, string _investmentType) internal {
        _preValidatePurchase(_beneficiary, _amount);

        (uint256 tokensAmount, uint256 tokenBonus) = _getTokensAmount(_beneficiary, _amount);

        uint256 totalAmount = tokensAmount.add(tokenBonus);

        _processPurchase(_beneficiary, totalAmount);
        emit TokensPurchaseLog(_investmentType, _beneficiary, _amount, tokensAmount, tokenBonus);        
        
        _postPurchaseUpdate(_beneficiary, totalAmount);
    }  

    /**
    * @dev Validation of an executed purchase
    * @param _beneficiary Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        require(_beneficiary != address(0), "Invalid beneficiary address.");
        require(_weiAmount > 0, "Invalid investment value.");
    }

    /**
    * @dev Abstract function to count the number of tokens depending on the funds deposited
    * @param _beneficiary Address for which to get the tokens amount
    * @param _weiAmount Value in wei involved in the purchase
    * @return Number of tokens
    */
    function _getTokensAmount(address _beneficiary, uint256 _weiAmount) internal view returns (uint256 tokens, uint256 bonus);

    /**
    * @dev Executed when a purchase is ready to be executed
    * @param _beneficiary Address receiving the tokens
    * @param _tokensAmount Number of tokens to be purchased
    */
    function _processPurchase(address _beneficiary, uint256 _tokensAmount) internal {
        _deliverTokens(_beneficiary, _tokensAmount);
    }

    /**
    * @dev Deliver tokens to investor
    * @param _beneficiary Address receiving the tokens
    * @param _tokensAmount Number of tokens to be purchased
    */
    function _deliverTokens(address _beneficiary, uint256 _tokensAmount) internal {
        token.safeTransfer(_beneficiary, _tokensAmount);
    }

    /**
    * @dev Changes the contract state after purchase
    * @param _beneficiary Address received the tokens
    * @param _tokensAmount The number of tokens that were purchased
    */
    function _postPurchaseUpdate(address _beneficiary, uint256 _tokensAmount) internal {
        tokensSold = tokensSold.add(_tokensAmount);
    }
}