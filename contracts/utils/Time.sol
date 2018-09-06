pragma solidity 0.4.24;


contract Time {
    /**
    * @dev Current time getter
    * @return Current time in seconds
    */
    function _currentTime() internal view returns (uint256) {
        return block.timestamp;
    }
}