pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../utils/Time.sol";
import "../access/Operable.sol";


contract PriceStrategy is Time, Operable {
    using SafeMath for uint256;

    /**
    * Describes stage parameters
    * @param start Stage start date
    * @param end Stage end date
    * @param volume Number of tokens available for the stage
    * @param priceInCHF Token price in CHF for the stage
    * @param minBonusVolume The minimum number of tokens after which the bonus tokens is added
    * @param bonus Percentage of bonus tokens
    */
    struct Stage {
        uint256 start;
        uint256 end;
        uint256 volume;
        uint256 priceInCHF;
        uint256 minBonusVolume;
        uint256 bonus;
        bool lock;
    }

    /**
    * Describes lockup period parameters
    * @param periodInSec Lockup period in seconds
    * @param bonus Lockup bonus tokens percentage
    */
    struct LockupPeriod {
        uint256 expires;
        uint256 bonus;
    }

    // describes stages available for ICO lifetime
    Stage[] public stages;

    // lockup periods specified by the period in month
    mapping(uint256 => LockupPeriod) public lockupPeriods;

    // number of decimals supported by CHF rates
    uint256 public constant decimalsCHF = 18;

    // minimum allowed investment in CHF (decimals 1e+18)
    uint256 public minInvestmentInCHF;

    // ETH rate in CHF
    uint256 public rateETHtoCHF;

    /**
    * Event for ETH to CHF rate changes logging
    * @param newRate New rate value
    */
    event RateChangedLog(uint256 newRate);

    /**
    * @param _rateETHtoCHF Cost of ETH in CHF
    * @param _minInvestmentInCHF Minimal allowed investment in CHF
    */
    constructor(uint256 _rateETHtoCHF, uint256 _minInvestmentInCHF) public {
        require(_minInvestmentInCHF > 0, "Minimum investment can not be set to 0.");        
        minInvestmentInCHF = _minInvestmentInCHF;

        setETHtoCHFrate(_rateETHtoCHF);

        // PRE-ICO
        stages.push(Stage({
            start: 1536969600, // 15th Sep, 2018 00:00:00
            end: 1542239999, // 14th Nov, 2018 23:59:59
            volume: uint256(25000000000).mul(10 ** 18), // (twenty five billion)
            priceInCHF: uint256(2).mul(10 ** 14), // CHF 0.00020
            minBonusVolume: 0,
            bonus: 0,
            lock: false
        }));

        // ICO
        stages.push(Stage({
            start: 1542240000, // 15th Nov, 2018 00:00:00
            end: 1550188799, // 14th Feb, 2019 23:59:59
            volume: uint256(65000000000).mul(10 ** 18), // (forty billion)
            priceInCHF: uint256(4).mul(10 ** 14), // CHF 0.00040
            minBonusVolume: uint256(400000000).mul(10 ** 18), // (four hundred million)
            bonus: 2000, // 20% bonus tokens
            lock: true
        }));

        _setLockupPeriod(1550188799, 18, 3000); // 18 months after the end of the ICO / 30%
        _setLockupPeriod(1550188799, 12, 2000); // 12 months after the end of the ICO / 20%
        _setLockupPeriod(1550188799, 6, 1000); // 6 months after the end of the ICO / 10%
    }

    /**
    * @dev Updates ETH to CHF rate
    * @param _rateETHtoCHF Cost of ETH in CHF
    */
    function setETHtoCHFrate(uint256 _rateETHtoCHF) public hasOwnerOrOperatePermission {
        require(_rateETHtoCHF > 0, "Rate can not be set to 0.");        
        rateETHtoCHF = _rateETHtoCHF;
        emit RateChangedLog(rateETHtoCHF);
    }

    /**
    * @dev Tokens amount based on investment value in wei
    * @param _wei Investment value in wei
    * @param _lockup Lockup period in months
    * @param _sold Number of tokens sold by the moment
    * @return Amount of tokens and bonuses
    */
    function getTokensAmount(uint256 _wei, uint256 _lockup, uint256 _sold) public view returns (uint256 tokens, uint256 bonus) { 
        uint256 chfAmount = _wei.mul(rateETHtoCHF).div(10 ** decimalsCHF);
        require(chfAmount >= minInvestmentInCHF, "Investment value is below allowed minimum.");

        Stage memory currentStage = _getCurrentStage();
        require(currentStage.priceInCHF > 0, "Invalid price value.");        

        tokens = chfAmount.mul(10 ** decimalsCHF).div(currentStage.priceInCHF);

        uint256 bonusSize;
        if (tokens >= currentStage.minBonusVolume) {
            bonusSize = currentStage.bonus.add(lockupPeriods[_lockup].bonus);
        } else {
            bonusSize = lockupPeriods[_lockup].bonus;
        }

        bonus = tokens.mul(bonusSize).div(10 ** 4);

        uint256 total = tokens.add(bonus);
        require(currentStage.volume > _sold.add(total), "Not enough tokens available.");
    }    

    /**
    * @dev Finds current stage parameters according to the rules and current date and time
    * @return Current stage parameters (available volume of tokens and price in CHF)
    */
    function _getCurrentStage() internal view returns (Stage) {
        uint256 index = 0;
        uint256 time = _currentTime();

        Stage memory result;

        while (index < stages.length) {
            Stage memory stage = stages[index];

            if ((time >= stage.start && time <= stage.end)) {
                result = stage;
                break;
            }

            index++;
        }

        return result;
    } 

    /**
    * @dev Sets bonus for specified lockup period. Allowed only for contract owner
    * @param _startPoint Lock start point (is seconds)
    * @param _period Lockup period (in months)
    * @param _bonus Percentage of bonus tokens
    */
    function _setLockupPeriod(uint256 _startPoint, uint256 _period, uint256 _bonus) private {
        uint256 expires = _startPoint.add(_period.mul(2628000));
        lockupPeriods[_period] = LockupPeriod({
            expires: expires,
            bonus: _bonus
        });
    }
}