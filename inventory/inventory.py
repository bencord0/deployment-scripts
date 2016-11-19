#!/usr/bin/env python

import json
import os
import sys

from novaclient.client import Client

METADATA = {
    'host_groups': 'ansible_host_groups',
    'host_vars': 'ansible_host_vars',
}
NETWORK_NAME = 'Ext-Net'


def get_openstack_credentials():
    credentials = {
        'version': os.getenv('OS_COMPUTE_API_VERSION', '2'),
        'username': os.environ['OS_USERNAME'],
        'api_key': os.environ['OS_PASSWORD'],
        'tenant_id': os.environ['OS_TENANT_ID'],
        'auth_url': os.environ['OS_AUTH_URL'],
        'region_name': os.environ['OS_REGION_NAME'],
    }
    return credentials


def get_server_address(server, network_name=NETWORK_NAME):
    return server.addresses[network_name][0]['addr']


nova = Client(**get_openstack_credentials())


def main():
    inventory = {
        '_meta': {
            'hostvars': {}
        }
    }

    for server in nova.servers.list():
        name = server.name
        address = get_server_address(server)

        groups = server.metadata.get('ansible_host_groups')
        if not groups:
            if 'other_hosts' not in inventory:
                inventory['other_hosts'] = {'hosts': []}
            inventory['other_hosts']['hosts'].append(address)

        else:
          groups = groups.split(',')
          for group in groups:
            if group not in inventory:
                inventory[group] = {'hosts': []}

            inventory[group]['hosts'].append(address)

        inventory['_meta']['hostvars'][address] = server.metadata

    print(json.dumps(inventory, indent=4))

if __name__ == '__main__':
    main()
