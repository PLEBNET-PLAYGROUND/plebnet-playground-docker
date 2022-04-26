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
from pprint import pprint

sys.path.append('.')
sys.path.append("/usr/local/lib/python3.8/site-packages")
sys.path.append("/usr/local/lib/python3.9/site-packages")

parser = argparse.ArgumentParser(description='Script to get coins from a faucet.')
parser.add_argument('-c', '--cmd', default='docker', help='bitcoin-cli command to use')
parser.add_argument('-f', '--faucet', default='http://signet.xenon.fun:5000/faucet', help='URL of the faucet')
parser.add_argument('-a', '--address', default='', help='Bitcoin address to which the faucet should send')
parser.add_argument('-r', '--report', action='store_true', help='Return session data')

args = parser.parse_args()

def print_report():
    if args.report == True:
        print(args.address)
        # NOTE: jq expected syntax
        # echo  {\"address\": \"tb1qhjd4lxv7vkqp7pen34t8zfxvvc8f8eqpppug26\"} | jq .
        #print(data) #return session data first!
    else:
        print(res.text)

if args.address == '':
    # get address for receiving coins
    args.address = json.loads(subprocess.check_output([args.cmd] + ['exec','-it','playground-lnd', 'lncli', '--macaroonpath', '/root/.lnd/data/chain/bitcoin/signet/admin.macaroon', 'newaddress', 'p2wkh']))["address"]
    data = {'address': args.address}
else:
    data = {'address': args.address}

try:
    res = requests.get(args.faucet, params=data)
    print_report()
except:
    print('Unexpected error when contacting faucet:', sys.exc_info()[0])
    exit()

