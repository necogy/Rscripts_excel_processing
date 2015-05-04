/* subset of workspace spec for using with first KNECT services.
   the main workspace spec for kbase is too big, unwieldly, and overloaded for t
his system (for now).
   so this subset of the spec is useful.
   it basically handles file system CRUD functions.

   by Mason Louie 2015
 */

package knect.core.Workspace
{

	typedef string typespec;
	 
	/* A module name defined in a KIDL typespec. */
	typedef string modulename;
	
	/* A type definition name in a KIDL typespec. */
	typedef string typename;

	typedef string func_string;
	
	/* The version of a typespec file. */
	typedef int spec_version;
	
	/* The JSON Schema (v4) representation of a type definition. */
	typedef string jsonschema;
	
	typedef string type_string;

	typedef string obj_name;

	typedef string ws_name;

	typedef structure {
		typespec spec REQUIRED_ONE(0);
		modulename mod REQUIRED_ONE(0);
		list<typename> new_types OPTIONAL;
		list<typename> remove_types OPTIONAL;
		map<modulename, spec_version> dependencies OPTIONAL;
		boolean dryrun OPTIONAL;
		spec_version prev_ver OPTIONAL;
	} RegisterTypespecParams;
	

  /* dict of token info */
  typedef structure
  {
    string status;
    string auth_token;
    timestamp accessed;
    /* some other fields */
  } TokenInfoParams;

  typedef structure
  { 
    string permissions;
    string owner;
	/* etc */
  } ACLRule;

  /* dict of object info */
  typedef structure
  {
    string object_id;
    string type_label;
    string name;

    string type_id;
    string owner_principle_id;
    list<ACLRule> acl_rules;
    string ancestor_id;
    string catalog_id;
    timestamp created;
    timestamp deleted;
    string description;
    string parent_id;
    string root_id;
  } ObjectInfoParams;

  /* dict of JSON object data */
  typedef structure
  {
    string data; // JSON encoded structured data
    ObjectInfoParams metadata; // the workspace object info for the data above/
  } ObjectData;

  typedef structure 
  { 
    obj_name id REQUIRED;
    type_string type REQUIRED;
    string data REQUIRED;
    ws_name workspace REQUIRED;
    map<string,string> metadata OPTIONAL;
    string auth OPTIONAL;
  } save_object_params;


  //////////////////////////////////////////////////////////////////////////////
///////////////

  /* main workspace service for KNECT system */
  service WorkspaceService
    authentication = none,
    auditing = none,
    validation = none
    {
      /* pass-through helper funcs for one-stop shopping. will call auth service
 to handle these needs */
      function login(string username, string password) 
	returns (string knect_auth_token);
      function logout(string knect_auth_token) 
	returns (TokenInfoParams auth_info);


      /* supremely insecure authentication func. creates a new workspace user for username
       REMOVEME in time */
      function insecure_auth(string username) 
	returns (string knect_auth_token);

      /* save an object to the Workspace. will save to current directory.
	 ignores the "workspace" param in the spec
	 returns the object_id (not the object name!) of the created object
	 the variable names come from kbase, the following translations are for clarity:
	 type = type_name
	 id = object_name
	 data = object's json encoded data 
	 workspace = workspace_name (currently ignored, but required)  */
      function save_object(save_object_params params) 
        returns(string object_id);
      /***** function save_object(string type, string id, string data, string workspace) 
	returns (string object_id);*/

      /* # show all the objects in the current directory. does a plain dump of all the
	 fields in the object table. completely ignores the spec for both input and output
	 workspaces = list of workspace names ['name1', 'name2'] (required, but ignored) */
      function list_objects(list<string> workspaces) 
        returns (list<ObjectInfoParams> obj_infos);

      /* get an object whose object_id = id. in the spec, id is the object_name
	 completely ignores the spec for both input and output.
	 id = object_id
	 workspace = workspace_name (required but ignored) */
      function get_object(string id, string workspace)
	returns (ObjectData data);


      /* Register a new typespec or recompile a previously registered typespec
		with new options.
		See the documentation of RegisterTypespecParams for more details.
		Also see the release_types function.	*/
      function register_typespec(RegisterTypespecParams params)
		returns (map<type_string,jsonschema>);

    };
};

