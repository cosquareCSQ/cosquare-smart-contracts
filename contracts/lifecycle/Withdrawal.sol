pragma solidity 0.4.24;


import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract Withdrawal is Ownable {
    // Address to which funds will be withdrawn
    address public withdrawWallet;

    /**
    * Event for withdraw logging
    * @param value Value that was withdrawn
    */
    event WithdrawLog(uint256 value);

    /**
    * @param _withdrawWallet Address to which funds will be withdrawn
    */
    constructor(address _withdrawWallet) public {
        require(_withdrawWallet != address(0), "Invalid funds holder wallet.");

        withdrawWallet = _withdrawWallet;
    }

    /**
    * @dev Transfers funds from the contract to the specified withdraw wallet address
    */
    function withdrawAll() external onlyOwner {
        uint256 weiAmount = address(this).balance;
      
        withdrawWallet.transfer(weiAmount);
        emit WithdrawLog(weiAmount);
    }

    /**
    * @dev Transfers a part of the funds from the contract to the specified withdraw wallet address
    * @param _weiAmount Part of the funds to be withdrawn
    */
    function withdraw(uint256 _weiAmount) external onlyOwner {
        require(_weiAmount <= address(this).balance, "Not enough funds.");

        withdrawWallet.transfer(_weiAmount);
        emit WithdrawLog(_weiAmount);
    }
}