/* API specification for Yann Cobigo's Neuroimaging Quality Control pipeline.
   These are a set of API functions for Neuroimaging to check & update Lava records
   ensuring that DICOM MRI images have the correct metadata
   
   by Mason Louie 2015
*/

package mac.neuroimaging.QualityControl {

  /* when making read-only requests to the API, use these parameters */
  typedef structure
  {
    /* patient in question's ID */
    int pidn REQUIRED;

    /* the username to be used with the system. this should be the service account
       running the script */
    string service_username REQUIRED;

  } QCRequestParam;

  /* When updating info using the API, use these parameters */
  typedef structure
  {
    /* the username to be used with the system. this should be the service account
       running the script */
    string service_username REQUIRED;

    /* neuroimaging InstrId, what instrument record to update */
    int instr_id REQUIRED;

    /* which scan image ID to update */
    int source_id1 OPTIONAL;

    /* the new value of where the image now sits on the network drive. what's being updated */
    string image_path OPTIONAL;

    /* human readable note about the quality of the scanned image. also what's being updated */
    string image_quality_note OPTIONAL;

  } QCUpdateParam;

  service neuroimaging_qc
    authentication = REQUIRED,
    auditing = SKIP_PARAMS,
    validation = SKIP_RETURN
    {
      /* must authenticate with auth service. use with QC service account */

      /* get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals */
      function get_enrollment(QCRequestParam inquiry_params) returns (undefined enrollment_info);

      /* get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals */
      function get_patient(QCRequestParam inquiry_params) returns (undefined patient_info);

      /* get the Lava record for a given PIDN. returns a JSON object (dict) of key-vals */
      function get_neuroimaging_assessment(QCRequestParam inquiry_params) 
        returns (undefined neuroimg_assesment_info);

      /* update the Lava record with the passed parameters */
      function update_image_record(QCUpdateParam update_params) returns (undefined update_status);

      /* after updating Source ID1 field, call this to relink all the scans */
      function relink_scans(QCUpdateParam update_params) returns (undefined update_status);
    };

};
