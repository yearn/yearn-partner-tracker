pragma solidity >=0.6.12;

interface IYearnRegistry {
    function isRegistered(address vault)
        external
        view
        returns (bool);

    function vaults(address vault, uint256 id)
        external
        view
        returns (address);
}