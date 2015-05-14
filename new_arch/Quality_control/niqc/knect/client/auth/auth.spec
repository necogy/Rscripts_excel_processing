/* service specification for KNECT auth server 
   
   by Mason Louie 2015
*/

package knect.core.Auth {

  /* dict of token info */
  typedef structure 
  {
    string status;
    string auth_token;
    timestamp accessed;
    /* some other fields */
  } TokenInfoParams;

  /* main authentication service for all services in the KNECT system */
  service AuthService
    authentication = none,
    auditing = none,
    validation = none
    {
    
      /* login with UCSF Active Directory/LDAP credentials */
      function login(string username, string password) returns (string knect_auth_token);
    
      /* with the login knect_auth_token, logout. returns get_token_info with current info */
      function logout(string knect_auth_token) returns (TokenInfoParams);

      /* prevent a knect_auth_token from timing out by renewing it. returns get_token_info with
	 current info */
      function renew_token(string knect_auth_token) returns (TokenInfoParams);

      /* returns a dict of authenticated info for a given token */
      function get_token_info(string knect_auth_token) returns (TokenInfoParams);

    };
};
