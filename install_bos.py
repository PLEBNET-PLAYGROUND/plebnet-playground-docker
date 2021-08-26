# Standard imports

import json
import base64

# ## tls.cert
#
# encodes the file as a base64 str, stripping newlines

# +
with open('volumes/lnd_datadir/tls.cert') as f:
    # get stripped binary string
    file_data = f.read().strip().encode("utf-8")
    
tls_cert = bytes.decode(base64.b64encode(file_data))
tls_cert
# -

# ## admin.macroon

# This file is already in binary format

with open('volumes/lnd_datadir/data/chain/bitcoin/signet/admin.macaroon', 'rb') as f:
    file_data = base64.b64encode(f.read())
macaroon = bytes.decode(file_data)
macaroon

# ## Update credentials file

# +
credentials_fname = 'bos/node/credentials.json'

with open(credentials_fname, 'r') as f:
    credentials = json.load(f)

credentials['cert'] = tls_cert
credentials['macaroon'] = macaroon

with open(credentials_fname, 'w') as f:
    json.dump(credentials, f, indent=2)
