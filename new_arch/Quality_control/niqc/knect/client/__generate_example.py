# example of how to use the API generator

# first compile spec to jsonschema
import knect.spec.compiler as cmp
compiler = cmp.KnectSpecCompiler()
schema_str = compiler.compile_specfile_to_json('workspace1.spec')
#print schema_str

import generate_api_client as gac

# this will generate the client side python stubs to the spec API in files named 
# according to the service name
gac.GenerateClientRPCLib(schema_str, save_to_file = True)
