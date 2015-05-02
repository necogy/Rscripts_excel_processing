import json
import sys

def GenerateClientRPCLib(schema_str, save_to_file = False):
    full_schema = json.loads(schema_str)
    schemas = full_schema[0]['package_components']
    types = {}
    services = {}
    for item in schemas:
        if 'jsonschema' in item:
            types[item['name']] = item['jsonschema']
        else:
            services[item['service_name']] = item['service_components']

    #print types.keys()
    #print services.keys()
    real_stdout = sys.stdout

    for service_name, service in services.iteritems():

        if save_to_file:
            sys.stdout = open('%s.py' % service_name, 'w')

        # preamble
        print '''### generated client-side API functions for %(service_name)s

knect_auth_token = ''
__%(service_name)s_dispatch = None


''' % { 'service_name' : service_name}


        # user defined API function stubs
        for func_schema in service:
            #pp(func_schema)
            GenerateClientFunc(service_name, func_schema)
            print

        # coda
        print '''

import knect.client.KnectClient as kc

# call to initialize this library
def Init(username, password, auth_url = 'https://knect.ucsf.edu/auth', service_url = 'https://knect2.ucsf.edu/%(service_name)s'):
    global knect_auth_token
    global __%(service_name)s_dispatch

    knect_auth_token = kc.DoKnectLogin(username, password, auth_url)

    # background dispatch for network communications between client and server. used by API functions
    __%(service_name)s_dispatch = kc.KnectDispatch(knect_auth_token = knect_auth_token,
                                                 service_hostname = service_url)

### jsonschemas for the API functions above''' % { 'service_name' : service_name}
        for func_schema in service:
            print '''    __%(service_name)s_dispatch.RegisterFuncSchema('%(func_name)s',
    r"""%(schema)s""")''' % { 'service_name' : service_name,
        'func_name' : func_schema['function_name'],
        'schema' : json.dumps(func_schema)
}
    sys.stdout = real_stdout

def GenerateClientFunc(service_name, func_schema):
    print '''
### %(comment)s
def %(func_name)s(%(params)s):
    return __%(service_name)s_dispatch.Dispatch('%(func_name)s', locals())''' % \
        { 'func_name' : func_schema['function_name'],
          'params' : ", ".join([param['param_name'] for param in func_schema['parameters']]),
          'comment' : func_schema['comment'].replace('\n', '\n###'),
          'service_name' : service_name
        }

