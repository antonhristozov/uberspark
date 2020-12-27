(*===========================================================================*)
(*===========================================================================*)
(* uberSpark uobjslt manifest interface implementation *)
(*	 author: amit vasudevan (amitvasudevan@acm.org) *)
(*===========================================================================*)
(*===========================================================================*)


(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* type definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)


type json_node_uberspark_uobjslt_t =
{
	mutable namespace : string;
	mutable platform : string;
	mutable arch : string;
    mutable cpu : string;
    mutable sizeof_addressing : int;
	mutable code_template_directxfer : string;
    mutable code_template_indirectxfer : string;
    mutable code_template_data_definition : string;
};;


(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)
(* interface definitions *)
(*---------------------------------------------------------------------------*)
(*---------------------------------------------------------------------------*)


(*--------------------------------------------------------------------------*)
(* convert json node "uberspark-uobjslt" into json_node_uberspark_uobjslt_t variable *)
(* return: *)
(* on success: true; json_node_uberspark_uobjslt fields are modified with parsed values *)
(* on failure: false; json_node_uberspark_uobjslt fields are untouched *)
(*--------------------------------------------------------------------------*)

let json_node_uberspark_uobjslt_to_var 
	(mf_json : Yojson.Basic.t)
	(json_node_uberspark_uobjslt_var : json_node_uberspark_uobjslt_t) 
	: bool =
	let retval = ref false in

	try
		let open Yojson.Basic.Util in
			json_node_uberspark_uobjslt_var.namespace <- mf_json |> member "uberspark.uobjslt.namespace" |> to_string;
			json_node_uberspark_uobjslt_var.platform <- mf_json |> member "uberspark.uobjslt.platform" |> to_string;
			json_node_uberspark_uobjslt_var.arch <- mf_json |> member "uberspark.uobjslt.arch" |> to_string;
			json_node_uberspark_uobjslt_var.cpu <- mf_json |> member "uberspark.uobjslt.cpu" |> to_string;
			json_node_uberspark_uobjslt_var.sizeof_addressing <- int_of_string (mf_json |> member "uberspark.uobjslt.sizeof_addressing" |> to_string);
			json_node_uberspark_uobjslt_var.code_template_directxfer <- mf_json |> member "uberspark.uobjslt.code_template_directxfer" |> to_string;
			json_node_uberspark_uobjslt_var.code_template_indirectxfer <- mf_json |> member "uberspark.uobjslt.code_template_indirectxfer" |> to_string;
			json_node_uberspark_uobjslt_var.code_template_data_definition <- mf_json |> member "uberspark.uobjslt.code_template_data_definition" |> to_string;
			retval := true;

	with Yojson.Basic.Util.Type_error _ -> 
			retval := false;
	;

	(!retval)
;;


