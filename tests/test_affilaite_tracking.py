from itertools import count
import brownie

def test_tracing(web3, chain,whale, dai, interface, accounts, YearnPartnerTracker):
    
    tracker = whale.deploy(YearnPartnerTracker)
    dai.approve(tracker, 2**256-1, {'from': whale})

    #a real yearn vault
    vault = interface.VaultAPI('0xdA816459F1AB5631232FE5e97a05BBBb94970c95')
    
    #a non endorsed vault
    fake_vault = interface.VaultAPI('0x1F8ad2cec4a2595Ff3cdA9e8a39C0b1BE1A02014')

    amount = 10_000 *1e18

    # a random address to call affilaite
    affiliate_id = '0xEED46878BaEaa7042A481A6e9efd5c39C6885b0c'

    with brownie.reverts("Vault not endorsed"):
        tracker.deposit(fake_vault, affiliate_id, amount, {'from': whale})

    tracker.deposit(vault, affiliate_id, amount, {'from': whale})

    assert vault.balanceOf(whale) > 0
    bal = vault.balanceOf(whale)
    print(bal/1e18)
    assert tracker.referredBalance(affiliate_id, vault, whale) == bal

    tracker.deposit(vault, affiliate_id, amount, {'from': whale})
    assert tracker.referredBalance(affiliate_id, vault, whale) == bal * 2

    