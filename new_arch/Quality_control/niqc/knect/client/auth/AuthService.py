### generated client-side API functions for AuthService

knect_auth_token = ''
__AuthService_dispatch = None




### login with UCSF Active Directory/LDAP credentials
def login(username, password):
    return __AuthService_dispatch.Dispatch('login', locals())


### with the login knect_auth_token, logout. returns get_token_info with current info
def logout(knect_auth_token):
    return __AuthService_dispatch.Dispatch('logout', locals())


### prevent a knect_auth_token from timing out by renewing it. returns get_token_info with
###	 current info
def renew_token(knect_auth_token):
    return __AuthService_dispatch.Dispatch('renew_token', locals())


### returns a dict of authenticated info for a given token
def get_token_info(knect_auth_token):
    return __AuthService_dispatch.Dispatch('get_token_info', locals())



import knect.client.KnectClient as kc

# call to initialize this library
def Init(username, password, auth_url = 'https://knect.ucsf.edu/auth', service_url = 'https://knect.ucsf.edu/auth'):
    global knect_auth_token
    global __AuthService_dispatch

    knect_auth_token = kc.DoKnectLogin(username, password, auth_url)

    # background dispatch for network communications between client and server. used by API functions
    __AuthService_dispatch = kc.KnectDispatch(knect_auth_token = knect_auth_token,
                                                 service_hostname = service_url)

### jsonschemas for the API functions above
    __AuthService_dispatch.RegisterFuncSchema('login',
    r"""{"comment": "login with UCSF Active Directory/LDAP credentials", "name": "login", "parameters": [{"param_name": "username", "type": "string", "original-type": "knect-string"}, {"param_name": "password", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"param_name": "knect_auth_token", "type": "string", "original-type": "knect-string"}], "function_options": null, "function_name": "login"}""")
    __AuthService_dispatch.RegisterFuncSchema('logout',
    r"""{"comment": "with the login knect_auth_token, logout. returns get_token_info with current info", "name": "logout", "parameters": [{"param_name": "knect_auth_token", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"comment": "dict of token info", "type_name": "TokenInfoParams", "package_name": "knect.core.Auth", "required": ["status", "accessed", "auth_token"], "original-type": "knect-structure", "original-alias": "TokenInfoParams", "additionalProperties": false, "type": "object", "properties": {"status": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "accessed": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "auth_token": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}], "function_options": null, "function_name": "logout"}""")
    __AuthService_dispatch.RegisterFuncSchema('renew_token',
    r"""{"comment": "prevent a knect_auth_token from timing out by renewing it. returns get_token_info with\n\t current info", "name": "renew_token", "parameters": [{"param_name": "knect_auth_token", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"comment": "dict of token info", "type_name": "TokenInfoParams", "package_name": "knect.core.Auth", "required": ["status", "accessed", "auth_token"], "original-type": "knect-structure", "original-alias": "TokenInfoParams", "additionalProperties": false, "type": "object", "properties": {"status": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "accessed": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "auth_token": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}], "function_options": null, "function_name": "renew_token"}""")
    __AuthService_dispatch.RegisterFuncSchema('get_token_info',
    r"""{"comment": "returns a dict of authenticated info for a given token", "name": "get_token_info", "parameters": [{"param_name": "knect_auth_token", "type": "string", "original-type": "knect-string"}], "return_parameters": [{"comment": "dict of token info", "type_name": "TokenInfoParams", "package_name": "knect.core.Auth", "required": ["status", "accessed", "auth_token"], "original-type": "knect-structure", "original-alias": "TokenInfoParams", "additionalProperties": false, "type": "object", "properties": {"status": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "accessed": {"extra_status": "required", "type": "string", "original-type": "knect-timestamp", "format": "date-time"}, "auth_token": {"extra_status": "required", "type": "string", "original-type": "knect-string"}}}], "function_options": null, "function_name": "get_token_info"}""")
