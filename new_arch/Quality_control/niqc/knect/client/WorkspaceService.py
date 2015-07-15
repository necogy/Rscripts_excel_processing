### generated client-side API functions for WorkspaceService

knect_auth_token = ''
__WorkspaceService_dispatch = None

import knect.client.KnectClient as kc

# call to initialize this library
def Init(username, password, auth_url = 'https://localhost:17888', service_url = 'https://myhost:7777'):
  global knect_auth_token
  global __WorkspaceService_dispatch

  knect_auth_token = kc.DoKnectLogin(username, password, auth_url)

  # background dispatch for network communications between client and server. used by API functions
  __WorkspaceService_dispatch = kc.KnectDispatch(knect_auth_token = knect_auth_token,
                                                 service_hostname = service_url)

def pv():
  global knect_auth_token
  print knect_auth_token

### pass-through helper funcs for one-stop shopping. will call auth service
### to handle these needs
def login(username, password):
    global __WorkspaceService_dispatch
    return __WorkspaceService_dispatch.Dispatch('login', locals())


### 
def logout(knect_auth_token):
    return __WorkspaceService_dispatch.Dispatch('logout', locals())


### supremely insecure authentication func. creates a new workspace user for username
###       REMOVEME in time
def insecure_auth(username):
    return __WorkspaceService_dispatch.Dispatch('insecure_auth', locals())


### save an object to the Workspace. will save to current directory.
###	 ignores the "workspace" param in the spec
###	 returns the object_id (not the object name!) of the created object
###	 the variable names come from kbase, the following translations are for clarity:
###	 type = type_name
###	 id = object_name
###	 data = object's json encoded data 
###	 workspace = workspace_name (currently ignored, but required)
def save_object(params):
    return __WorkspaceService_dispatch.Dispatch('save_object', locals())


### # show all the objects in the current directory. does a plain dump of all the
###	 fields in the object table. completely ignores the spec for both input and output
###	 workspaces = list of workspace names ['name1', 'name2'] (required, but ignored)
def list_objects(workspaces):
    return __WorkspaceService_dispatch.Dispatch('list_objects', locals())


### get an object whose object_id = id. in the spec, id is the object_name
###	 completely ignores the spec for both input and output.
###	 id = object_id
###	 workspace = workspace_name (required but ignored)
def get_object(id, workspace):
    return __WorkspaceService_dispatch.Dispatch('get_object', locals())


### Register a new typespec or recompile a previously registered typespec
###		with new options.
###		See the documentation of RegisterTypespecParams for more details.
###		Also see the release_types function.
def register_typespec(params):
    return __WorkspaceService_dispatch.Dispatch('register_typespec', locals())




### jsonschemas for the API functions above
__WorkspaceService_dispatch.RegisterFuncSchema('login',
    r"""{"comment": "pass-through helper funcs for one-stop shopping. will call auth service\n to handle these needs", "name": "login", "parameters": [{"param_name": "username", "type": "string", "original-type": "knect-string"}, {"param_name": "password", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"param_name": "knect_auth_token", "type": "string", "original-type": "knect-string"}], "function_options": null, "function_name": "login"}""")
__WorkspaceService_dispatch.RegisterFuncSchema('logout',
    r"""{"comment": "", "name": "logout", "parameters": [{"param_name": "knect_auth_token", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"comment": "dict of token info", "param_name": "auth_info", "type_name": "TokenInfoParams", "package_name": "knect.core.Workspace", "required": ["status", "accessed", "auth_token"], "original-type": "knect-structure", "original-alias": "TokenInfoParams", "additionalProperties": false, "type": "object", "properties": {"status": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "accessed": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "auth_token": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}], "function_options": null, "function_name": "logout"}""")
__WorkspaceService_dispatch.RegisterFuncSchema('insecure_auth',
    r"""{"comment": "supremely insecure authentication func. creates a new workspace user for username\n       REMOVEME in time", "name": "insecure_auth", "parameters": [{"param_name": "username", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"param_name": "knect_auth_token", "type": "string", "original-type": "knect-string"}], "function_options": null, "function_name": "insecure_auth"}""")
__WorkspaceService_dispatch.RegisterFuncSchema('save_object',
    r"""{"comment": "save an object to the Workspace. will save to current directory.\n\t ignores the \"workspace\" param in the spec\n\t returns the object_id (not the object name!) of the created object\n\t the variable names come from kbase, the following translations are for clarity:\n\t type = type_name\n\t id = object_name\n\t data = object's json encoded data \n\t workspace = workspace_name (currently ignored, but required)", "name": "save_object", "parameters": [{"comment": "", "param_name": "params", "type_name": "save_object_params", "package_name": "knect.core.Workspace", "required": ["data", "workspace", "type", "id"], "original-type": "knect-structure", "original-alias": "save_object_params", "additionalProperties": false, "type": "object", "properties": {"data": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "auth": {"extra_status": "optional", "type": "string", "original-type": "knect-string"}, "workspace": {"comment": "", "extra_status": "required", "package_name": "knect.core.Workspace", "type_name": "ws_name", "original-type": "knect-string", "original-alias": "ws_name", "type": "string"}, "type": {"comment": "", "extra_status": "required", "package_name": "knect.core.Workspace", "type_name": "type_string", "original-type": "knect-string", "original-alias": "type_string", "type": "string"}, "id": {"comment": "", "extra_status": "required", "package_name": "knect.core.Workspace", "type_name": "obj_name", "original-type": "knect-string", "original-alias": "obj_name", "type": "string"}, "metadata": {"additionalProperties": {"type": "string", "original-type": "knect-string"}, "extra_status": "optional", "type": "object", "additionalPropertiesKey": {"type": "string", "original-type": "knect-string"}, "original-type": "knect-map"}}}], "return_parameters": [{"param_name": "object_id", "type": "string", "original-type": "knect-string"}], "function_options": null, "function_name": "save_object"}""")
__WorkspaceService_dispatch.RegisterFuncSchema('list_objects',
    r"""{"comment": "# show all the objects in the current directory. does a plain dump of all the\n\t fields in the object table. completely ignores the spec for both input and output\n\t workspaces = list of workspace names ['name1', 'name2'] (required, but ignored)", "name": "list_objects", "parameters": [{"items": {"type": "string", "original-type": "knect-string"}, "type": "array", "param_name": "workspaces", "original-type": "knect-list"}], "return_parameters": [{"items": {"comment": "dict of object info", "type_name": "ObjectInfoParams", "package_name": "knect.core.Workspace", "required": ["description", "created", "deleted", "root_id", "object_id", "name", "parent_id", "catalog_id", "owner_principle_id", "type_id", "acl_rules", "ancestor_id", "type_label"], "original-type": "knect-structure", "original-alias": "ObjectInfoParams", "additionalProperties": false, "type": "object", "properties": {"type_label": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "description": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "created": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "deleted": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "root_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "object_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "parent_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "catalog_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "owner_principle_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "type_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "acl_rules": {"items": {"comment": "", "type_name": "ACLRule", "package_name": "knect.core.Workspace", "required": ["owner", "permissions"], "original-type": "knect-structure", "original-alias": "ACLRule", "additionalProperties": false, "type": "object", "properties": {"owner": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "permissions": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}, "extra_status": "required", "type": "array", "original-type": "knect-list"}, "ancestor_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "name": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}, "type": "array", "param_name": "obj_infos", "original-type": "knect-list"}], "function_options": null, "function_name": "list_objects"}""")
__WorkspaceService_dispatch.RegisterFuncSchema('get_object',
    r"""{"comment": "get an object whose object_id = id. in the spec, id is the object_name\n\t completely ignores the spec for both input and output.\n\t id = object_id\n\t workspace = workspace_name (required but ignored)", "name": "get_object", "parameters": [{"param_name": "id", "type": "string", "original-type": "knect-string"}, {"param_name": "workspace", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"comment": "dict of JSON object data", "param_name": "data", "type_name": "ObjectData", "package_name": "knect.core.Workspace", "required": ["data", "metadata"], "original-type": "knect-structure", "original-alias": "ObjectData", "additionalProperties": false, "type": "object", "properties": {"data": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "metadata": {"comment": "dict of object info", "extra_status": "required", "package_name": "knect.core.Workspace", "required": ["description", "created", "deleted", "root_id", "object_id", "name", "parent_id", "catalog_id", "owner_principle_id", "type_id", "acl_rules", "ancestor_id", "type_label"], "original-type": "knect-structure", "original-alias": "ObjectInfoParams", "additionalProperties": false, "type_name": "ObjectInfoParams", "type": "object", "properties": {"type_label": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "description": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "created": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "deleted": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "root_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "object_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "parent_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "catalog_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "owner_principle_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "type_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "acl_rules": {"items": {"comment": "", "type_name": "ACLRule", "package_name": "knect.core.Workspace", "required": ["owner", "permissions"], "original-type": "knect-structure", "original-alias": "ACLRule", "additionalProperties": false, "type": "object", "properties": {"owner": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "permissions": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}, "extra_status": "required", "type": "array", "original-type": "knect-list"}, "ancestor_id": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "name": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}}}], "function_options": null, "function_name": "get_object"}""")
__WorkspaceService_dispatch.RegisterFuncSchema('register_typespec',
    r"""{"comment": "Register a new typespec or recompile a previously registered typespec\n\t\twith new options.\n\t\tSee the documentation of RegisterTypespecParams for more details.\n\t\tAlso see the release_types function.", "name": "register_typespec", "parameters": [{"comment": "", "param_name": "params", "package_name": "knect.core.Workspace", "allOf": [{"oneOf": [{"description": "required_one group number (0)"}, {"required": ["spec"]}, {"required": ["mod"]}]}, {"description": "validation schema for the required_one and required_any language constructs"}], "type_name": "RegisterTypespecParams", "original-type": "knect-structure", "original-alias": "RegisterTypespecParams", "additionalProperties": false, "type": "object", "properties": {"remove_types": {"items": {"comment": "A type definition name in a KIDL typespec.", "package_name": "knect.core.Workspace", "type_name": "typename", "original-type": "knect-string", "original-alias": "typename", "type": "string"}, "extra_status": "optional", "type": "array", "original-type": "knect-list"}, "dryrun": {"extra_status": "optional", "type": "boolean", "original-type": "knect-boolean"}, "prev_ver": {"comment": "The version of a typespec file.", "extra_status": "optional", "package_name": "knect.core.Workspace", "type_name": "spec_version", "original-type": "knect-int", "original-alias": "spec_version", "type": "integer"}, "new_types": {"items": {"comment": "A type definition name in a KIDL typespec.", "package_name": "knect.core.Workspace", "type_name": "typename", "original-type": "knect-string", "original-alias": "typename", "type": "string"}, "extra_status": "optional", "type": "array", "original-type": "knect-list"}, "dependencies": {"additionalProperties": {"comment": "The version of a typespec file.", "package_name": "knect.core.Workspace", "type_name": "spec_version", "original-type": "knect-int", "original-alias": "spec_version", "type": "integer"}, "extra_status": "optional", "type": "object", "additionalPropertiesKey": {"comment": "A module name defined in a KIDL typespec.", "package_name": "knect.core.Workspace", "type_name": "modulename", "original-type": "knect-string", "original-alias": "modulename", "type": "string"}, "original-type": "knect-map"}, "spec": {"comment": "", "extra_status": {"required_one": 0}, "package_name": "knect.core.Workspace", "type_name": "typespec", "original-type": "knect-string", "original-alias": "typespec", "type": "string"}, "mod": {"comment": "A module name defined in a KIDL typespec.", "extra_status": {"required_one": 0}, "package_name": "knect.core.Workspace", "type_name": "modulename", "original-type": "knect-string", "original-alias": "modulename", "type": "string"}}}], "return_parameters": [{"additionalProperties": {"comment": "The JSON Schema (v4) representation of a type definition.", "package_name": "knect.core.Workspace", "type_name": "jsonschema", "original-type": "knect-string", "original-alias": "jsonschema", "type": "string"}, "type": "object", "additionalPropertiesKey": {"comment": "", "package_name": "knect.core.Workspace", "type_name": "type_string", "original-type": "knect-string", "original-alias": "type_string", "type": "string"}, "original-type": "knect-map"}], "function_options": null, "function_name": "register_typespec"}""")
/home/mason/ipy/__knect/knect/client
