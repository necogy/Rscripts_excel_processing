### generated client-side API functions for neuroimaging_qc

knect_auth_token = ''
__neuroimaging_qc_dispatch = None




### get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals
def get_enrollment(inquiry_params):
    return __neuroimaging_qc_dispatch.Dispatch('get_enrollment', locals())


### get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals
def get_patient(inquiry_params):
    return __neuroimaging_qc_dispatch.Dispatch('get_patient', locals())


### get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals
def get_neuroimaging_assessment(inquiry_params):
    return __neuroimaging_qc_dispatch.Dispatch('get_neuroimaging_assessment', locals())


### update the Lava record with the passed parameters
def update_image_record(update_params):
    return __neuroimaging_qc_dispatch.Dispatch('update_image_record', locals())


### after updating Source ID1 field, call this to relink all the scans
def relink_scans(update_params):
    return __neuroimaging_qc_dispatch.Dispatch('relink_scans', locals())



import knect.client.KnectClient as kc

# call to initialize this library
def Init(username, password, auth_url = 'https://knect.ucsf.edu/auth', service_url = 'https://knect2.ucsf.edu/neuroimaging/qc'):
    global knect_auth_token
    global __neuroimaging_qc_dispatch

    knect_auth_token = kc.DoKnectLogin(username, password, auth_url)

    # background dispatch for network communications between client and server. used by API functions
    __neuroimaging_qc_dispatch = kc.KnectDispatch(knect_auth_token = knect_auth_token,
                                                 service_hostname = service_url)

### jsonschemas for the API functions above
    __neuroimaging_qc_dispatch.RegisterFuncSchema('get_enrollment',
    r"""{"comment": "get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals", "name": "get_enrollment", "parameters": [{"comment": "when making read-only requests to the API, use these parameters", "param_name": "inquiry_params", "type_name": "QCRequestParam", "package_name": "mac.neuroimaging.QualityControl", "required": ["service_username", "pidn"], "original-type": "knect-structure", "original-alias": "QCRequestParam", "additionalProperties": false, "type": "object", "properties": {"service_username": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "pidn": {"extra_status": "required", "type": "integer", "original-type": "knect-int"}}}], "return_parameters": [{"param_name": "enrollment_info", "type": "object", "original-type": "knect-undefined"}], "function_options": null, "function_name": "get_enrollment"}""")
    __neuroimaging_qc_dispatch.RegisterFuncSchema('get_patient',
    r"""{"comment": "get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals", "name": "get_patient", "parameters": [{"comment": "when making read-only requests to the API, use these parameters", "param_name": "inquiry_params", "type_name": "QCRequestParam", "package_name": "mac.neuroimaging.QualityControl", "required": ["service_username", "pidn"], "original-type": "knect-structure", "original-alias": "QCRequestParam", "additionalProperties": false, "type": "object", "properties": {"service_username": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "pidn": {"extra_status": "required", "type": "integer", "original-type": "knect-int"}}}], "return_parameters": [{"param_name": "patient_info", "type": "object", "original-type": "knect-undefined"}], "function_options": null, "function_name": "get_patient"}""")
    __neuroimaging_qc_dispatch.RegisterFuncSchema('get_neuroimaging_assessment',
    r"""{"comment": "get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals", "name": "get_neuroimaging_assessment", "parameters": [{"comment": "when making read-only requests to the API, use these parameters", "param_name": "inquiry_params", "type_name": "QCRequestParam", "package_name": "mac.neuroimaging.QualityControl", "required": ["service_username", "pidn"], "original-type": "knect-structure", "original-alias": "QCRequestParam", "additionalProperties": false, "type": "object", "properties": {"service_username": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "pidn": {"extra_status": "required", "type": "integer", "original-type": "knect-int"}}}], "return_parameters": [{"param_name": "neuroimg_assesment_info", "type": "object", "original-type": "knect-undefined"}], "function_options": null, "function_name": "get_neuroimaging_assessment"}""")
    __neuroimaging_qc_dispatch.RegisterFuncSchema('update_image_record',
    r"""{"comment": "update the Lava record with the passed parameters", "name": "update_image_record", "parameters": [{"comment": "When updating info using the API, use these parameters", "param_name": "update_params", "type_name": "QCUpdateParam", "package_name": "mac.neuroimaging.QualityControl", "required": ["instr_id", "service_username"], "original-type": "knect-structure", "original-alias": "QCUpdateParam", "additionalProperties": false, "type": "object", "properties": {"source_id1": {"extra_status": "optional", "type": "integer", "original-type": "knect-int"}, "image_quality_note": {"extra_status": "optional", "type": "string", "original-type": "knect-string"}, "instr_id": {"extra_status": "required", "type": "integer", "original-type": "knect-int"}, "service_username": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "image_path": {"extra_status": "optional", "type": "string", "original-type": "knect-string"}}}], "return_parameters": [{"param_name": "update_status", "type": "object", "original-type": "knect-undefined"}], "function_options": null, "function_name": "update_image_record"}""")
    __neuroimaging_qc_dispatch.RegisterFuncSchema('relink_scans',
    r"""{"comment": "after updating Source ID1 field, call this to relink all the scans", "name": "relink_scans", "parameters": [{"comment": "When updating info using the API, use these parameters", "param_name": "update_params", "type_name": "QCUpdateParam", "package_name": "mac.neuroimaging.QualityControl", "required": ["instr_id", "service_username"], "original-type": "knect-structure", "original-alias": "QCUpdateParam", "additionalProperties": false, "type": "object", "properties": {"source_id1": {"extra_status": "optional", "type": "integer", "original-type": "knect-int"}, "image_quality_note": {"extra_status": "optional", "type": "string", "original-type": "knect-string"}, "instr_id": {"extra_status": "required", "type": "integer", "original-type": "knect-int"}, "service_username": {"extra_status": "required", "type": "string", "original-type": "knect-string"}, "image_path": {"extra_status": "optional", "type": "string", "original-type": "knect-string"}}}], "return_parameters": [{"param_name": "update_status", "type": "object", "original-type": "knect-undefined"}], "function_options": null, "function_name": "relink_scans"}""")
