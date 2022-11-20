# Generates docker-compose for n nodes.

# +
from omegaconf import OmegaConf
import sys


architectures = {
        "Intel x64": 'x86_64-linux-gnu',
        'OSX 64-bit': 'aarch64-linux-gnu',
        'arm 32-bit': 'arm-linux-gnueabihf',
        'ARM64 linux': 'aarch64-linux-gnu',
}

from omegaconf import OmegaConf

cli_args = OmegaConf.from_cli()

try:
    triplet = cli_args['TRIPLET']
except KeyError:
    print('Need to supply TRIPLET. Supported architectures:')
    for k, v in architectures.items():
        print('\t{}: TRIPLET={}'.format(k, v))
    sys.exit()

node_counts = dict()

for _ in 'bitcoind', 'lnd', 'tor':
    try:
        node_counts[_] = getattr(cli_args, _)
    except:
        print('Need to supply {}='.format(_))
        sys.exit()

conf = OmegaConf.load('docker-compose.yaml.template')

# merge in architecture
conf = OmegaConf.merge(OmegaConf.create(dict(TRIPLET=triplet)), conf)

print('creating config for nodes:')

def get_service(service_values, service_template):
    """merge values into template"""
    result = OmegaConf.merge(
        service_values,
        service_template)
    OmegaConf.resolve(result)
    for key in service_values:
        result.pop(key)
    return result

def get_service_values(i, node_counts, **kwargs):
    """Get service values using the modulus of service counts"""
    service_values = dict()
    for service, nodes in node_counts.items():
        service_values[service + '_i'] = i%node_counts[service]
    for k,v in kwargs.items():
        service_values[k] = v
    return OmegaConf.create(service_values)

for service in list(conf.services):
    service_nodes = node_counts[service]
    print(service, service_nodes)
    for i in range(service_nodes):
        service_values = get_service_values(i, node_counts, TRIPLET=triplet)
        service_name = '{}-{}'.format(service, str(i))
        conf.services[service_name] = get_service(
            service_values,
            conf.services[service])
        # remove build for additional nodes
        if i > 0:
            conf.services[service_name].pop('build')
    conf.services.pop(service)
try:
    OmegaConf.resolve(conf)
except:
    print(OmegaConf.to_yaml(conf))
    raise
conf.pop('TRIPLET')

with open('docker-compose.yaml', 'w') as f:
    f.write(OmegaConf.to_yaml(conf))
