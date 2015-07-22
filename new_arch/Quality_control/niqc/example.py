
# example python code for using KNECT auth + neuroimaging QC API
import json
import neuroimaging_qc as niqc
# knect must be in search path. in this case, in the same dir as this example
#import knect.client.auth.AuthService as auth


service_username = 'knect_service_yann'
service_password = 'C0nn#ct4Y@nn'

# must initialize with LDAP auth credentials, auth service URL, and workspace service URL
niqc.Init(service_username, service_password, 
          auth_url = 'https://knect.ucsf.edu/auth',
          #service_url = 'https://localhost:5001/qc' # mason's localhost test
          service_url = 'https://knect.ucsf.edu/neuroimaging/qc')  # dev Knect test 


# successful auth will save a knect_auth_token in the library
knect_auth_token = niqc.knect_auth_token


# some example parameters
inquiry_params = {'service_username':service_username, 'pidn':'17020'}
#update_params = {'service_username':'mlouie', 'pidn':'111', 'instr_id':'212321', 'source_id1':'12345'}



#ans = niqc.get_enrollment(inquiry_params)
#print ans
#
#ans = niqc.get_patient(inquiry_params)
#print "lalal"

patient_lava = json.loads( niqc.get_patient(inquiry_params) )

firstName = patient_lava["patient"]["firstName"]
lastName  = patient_lava["patient"]["lastName"]
#
print "%s%s"%(firstName[0],firstName[1:].lower())
print "%s%s"%(lastName[0],lastName[1:].lower())
#


#
#ans = niqc.get_neuroimaging_assessment(inquiry_params)
#print ans

instruments_list = json.loads( niqc.get_neuroimaging_assessment(inquiry_params) )["instruments"]

for visit in instruments_list:
    print visit["visit"]["visitDate"][0:10]
    print visit["visit"]["visitLocation"]
    print visit["visit"]["visitType"]
    print visit["visit"]["visitWith"]
    print "\n"
    print visit["projName"]
    print "\n"
    print visit["scansSummary"]
    #print visit["sourceIds"]["NIC ScanID"]
    print "\n"
    print "\n"
    print "\n"



#
#
## these should return nothing if successful
#ans = niqc.update_image_record(update_params)
#print ans
#
#ans = niqc.relink_scans(update_params)
#print ans
#
#print knect_auth_token
