from brownie import Lottery, config, network
from scripts.helpers import get_account
from web3 import Web3

# Update this value before test
CURRENT_USD_ETH = 4121.37
# To do:
# use this url:
# https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD
# To get ethereum price

# Price variation tolerance for test to pass
PRICE_TOLERANCE = 0.1


def test_get_entrance_fee():
    entrance_usd_price = 15
    account = get_account()
    max_eth = Web3.toWei((entrance_usd_price / CURRENT_USD_ETH) *
                         (1 + PRICE_TOLERANCE), "ether")
    min_eth = Web3.toWei((entrance_usd_price / CURRENT_USD_ETH) *
                         (1 - PRICE_TOLERANCE), "ether")
    if len(Lottery) == 0:
        lottery = Lottery.deploy(
            # Oracle address
            config['networks'][network.show_active()]['eth_usd_price_feed'],
            entrance_usd_price,  # USD entrace price
            {"from": account}
        )
        assert lottery.getEntranceFee() > min_eth
        assert lottery.getEntranceFee() < max_eth
