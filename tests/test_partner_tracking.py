from itertools import count
import brownie

def test_tracing(web3, chain,whale, dai, interface, accounts, YearnPartnerTracker):
    
    tracker = whale.deploy(YearnPartnerTracker)
    dai.approve(tracker, 2**256-1, {'from': whale})

    #a real yearn vault
    vault = interface.VaultAPI('0xdA816459F1AB5631232FE5e97a05BBBb94970c95')

    amount = 10_000 *1e18

    # a random address to call partner
    partnerId = '0xEED46878BaEaa7042A481A6e9efd5c39C6885b0c'

    tracker.deposit(vault, partnerId, amount, {'from': whale})

    assert vault.balanceOf(whale) > 0
    bal = vault.balanceOf(whale)
    print(bal/1e18)
    assert tracker.referredBalance(partnerId, vault, whale) == bal

    tracker.deposit(vault, partnerId, amount, {'from': whale})
    assert tracker.referredBalance(partnerId, vault, whale) == bal * 2