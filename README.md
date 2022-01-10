# Yearn V2 Partner Tracker

This contract is an accounting contract for tracking yearn deposits from partners. It is non-custodial and only works with vaults endorsed by v2.registry.ychad.eth

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