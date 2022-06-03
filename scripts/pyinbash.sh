#!/usr/bin/env bash

PYTHON3=$(which python3)
export PYTHON3

echo
echo "Begin python3 -c example"
if [ -x "$PYTHON3" ]; then
    echo Using: "$PYTHON3"
    "$PYTHON3" -c "print('Hello, world')"
else
    PYTHON3=$(brew --prefix)/opt/python/libexec/bin
    if [ -x "$PYTHON3" ]; then
        echo Using: "$PYTHON3"
        "$PYTHON3" -c "print('Hello, world')"
    else
        echo 'else else Hello World'
    fi
echo 'else Hello World'
fi
echo "End python3 -c example"
echo

echo "Begin inline example"
"$PYTHON3" - << EOF
import socket
import subprocess
import ipaddress
import asyncio
import urllib.request

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP
print("Inline python3 execution!")
print("local_ip="+get_ip())

EOF
echo "End inline example"
echo
echo "Begin create pyscript.py"
cat << EOF > scripts/pyscript.py
#!/usr/bin/env python3
import sys
import socket
import subprocess
import ipaddress
import asyncio
import urllib.request

print(sys.version_info[0])
print(sys.version_info[1])
print(sys.version_info[2])
if not sys.version_info > (2,7,0):
	print("This is python@2.7!!!")
	if sys.version_info > (2,7,16):
		print("This is python@2.7.16!!!")
elif sys.version_info > (3,0):
	print("This is python3!!!")
	if sys.version_info < (3,10,0):
		print("Please upgrade to a version greater than 3.9!!!")

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

async def get_local_ip():
    global local_ip
    loop = asyncio.get_event_loop()
    transport, protocol = await loop.create_datagram_endpoint(
        asyncio.DatagramProtocol,
        remote_addr=('8.8.8.8', 80))
    result = transport.get_extra_info('sockname')[0]
    transport.close()
    local_ip=result
    return result

print("local_ip="+asyncio.run(get_local_ip()))

IP_WEBSITES = (
           'https://ipinfo.io/ip',
           'https://ipecho.net/plain',
           'https://api.ipify.org',
           'https://ipaddr.site',
           'https://icanhazip.com',
           'https://ident.me',
           'https://curlmyip.net',
           )

def get_public_ip():
    for ipWebsite in IP_WEBSITES:
        try:
            response = urllib.request.urlopen(ipWebsite)

            charsets = response.info().get_charsets()
            if len(charsets) == 0 or charsets[0] is None:
                charset = 'utf-8'  # Use utf-8 by default
            else:
                charset = charsets[0]

            userIp = response.read().decode(charset).strip()

            return userIp
        except:
            pass  # Network error, just continue on to next website.

    # Either all of the websites are down or returned invalid response
    # (unlikely) or you are disconnected from the internet.
    return None

# print(get_public_ip())

def find_free_port():
    with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
        s.bind(("", 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]

def get_hostname():
    host_name = socket.gethostname()
    return host_name


def get_host():

    global hostname
    global public_ip

    # hostname = socket.getfqdn()
    # print("hostname=" + hostname)

    hostname = socket.gethostname()
    print("hostname=" + hostname)

    IP_addres = socket.gethostbyname("$hostname")
    print("public_ip=" + get_public_ip())
    return hostname

addr = ("", $1)  # all interfaces, port $1

def create_server():

    for ip in ipaddress.IPv4Network('0.0.0.0/0'):
        print(f'{ip}')
        if socket.has_dualstack_ipv6():
            s = socket.create_server(addr, family=socket.AF_INET6, dualstack_ipv6=True)
        else:
            s = socket.create_server(addr)

    for ip in ipaddress.IPv4Network('0.0.0.0:$1'):
        print(f'{ip}')
        if socket.has_dualstack_ipv6():
            s = socket.create_server(addr, family=socket.AF_INET6, dualstack_ipv6=True)
        else:
            s = socket.create_server(addr)

# create_server()
# get_host()
print(get_host())
print(get_hostname())

print('Hello python3!!!')
# subprocess.call(["lsof","-i", "-P"])

EOF
echo "End create pyscript.py"

chmod 755 scripts/pyscript.py
./scripts/pyscript.py

echo "Back to bash"
