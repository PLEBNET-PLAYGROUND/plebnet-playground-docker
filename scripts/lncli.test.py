#!/usr/bin/env python3
# Copyright (c) 2021 Richard Safier
# Copyright (c) 2020 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

import argparse
import subprocess
import requests
import sys
import json

parser = argparse.ArgumentParser(description='Script to get coins from a faucet.')
parser.add_argument('-c', '--cmd', dest='cmd', default='docker', help='bitcoin-cli command to use')
parser.add_argument('-f', '--faucet', dest='faucet', default='http://signet.xenon.fun:5000/faucet', help='URL of the faucet')
parser.add_argument('-a', '--address', dest='address', default='', help='Bitcoin address to which the faucet should send')

args = parser.parse_args()

if args.address == '': 
    # get address for receiving coins
    args.address = json.loads(subprocess.check_output([args.cmd] + ['exec','-it','playground-lnd', 'lncli', '--macaroonpath', '/root/.lnd/data/chain/bitcoin/signet/admin.macaroon', 'newaddress', 'p2wkh']))["address"]

    data = {'address': args.address}
try:
    res = requests.get(args.faucet, params=data)
except:
    print('Unexpected error when contacting faucet:', sys.exc_info()[0])
    exit()
print(res.text)
