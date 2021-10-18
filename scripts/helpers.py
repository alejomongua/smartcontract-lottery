from brownie import network, accounts, config  # , MockV3Aggregator
from web3 import Web3

DECIMALS = 8
INITIAL_VALUE = 2000 * 10 ** DECIMALS

FORKED_LOCAL_ENVIRONMENTS = [
    'mainnet-fork',
    'mainnet-fork-dev',
]
LOCAL_BLOCKCHAINS_ENVIRONMENTS = [
    'development', 'ganache-local',
]


def get_account():
    local_blockchains = LOCAL_BLOCKCHAINS_ENVIRONMENTS + FORKED_LOCAL_ENVIRONMENTS
    if network.show_active() in local_blockchains:
        return accounts[0]

    return accounts.add(config['wallets']['from_key'])


"""
def deploy_mocks():
    if len(MockV3Aggregator) == 0:
        print(f"Deploying mocks...")
        MockV3Aggregator.deploy(
            DECIMALS, INITIAL_VALUE, {'from': get_account()})
"""
