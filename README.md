# Yearn V2 Partner Tracker

This contract is a non-custodial accounting contract for tracking yearn deposits from partners.

To work out how much traffic an partner has generated we compare the balance stored in the accounting contract with the yvault tokens in their wallet.

Total partner referrals per vyToken = Min(Sum(reffered balance over all partners), user vyToken)

Individual partner referrals are then ordered by most recent.

Example:
A user deposits 10,000 DAI to the yvDAI vault through this contract specifying partner A. They get 9,000 yvdai tokens back. At this point partner A's balance from the user is 9,000 yvDAI. The minimum of the 9,000 in the accounting and the 9,000 in their balance.

If the user now withdraws 5,000 yvDAI the balance they have left is 4,000 yvDAI. 
At this point partner A's balance from the user is 4,000 yvDAI. The minimum of the 9,000 in the accounting and the 4,000 in their balance.

A second user deposits 10,000 DAI to the yvDAI vault through this contract specifying partner A. They get 9,000 yvdai tokens back but have already got 10,000 yvDAI from a previous, non-partnered deposit.  At this point partner A's balance from the user is 9,000 yvDAI. The minimum of the 9,000 in the accounting and the 19,000 in their balance.

A third user deposits 10,000 DAI to the yvDAI vault through this contract specifying partner A and receive 9,000 yvdai tokens back. Then one day later they deposit 10,000 DAI to the yvDAI vault through this contract specifying partner B and and receive 8,900 yvDAI tokens back. At this point partner A's balance from the user is 9,000 yvDAI and partner B is 8,900 yvDAI. 

If the user now withdraws 5,000 yvDAI they will be left with 12,900 yvDAI. At this point partner A's balance from the user is 4,000 yvDAI and partner B is 8,900 yvDAI. This is because the total across all partners is 12,900 yvDAI and partners are filled last in first. 


## Deployment addresses:
Ethereum mainnet (1): `0x8ee392a4787397126C163Cb9844d7c447da419D8`  
Optimism (10): `0x7E08735690028cdF3D81e7165493F1C34065AbA2`  
Fantom Opera (250): `0x086865B2983320b36C42E48086DaDc786c9Ac73B`  
Arbitrum One (42161): `0x0e5b46E4b2a05fd53F5a4cD974eb98a9a613bcb7`  
