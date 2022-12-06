// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import {VaultAPI} from "@yearnvaults/contracts/BaseStrategy.sol";
interface WETH {
    function deposit() external payable;
}

contract YearnPartnerTracker {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    /// @notice An event thats emitted when a depositers referred balance increases
    event ReferredBalanceIncreased(address indexed partnerId, address indexed vault, address indexed depositer, uint amountAdded, uint totalDeposited);

    /// @notice Mapping of partner -> depositer -> vault. Each partner can have multiple depositers who deposit to multiple vaults
    mapping (address => mapping (address => mapping(address => uint256))) public referredBalance;

    // Address of the WETH contract
    address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

     /**
     * @notice Deposit into a vault the full balance of depositer or in the case of sending eth, the amount of eth sent
     * @param vault The address of the vault
     * @param partnerId The address of the partner who has referred this deposit
     * @return The number of yVault tokens received
     */
    function deposit(address vault, address partnerId) external payable returns (uint256){
        VaultAPI v = VaultAPI(vault);
        IERC20 want = IERC20(v.token());

        uint256 amount;
        if(address(want) == weth && msg.value != 0){
            amount = msg.value;
            WETH(weth).deposit{value: amount}();
            
        }else{
            require(msg.value == 0, "sending eth to a non weth vault");
            uint256 amount = want.balanceOf(msg.sender);
        }

        return _internalDeposit(v, want, partnerId, amount);

    }

    /**
     * @notice Deposit into a vault the specified amount from depositer
     * @param vault The address of the vault
     * @param partnerId The address of the partner who has referred this deposit
     * @param amount The amount to deposit
     * @return The number of yVault tokens received
     */
    function deposit(address vault, address partnerId, uint256 amount) external returns (uint256){
        VaultAPI v = VaultAPI(vault);
        IERC20 want = IERC20(v.token());

        return _internalDeposit(v, want, partnerId, amount);
    }

    function _internalDeposit(VaultAPI v, IERC20 want, address partnerId, uint256 amount) internal returns (uint256){
        require(amount > 0, "trying to deposit 0");

        // if there is not enough allowance we set then set them
        if(want.allowance(address(this), address(v)) < amount){
            want.safeApprove(address(v), 0);
            want.safeApprove(address(v), type(uint256).max);
        }

        // pull the required amount from depositer
        uint balance = want.balanceOf(address(this));
        uint amountToPull = balance >= amount ? 0 : amount - balance;
        if(amountToPull > 0){
            want.safeTransferFrom(msg.sender, address(this), amount);
        }
        uint256 receivedShares = v.deposit(amount, msg.sender);

        //we use vault tokens and not deposit amount to track deposits. ie what percent of the tvl is referred
        referredBalance[partnerId][address(v)][msg.sender] = referredBalance[partnerId][address(v)][msg.sender].add(receivedShares);
        emit ReferredBalanceIncreased(partnerId, address(v), msg.sender, receivedShares, referredBalance[partnerId][address(v)][msg.sender]);

        return receivedShares;
    }

}