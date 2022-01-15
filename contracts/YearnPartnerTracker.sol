// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import {VaultAPI} from "@yearnvaults/contracts/BaseStrategy.sol";

contract YearnPartnerTracker {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    event ReferredBalanceIncreased(address indexed partnerId, address indexed vault, address indexed depositer, uint amountAdded, uint totalDeposited);
    mapping (address => mapping (address => mapping(address => uint256))) public referredBalance;

    function deposit(address vault, address partnerId) external returns (uint256){
        VaultAPI v = VaultAPI(vault);
        IERC20 want = IERC20(v.token());

        uint256 amount = want.balanceOf(msg.sender);

        return _internalDeposit(v, want, partnerId, amount);

    }

    function deposit(address vault, address partnerId, uint256 amount) external returns (uint256){
        VaultAPI v = VaultAPI(vault);
        IERC20 want = IERC20(v.token());

        return _internalDeposit(v, want, partnerId, amount);
    }

    function _internalDeposit(VaultAPI v, IERC20 want, address partnerId, uint256 amount) internal returns (uint256){

        if(want.allowance(address(this), address(v)) < amount){
            want.safeApprove(address(v), 0);
            want.safeApprove(address(v), type(uint256).max);
        }

        want.safeTransferFrom(msg.sender, address(this), amount);
        uint256 receivedShares = v.deposit(amount, msg.sender);

        //we use vault tokens and not deposit amount to track deposits. ie what percent of the tvl is referred
        referredBalance[partnerId][address(v)][msg.sender] = referredBalance[partnerId][address(v)][msg.sender].add(receivedShares);
        emit ReferredBalanceIncreased(partnerId, address(v), msg.sender, receivedShares, referredBalance[partnerId][address(v)][msg.sender]);

        return receivedShares;
    }

}