(****************************************************************************)
(****************************************************************************)
(* uberSpark codegen interface *)
(* author: amit vasudevan (amitvasudevan@acm.org) *)
(****************************************************************************)
(****************************************************************************)


(****************************************************************************)
(* types *)
(****************************************************************************)



(****************************************************************************)
(* interfaces *)
(****************************************************************************)
val hashtbl_keys : (int, Uberspark.Defs.Basedefs.section_info_t) Hashtbl.t ->  int list


(****************************************************************************)
(* submodules *)
(****************************************************************************)


module Uobj : sig

  (****************************************************************************)
  (* types *)
  (****************************************************************************)
  type slt_codegen_info_t =
  {
    mutable f_canonical_public_method     : string;
    mutable f_pm_sentinel_addr : int;		
    mutable f_codegen_type : string; (* direct or indirect *)	
    mutable f_pm_sentinel_addr_loc : int;
  }


  (****************************************************************************)
  (* interfaces *)
  (****************************************************************************)
  
  (* TBD: future expansion *)
  (*val generate_src_binhdr : 
    string ->
    string ->
    int ->
    int ->
    (string * Uberspark.Defs.Basedefs.section_info_t) list ->
    unit
*)

  val generate_src_publicmethods_info : string -> string -> ((string, Uberspark.Manifest.Uobj.json_node_uberspark_uobj_publicmethods_t)  Hashtbl.t) -> unit 
  val generate_src_intrauobjcoll_callees_info : string -> ((string, string list)  Hashtbl.t) -> unit
  val generate_src_interuobjcoll_callees_info : string -> ((string, string list)  Hashtbl.t) -> unit 
  val generate_src_legacy_callees_info : string -> (string, string list) Hashtbl.t -> unit 
  
  val generate_slt	: string ->
    ?output_banner: string ->	
    string ->
	  string ->
	  string ->
    slt_codegen_info_t list ->
    string ->
    (string * Uberspark.Defs.Basedefs.slt_indirect_xfer_table_info_t) list ->
    string ->
   bool

  val generate_linker_script : string -> int -> int -> (string * Uberspark.Defs.Basedefs.section_info_t) list -> unit
  val generate_top_level_include_header : string -> ((string, Uberspark.Manifest.Uobj.json_node_uberspark_uobj_publicmethods_t)  Hashtbl.t) ->  unit
  
  val generate_header_file :
    string ->
    ((string * Uberspark.Manifest.Uobj.json_node_uberspark_uobj_publicmethods_t) list) ->
    unit


end




module Uobjcoll : sig

  (****************************************************************************)
  (* types *)
  (****************************************************************************)
type sentinel_info_t =
{
	mutable f_type          : string; 	
    mutable fn_name          : string;
    mutable f_secname       : string;
	mutable code_template		    : string;
	mutable library_code_template  	    : string;	
	mutable sizeof_code_template   : int;	
	mutable fn_address          : int;
    mutable f_pm_addr       : int;
    mutable f_method_name : string;
}



  (****************************************************************************)
  (* interfaces *)
  (****************************************************************************)
  val generate_sentinel_code : string ->
      ?output_banner : string ->
      sentinel_info_t list -> bool
  
  val generate_uobj_binary_image_section_mapping : string ->
    ?output_banner : string ->
    Uberspark.Defs.Basedefs.uobjinfo_t list -> bool

val generate_linker_script : string -> int -> int -> (string * Uberspark.Defs.Basedefs.section_info_t) list -> bool
val generate_top_level_include_header : 
    string ->
    bool ->
    ((string * Uberspark.Manifest.Uobjcoll.json_node_uberspark_uobjcoll_configdefs_t) list) ->
    unit
    

end

