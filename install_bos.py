#!/usr/bin/env python

# Standard imports

import json
import base64

# ## tls.cert
#
# encodes the file as a base64 str, stripping newlines

import os

# +
tls_fname = 'volumes/lnd_datadir/tls.cert'

print('reading {}'.format(tls_fname))

if not os.path.exists(tls_fname):
    raise FileNotFoundError("{} not found\nMake sure you have lnd installed first".format(tls_fname))

with open(tls_fname) as f:
    # get stripped binary string
    file_data = f.read().strip().encode("utf-8")
    
tls_cert = bytes.decode(base64.b64encode(file_data))
tls_cert
# -

# ## admin.macroon

# This file is already in binary format

# +
macaroon_fname = 'volumes/lnd_datadir/data/chain/bitcoin/signet/admin.macaroon'

print('reading {}'.format(macaroon_fname))

if not os.path.exists(macaroon_fname):
    raise FileNotFoundError("{} not found\nMake sure you have generated a lightning wallet first.".format(macaroon_fname))

with open(macaroon_fname, 'rb') as f:
    file_data = base64.b64encode(f.read())
macaroon = bytes.decode(file_data)
macaroon
# -

# ## Update credentials file

# +
credentials_fname = 'bos/node/credentials.json'

print('loading existing credentials {}'.format(credentials_fname))

with open(credentials_fname, 'r') as f:
    credentials = json.load(f)

credentials['cert'] = tls_cert
credentials['macaroon'] = macaroon

print('writing new credentials {}'.format(credentials_fname))

with open(credentials_fname, 'w') as f:
    json.dump(credentials, f, indent=2)
    f.write('\n')

print('done')
