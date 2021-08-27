#!/usr/bin/env python

# Standard imports only

import json
import base64
import shutil
import os

# ## tls.cert
#
# encodes the file as a base64 str, stripping newlines

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

# ## Read credentials file

# +
credentials_fname_read = 'bos/node/credentials.json'

print('loading existing credentials {}'.format(credentials_fname_read))

with open(credentials_fname_read, 'r') as f:
    credentials = json.load(f)

credentials['cert'] = tls_cert
credentials['macaroon'] = macaroon
# -

# ## Write credentials file

# +
bos_datadir = 'volumes/bos_datadir'

if not os.path.exists(bos_datadir):
    os.mkdir(bos_datadir)
    os.mkdir(bos_datadir + '/node')
# -

credentials_fname_write = '{}/node/credentials.json'.format(bos_datadir)
print('writing new credentials {}'.format(credentials_fname_write))

with open(credentials_fname_write, 'w') as f:
    json.dump(credentials, f, indent=2)
    f.write('\n')

# cat volumes/bos_datadir/node/credentials.json

# ## Copy config file
#

print('copying config.json')

shutil.copy2('bos/config.json', bos_datadir)

# ## fini

print('done')
