(*------------------------------------------------------------------------------
	uberSpark uberobject verification and build interface
	author: amit vasudevan (amitvasudevan@acm.org)
------------------------------------------------------------------------------*)

open Str


		type sentinel_info_t = 
			{
				s_type: string;
				s_type_id : string;
				s_retvaldecl : string;
				s_fname: string;
				s_fparamdecl: string;
				s_fparamdwords : int;
				s_attribute : string;
				s_origin: int;
				s_length: int;	
			};;


		type uobj_publicmethods_t = 
			{
				f_name: string;
				f_retvaldecl : string;
				f_paramdecl: string;
				f_paramdwords : int;
			};;


		

class uobject 
		= object(self)

		(*val log_tag = "Usuobj";*)
		val d_ltag = "Usuobj";

		val d_mf_filename = ref "";
		method get_d_mf_filename = !d_mf_filename;

		val d_path_ns = ref "";
		method get_d_path_ns = !d_path_ns;

		val d_hdr: Uberspark_manifest.Uobj.uobj_hdr_t = {f_namespace = ""; f_platform = ""; f_arch = ""; f_cpu = ""};
		method get_d_hdr = d_hdr;


		val d_sources_h_file_list: string list ref = ref [];
		method get_d_sources_h_file_list = !d_sources_h_file_list;

		val d_sources_c_file_list: string list ref = ref [];
		method get_d_sources_c_file_list = !d_sources_c_file_list;

		val d_sources_casm_file_list: string list ref = ref [];
		method get_d_sources_casm_file_list = !d_sources_casm_file_list;

		val d_publicmethods_hashtbl = ((Hashtbl.create 32) : ((string, uobj_publicmethods_t)  Hashtbl.t)); 
		method get_d_publicmethods_hashtbl = d_publicmethods_hashtbl;

		val d_callees_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t)); 
		method get_d_callees_hashtbl = d_callees_hashtbl;

		val d_interuobjcoll_callees_hashtbl = ((Hashtbl.create 32) : ((string, string list)  Hashtbl.t)); 
		method get_d_interuobjcoll_callees_hashtbl = d_interuobjcoll_callees_hashtbl;

		(* hashtbl of uobj sections as parsed from uobj manifest; indexed by section name *)		
		val d_sections_hashtbl = ((Hashtbl.create 32) : ((string, Defs.Basedefs.section_info_t)  Hashtbl.t)); 
		method get_d_sections_hashtbl = d_sections_hashtbl;

		(* hashtbl of uobj sections with memory map info; indexed by section name *)
		val d_sections_memory_map_hashtbl = ((Hashtbl.create 32) : ((string, Defs.Basedefs.section_info_t)  Hashtbl.t)); 
		method get_d_sections_memory_map_hashtbl = (d_sections_memory_map_hashtbl);

		(* hashtbl of uobj sections with memory map info; indexed by section virtual address*)
		val d_sections_memory_map_hashtbl_byorigin = ((Hashtbl.create 32) : ((int, Defs.Basedefs.section_info_t)  Hashtbl.t)); 
		method get_d_sections_memory_map_hashtbl_byorigin = (d_sections_memory_map_hashtbl_byorigin);


		val d_target_def: Defs.Basedefs.target_def_t = {
			f_platform = ""; 
			f_arch = ""; 
			f_cpu = "";
		};
		method get_d_target_def = d_target_def;
		method set_d_target_def 
			(target_def: Defs.Basedefs.target_def_t) = 
			d_target_def.f_platform <- target_def.f_platform;
			d_target_def.f_arch <- target_def.f_arch;
			d_target_def.f_cpu <- target_def.f_cpu;
			()
		;
			
		val d_slt_trampolinecode : string ref = ref "";
		method get_d_slt_trampolinecode = !d_slt_trampolinecode;
		method set_d_slt_trampolinecode (trampolinecode : string)= 
			d_slt_trampolinecode := trampolinecode;
			()
		;

		val d_slt_trampolinedata : string ref = ref "";
		method get_d_slt_trampolinedata = !d_slt_trampolinedata;
		method set_d_slt_trampolinedata (trampolinedata : string)= 
			d_slt_trampolinedata := trampolinedata;
			()
		;

		(* uobj load address base *)
		val d_load_addr = ref Uberspark_config.config_settings.binary_uobj_default_load_addr;
		method get_d_load_addr = !d_load_addr;
		method set_d_load_addr load_addr = (d_load_addr := load_addr);
		
		(* uobj size *)
		val d_size = ref Uberspark_config.config_settings.binary_uobj_default_size; 
		method get_d_size = !d_size;
		method set_d_size size = (d_size := size);

		method hashtbl_keys (h : (int, Defs.Basedefs.section_info_t) Hashtbl.t ) = Hashtbl.fold (fun key _ l -> key :: l) h [];


(*
		val usmf_type_usuobj = "uobj";


	
	
		val o_usmf_hdr_type = ref "";
		method get_o_usmf_hdr_type = !o_usmf_hdr_type;
		
		val o_usmf_hdr_subtype = ref "";
		method get_o_usmf_hdr_subtype = !o_usmf_hdr_subtype;

		val o_usmf_hdr_id = ref "";
		method get_o_usmf_hdr_id = !o_usmf_hdr_id;
		
		val o_usmf_hdr_platform = ref "";
		method get_o_usmf_hdr_platform = !o_usmf_hdr_platform;
		
		val o_usmf_hdr_cpu = ref "";
		method get_o_usmf_hdr_cpu = !o_usmf_hdr_cpu;

		val o_usmf_hdr_arch = ref "";
		method get_o_usmf_hdr_arch = !o_usmf_hdr_arch;
*)

		
	

(*	
		val o_uobj_publicmethods_sentinels_hashtbl = ((Hashtbl.create 32) : ((string, sentinel_info_t)  Hashtbl.t)); 
		method get_o_uobj_publicmethods_sentinels_hashtbl = o_uobj_publicmethods_sentinels_hashtbl;

		val o_uobj_publicmethods_sentinels_libname = ref "";
		method get_o_uobj_publicmethods_sentinels_libname = !o_uobj_publicmethods_sentinels_libname;

		val o_uobj_publicmethods_sentinels_lib_source_file_list : string list ref = ref [];
		method get_o_uobj_publicmethods_sentinels_lib_source_file_list = !o_uobj_publicmethods_sentinels_lib_source_file_list;



	


		val o_uobj_build_dirname = ref ".";
		method get_o_uobj_build_dirname = !o_uobj_build_dirname;
		
		(* uobj load address base *)
		val o_uobj_load_addr = ref 0;
		method get_o_uobj_load_addr = !o_uobj_load_addr;
		method set_o_uobj_load_addr load_addr = (o_uobj_load_addr := load_addr);

		(* uobj size *)
		val o_uobj_size = ref 0; 
		method get_o_uobj_size = !o_uobj_size;
		method set_o_uobj_size size = (o_uobj_size := size);

(*
		(* uobj section count *)
		val o_uobj_num_sections = ref 0; 
		method get_o_uobj_num_sections = !o_uobj_num_sections;
		method set_o_uobj_num_sections num_sections = (o_uobj_num_sections := num_sections);
*)

		(* base uobj sections hashtbl indexed by section name *)		
		val o_uobj_sections_hashtbl = ((Hashtbl.create 32) : ((string, Defs.Basedefs.section_info_t)  Hashtbl.t)); 
		method get_o_uobj_sections_hashtbl = (o_uobj_sections_hashtbl);
		method get_o_uobj_sections_hashtbl_length = (Hashtbl.length o_uobj_sections_hashtbl);
		
		(* hashtbl of uobj sections with memory map info indexed by section name *)
		val uobj_sections_memory_map_hashtbl = ((Hashtbl.create 32) : ((string, Defs.Basedefs.section_info_t)  Hashtbl.t)); 
		method get_uobj_sections_memory_map_hashtbl = (uobj_sections_memory_map_hashtbl);

		(* hashtbl of uobj sections with memory map info indexed by section va*)
		val uobj_sections_memory_map_hashtbl_byorigin = ((Hashtbl.create 32) : ((int, Defs.Basedefs.section_info_t)  Hashtbl.t)); 
		method get_uobj_sections_memory_map_hashtbl_byorigin = (uobj_sections_memory_map_hashtbl_byorigin);
		
		(* val mutable slab_idtoname = ((Hashtbl.create 32) : ((int,string)  Hashtbl.t)); *)

		val o_sentinels_source_file_list : string list ref = ref [];
		method get_o_sentinels_source_file_list = !o_sentinels_source_file_list;


		val o_pp_definition = ref "";
		method get_o_pp_definition = !o_pp_definition;

		val o_sentineltypes_hashtbl = ((Hashtbl.create 32) : ((string, Defs.Basedefs.uobjcoll_sentineltypes_t)  Hashtbl.t));
		method get_o_sentineltypes_hashtbl = o_sentineltypes_hashtbl;
*)
		
	

		
		(*--------------------------------------------------------------------------*)
		(* parse manifest node "uobj-sources" *)
		(* return true on successful parse, false if not *)
		(* return: if true then store lists of h-files, c-files and casm files *)
		(*--------------------------------------------------------------------------*)
		method parse_node_mf_uobj_sources mf_json =
			let retval = ref true in
			try
				let open Yojson.Basic.Util in
					let mf_uobj_sources_json = mf_json |> member "uobj-sources" in
					if mf_uobj_sources_json != `Null then
							begin

								let mf_hfiles_json = mf_uobj_sources_json |> member "h-files" in
									if mf_hfiles_json != `Null then
										begin
											let hfiles_json_list = mf_hfiles_json |> 
													to_list in 
												List.iter (fun x -> d_sources_h_file_list := 
														!d_sources_h_file_list @ [(x |> to_string)]
													) hfiles_json_list;
										end
									;

								let mf_cfiles_json = mf_uobj_sources_json |> member "c-files" in
									if mf_cfiles_json != `Null then
										begin
											let cfiles_json_list = mf_cfiles_json |> 
													to_list in 
												List.iter (fun x -> d_sources_c_file_list := 
														!d_sources_c_file_list @ [(x |> to_string)]
													) cfiles_json_list;
										end
									;

								let mf_casmfiles_json = mf_uobj_sources_json |> member "casm-files" in
									if mf_casmfiles_json != `Null then
										begin
											let casmfiles_json_list = mf_casmfiles_json |> 
													to_list in 
												List.iter (fun x -> d_sources_casm_file_list := 
														!d_sources_casm_file_list @ [(x |> to_string)]
													) casmfiles_json_list;
										end
									;
									
							end
						;
						
			with Yojson.Basic.Util.Type_error _ -> 
					retval := false;
			;
		
			(!retval)
		;
	

	  (*--------------------------------------------------------------------------*)
		(* parse manifest node "uobj-publicmethods" *)
		(* return true on successful parse, false if not *)
		(* return: if true then list public methods *)
		(*--------------------------------------------------------------------------*)
		method parse_node_mf_uobj_publicmethods mf_json =
			let retval = ref false in

			try
				let open Yojson.Basic.Util in
					let uobj_publicmethods_json = mf_json |> member "uobj-publicmethods" in
						if uobj_publicmethods_json != `Null then
							begin

								let uobj_publicmethods_assoc_list = Yojson.Basic.Util.to_assoc uobj_publicmethods_json in
									retval := true;
									
									List.iter (fun (x,y) ->
										let uobj_publicmethods_inner_list = (Yojson.Basic.Util.to_list y) in 
										if (List.length uobj_publicmethods_inner_list) <> 3 then
											begin
												retval := false;
											end
										else
											begin
												Hashtbl.add d_publicmethods_hashtbl (x) 
												{
													f_name = x;
													f_retvaldecl = (List.nth uobj_publicmethods_inner_list 0) |> to_string;
													f_paramdecl = (List.nth uobj_publicmethods_inner_list 1) |> to_string;
													f_paramdwords = int_of_string ((List.nth uobj_publicmethods_inner_list 2) |> to_string );
												};
														
												retval := true; 
											end
										;
							
										()
									) uobj_publicmethods_assoc_list;

							end
						;
																
			with Yojson.Basic.Util.Type_error _ -> 
					retval := false;
			;

									
			(!retval)
		;


		(*--------------------------------------------------------------------------*)
		(* parse manifest node "uobj-callees" *)
		(* return true on successful parse, false if not *)
		(* return: if true then populate hashtable of callees*)
		(*--------------------------------------------------------------------------*)
		method parse_node_mf_uobj_callees mf_json =
			let retval = ref true in

			try
				let open Yojson.Basic.Util in
					let uobj_callees_json = mf_json |> member "intrauobjcoll-callees" in
						if uobj_callees_json != `Null then
							begin

								let uobj_callees_assoc_list = Yojson.Basic.Util.to_assoc uobj_callees_json in
									retval := true;
									List.iter (fun (x,y) ->
											let uobj_callees_attribute_list = ref [] in
												List.iter (fun z ->
													uobj_callees_attribute_list := !uobj_callees_attribute_list @
																			[ (z |> to_string) ];
													()
												)(Yojson.Basic.Util.to_list y);
												
												Hashtbl.add d_callees_hashtbl x !uobj_callees_attribute_list;
											()
										) uobj_callees_assoc_list;
							end
						;
																
			with Yojson.Basic.Util.Type_error _ -> 
					retval := false;
			;

									
			(!retval)
		;



		(*--------------------------------------------------------------------------*)
		(* parse manifest node "interuobjcoll-callees" *)
		(* return true on successful parse, false if not *)
		(* return: if true then populate list of exitcallees function names *)
		(*--------------------------------------------------------------------------*)
		method parse_node_mf_uobj_interuobjcoll_callees mf_json =
			let retval = ref true in

			try
				let open Yojson.Basic.Util in
					let uobj_callees_json = mf_json |> member "interuobjcoll-callees" in
						if uobj_callees_json != `Null then
							begin

								let uobj_callees_assoc_list = Yojson.Basic.Util.to_assoc uobj_callees_json in
									retval := true;
									List.iter (fun (x,y) ->
											let uobj_callees_attribute_list = ref [] in
												List.iter (fun z ->
													uobj_callees_attribute_list := !uobj_callees_attribute_list @
																			[ (z |> to_string) ];
													()
												)(Yojson.Basic.Util.to_list y);
												
												Hashtbl.add d_interuobjcoll_callees_hashtbl x !uobj_callees_attribute_list;
											()
										) uobj_callees_assoc_list;
							end
						;
																
			with Yojson.Basic.Util.Type_error _ -> 
					retval := false;
			;

									
			(!retval)
		;


		(*--------------------------------------------------------------------------*)
		(* parse manifest node "uobj-binary/uobj-sections" *)
		(* return true on successful parse, false if not *)
		(* return: if true then populate list of sections *)
		(*--------------------------------------------------------------------------*)
		method parse_node_mf_uobj_binary mf_json =
		let retval = ref false in

		try
		let open Yojson.Basic.Util in
			let uobj_binary_json = mf_json |> member "uobj-binary" in
				if uobj_binary_json != `Null then
					begin

						let uobj_sections_json = uobj_binary_json |> member "uobj-sections" in
							if uobj_sections_json != `Null then
								begin
									
									let uobj_sections_assoc_list = Yojson.Basic.Util.to_assoc uobj_sections_json in
										retval := true;
										List.iter (fun (x,y) ->
												(* x = section name, y = list of section attributes *)
												let uobj_sections_attribute_list = (Yojson.Basic.Util.to_list y) in
													if (List.length uobj_sections_attribute_list  < 6 ) then
														begin
															Uberspark_logger.log ~lvl:Uberspark_logger.Error "insufficient entries within section attribute list for section: %s" x;															retval := false;
														end
													else
														begin
															let subsection_list = ref [] in 
															for index = 5 to ((List.length uobj_sections_attribute_list)-1) do 
																subsection_list := !subsection_list @	[ ((List.nth uobj_sections_attribute_list index) |> to_string) ]
															done;

															Hashtbl.add d_sections_hashtbl (x) 
															{ 
																f_name = (x);	
															 	f_subsection_list = !subsection_list;	
																usbinformat = { f_type = int_of_string ((List.nth uobj_sections_attribute_list 0) |> to_string); 
																								f_prot = int_of_string ((List.nth uobj_sections_attribute_list 1) |> to_string); 
																								f_size = int_of_string ((List.nth uobj_sections_attribute_list 2) |> to_string);
																								f_aligned_at = int_of_string ((List.nth uobj_sections_attribute_list 3) |> to_string); 
																								f_pad_to = int_of_string ((List.nth uobj_sections_attribute_list 4) |> to_string); 
																								f_addr_start=0; 
																								f_addr_file = 0;
																								f_reserved = 0;
																							};
															};
								
															retval := true;
														end
													;
												()
											) uobj_sections_assoc_list;
								end
							;		
				
					end
				;
														
		with Yojson.Basic.Util.Type_error _ -> 
			retval := false;
		;

							
		(!retval)
		;




		(*--------------------------------------------------------------------------*)
		(* parse uobj manifest *)
		(* usmf_filename = canonical uobj manifest filename *)
		(* keep_temp_files = true if temporary files need to be preserved *)
		(*--------------------------------------------------------------------------*)
		method parse_manifest 
			(uobj_mf_filename : string)
			(keep_temp_files : bool) 
			: bool =
			
			(* store filename and uobj path/namespace *)
			d_mf_filename := Filename.basename uobj_mf_filename;
			d_path_ns := Filename.dirname uobj_mf_filename;
			
			(* read manifest JSON *)
			let (rval, mf_json) = Uberspark_manifest.get_manifest_json self#get_d_mf_filename in
			
			if (rval == false) then (false)
			else

			(* parse uobj-hdr node *)
			let rval = (Uberspark_manifest.Uobj.parse_uobj_hdr mf_json d_hdr ) in
			if (rval == false) then (false)
			else

			(* parse uobj-sources node *)
			let rval = (self#parse_node_mf_uobj_sources mf_json) in
	
			if (rval == false) then (false)
			else
			let dummy = 0 in
				begin
					Uberspark_logger.log "total sources: h files=%u, c files=%u, casm files=%u" 
						(List.length self#get_d_sources_h_file_list)
						(List.length self#get_d_sources_c_file_list)
						(List.length self#get_d_sources_casm_file_list);
				end;


			(* parse uobj-publicmethods node *)
			let rval = (self#parse_node_mf_uobj_publicmethods mf_json) in

			if (rval == false) then (false)
			else
			let dummy = 0 in
				begin
					Uberspark_logger.log "total public methods:%u" (Hashtbl.length self#get_d_publicmethods_hashtbl); 
				end;

			(* parse uobj-calles node *)
			let rval = (self#parse_node_mf_uobj_callees mf_json) in

			if (rval == false) then (false)
			else
			let dummy = 0 in
				begin
					Uberspark_logger.log "list of uobj-callees follows:";

					Hashtbl.iter (fun key value  ->
						Uberspark_logger.log "uobj=%s; callees=%u" key (List.length value);
					) self#get_d_callees_hashtbl;
				end;

			(* parse uobj-exitcallees node *)
			let rval = (self#parse_node_mf_uobj_interuobjcoll_callees mf_json) in

			if (rval == false) then (false)
			else
			let dummy = 0 in
				begin
					Uberspark_logger.log "total interuobjcoll callees=%u" (Hashtbl.length self#get_d_interuobjcoll_callees_hashtbl);
				end;


			(* parse uobj-binary/uobj-sections node *)
			let rval = (self#parse_node_mf_uobj_binary mf_json) in

			if (rval == false) then (false)
			else
			let dummy = 0 in
			if (rval == true) then
				begin
					Uberspark_logger.log "binary sections override:%u" (Hashtbl.length self#get_d_sections_hashtbl);								
				end;
	
(*																											
			(* initialize uobj preprocess definition *)
			o_pp_definition := "__UOBJ_" ^ self#get_o_usmf_hdr_id ^ "__";

			(* initialize uobj sentinels lib name *)
			o_uobj_publicmethods_sentinels_libname := "lib" ^ (self#get_o_usmf_hdr_id) ^ "-" ^
				!o_usmf_hdr_platform ^ "-" ^ !o_usmf_hdr_cpu ^ "-" ^ !o_usmf_hdr_arch;
	
				*)
				
			(true)
		;



		(*(*--------------------------------------------------------------------------*)
		(* generate sentinel linkage table symbols*)
		(*--------------------------------------------------------------------------*)
		method generate_slt_symbols	
			: bool	= 
				let retval = ref false in

				let oc = open_out Uberspark_config.namespace_uobjslt_output_symbols_filename in
					Printf.fprintf oc "\n/* --- this file is autogenerated --- */";
					Printf.fprintf oc "\n/* uberSpark sentinel linkage table - symbols */";
					Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n{";
					Printf.fprintf oc "\n\t\"hdr\":{";
					Printf.fprintf oc "\n\t\"type\" : \"uobjslt_symbols\",";
					Printf.fprintf oc "\n\t\"namespace\" : \"%s\"," (self#get_d_hdr).f_namespace;
					Printf.fprintf oc "\n\t\"platform\" : \"%s\"," (self#get_d_targetdef).f_platform;
					Printf.fprintf oc "\n\t\"arch\" : \"%s\"," (self#get_d_targetdef).f_arch;
					Printf.fprintf oc "\n\t\"cpu\" : \"%s\"" (self#get_d_targetdef).f_cpu;
					Printf.fprintf oc "\n\t},";
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n\t\"uobjslt-callees\": [";
					for index = 0 to ((List.length self#get_d_exitcalles_list)-1) do 
						if ( index == (List.length self#get_d_exitcalles_list)-1 ) then
							begin	
								Printf.fprintf oc "\n\t\t\"%s\"" (List.nth self#get_d_exitcalles_list index);
							end
						else
							begin
								Printf.fprintf oc "\n\t\t\"%s\"," (List.nth self#get_d_exitcalles_list index);
							end
						;
					done;
					Printf.fprintf oc "\n\t],";
					Printf.fprintf oc "\n";

					Printf.fprintf oc "\n}";

				close_out oc;	


				retval := true;
				(!retval)
			;
		*)

		(*--------------------------------------------------------------------------*)
		(* generate sentinel linkage table *)
		(*--------------------------------------------------------------------------*)
		method generate_slt	
			(fn_list: string list)
			(output_section_name_code : string)
			(output_section_name_data : string)
			(output_filename : string)
			: bool	= 
				let retval = ref false in
				
				Uberspark_logger.log ~lvl:Uberspark_logger.Debug "fn_list length=%u" (List.length fn_list);
				let oc = open_out output_filename in
					Printf.fprintf oc "\n/* --- this file is autogenerated --- */";
					Printf.fprintf oc "\n/* uberSpark sentinel linkage table */";
					Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n/* --- trampoline data follows --- */";
					Printf.fprintf oc "\n.section %s" output_section_name_data;
					Printf.fprintf oc "\n.global uobjslt_trampolinedata";
					Printf.fprintf oc "\nuobjslt_trampolinedata:";
					let tdata_0 = Str.global_replace (Str.regexp "TOTAL_TRAMPOLINES") "2" (self#get_d_slt_trampolinedata) in
					let tdata = Str.global_replace (Str.regexp "SIZEOF_TRAMPOLINE_ENTRY") "4" tdata_0 in
					Printf.fprintf oc "\n%s" (tdata);
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n/* --- trampoline code follows --- */";
					Printf.fprintf oc "\n";
					Printf.fprintf oc "\n";


					for index=0 to (List.length fn_list - 1) do 
						Printf.fprintf oc "\n";
						Printf.fprintf oc "\n.section %s" output_section_name_code;
						Printf.fprintf oc "\n.global %s" (List.nth fn_list index);
						Printf.fprintf oc "\n%s:" (List.nth fn_list index);
						let tcode = Str.global_replace (Str.regexp "TRAMPOLINE_FN_INDEX") (string_of_int index) (self#get_d_slt_trampolinecode) in
						Printf.fprintf oc "\n%s" tcode;
	
						Printf.fprintf oc "\n";
					done;

				close_out oc;	

				retval := true;
				(!retval)
			;

			



		(*--------------------------------------------------------------------------*)
		(* parse sentinel linkage manifest *)
		(*--------------------------------------------------------------------------*)
		method parse_manifest_slt	
			(*(fn_list: string list)*)
				= 
				let retval = ref false in 	
				let target_def = 	self#get_d_target_def in	
				let uobjslt_filename = (Uberspark_config.namespace_uobjslt ^ "/" ^
					target_def.f_arch ^ "/" ^ target_def.f_cpu ^ "/" ^
					Uberspark_config.namespace_uobjslt_mf_filename) in 

				let (rval, abs_uobjslt_filename) = (Uberspark_osservices.abspath uobjslt_filename) in
				if(rval == true) then
				begin
					(*Uberspark_logger.log ~lvl:Uberspark_logger.Debug "fn_list length=%u" (List.length fn_list);*)
					Uberspark_logger.log "reading slt manifest from:%s" abs_uobjslt_filename;
	
					(* read manifest JSON *)
					let (rval, mf_json) = (Uberspark_manifest.get_manifest_json abs_uobjslt_filename) in
					if(rval == true) then
					begin

						(* parse uobjslt-hdr node *)
						let uobjslt_hdr: Uberspark_manifest.Uobjslt.uobjslt_hdr_t = {f_namespace = ""; f_platform = ""; f_arch = ""; f_cpu = ""} in
						let rval =	(Uberspark_manifest.Uobjslt.parse_uobjslt_hdr mf_json uobjslt_hdr) in
						if rval then
						begin

							(* read trampoline code and data *)
							let (rval_tcode, tcode) =	(Uberspark_manifest.Uobjslt.parse_uobjslt_trampolinecode mf_json) in
							let (rval_tdata, tdata) =	(Uberspark_manifest.Uobjslt.parse_uobjslt_trampolinedata mf_json) in

							if  rval_tcode && rval_tdata then
								begin
									self#set_d_slt_trampolinecode tcode;
									self#set_d_slt_trampolinedata tdata;
									retval := true;
									(*Uberspark_logger.log "code=%s" (uobjslt_trampolinecode_json |> to_string);								
									Uberspark_logger.log "data=%s" (uobjslt_trampolinedata_json |> to_string);*)								
								end;

						end;
					end;
				end;


(*								

				

				else

				let dummy = 0 in
				begin
					(* read node for trampoline code *)
					try
						let open Yojson.Basic.Util in
						let uobj_binary_json = mf_json |> member "uobj-binary" in
						if uobj_binary_json != `Null then

					Uberspark_logger.log "success";
				end;

				(* read node for trampoline code *)
				try
				let open Yojson.Basic.Util in
					let uobj_binary_json = usmf_json |> member "uobj-binary" in
						if uobj_binary_json != `Null then
							begin
	
								let uobj_sections_json = uobj_binary_json |> member "uobj-sections" in
									if uobj_sections_json != `Null then
										begin
											let uobj_sections_assoc_list = Yojson.Basic.Util.to_assoc uobj_sections_json in
												retval := true;
												List.iter (fun (x,y) ->
														Uberspark_logger.logf log_tag Uberspark_logger.Debug "%s: key=%s" __LOC__ x;
														let uobj_section_attribute_list = ref [] in
															uobj_section_attribute_list := !uobj_section_attribute_list @
																						[ x ];
															List.iter (fun z ->
																uobj_section_attribute_list := !uobj_section_attribute_list @
																						[ (z |> to_string) ];
																()
															)(Yojson.Basic.Util.to_list y);
															
															uobj_sections_list := !uobj_sections_list @	[ !uobj_section_attribute_list ];
															if (List.length (Yojson.Basic.Util.to_list y)) < 3 then
																retval:=false;
														()
													) uobj_sections_assoc_list;
												Uberspark_logger.logf log_tag Uberspark_logger.Debug "%s: list length=%u" __LOC__ (List.length !uobj_sections_list);
										end
									;		
						
							end
						;
																
			with Yojson.Basic.Util.Type_error _ -> 
					retval := false;
			;
	
	*)			


		(!retval)
		;


			(*--------------------------------------------------------------------------*)
			(* generate uobj binary header source *)
			(*--------------------------------------------------------------------------*)
			method generate_src_binhdr = 

				(* open binary header source file *)
				let oc = open_out Uberspark_config.namespace_uobj_binhdr_src_filename in
				
				(* generate prologue *)
				Printf.fprintf oc "\n/* autogenerated uberSpark uobj binary header source */";
				Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n#include <uberspark.h>";
				Printf.fprintf oc "\n#include <usbinformat.h>";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";

				Printf.fprintf oc "\n__attribute__(( section(\".binhdr\") )) __attribute__((aligned(4096))) usbinformat_uobj_hdr_t uobj_hdr = {";

				(* generate common header *)
				(* hdr *)
				Printf.fprintf oc "\n\t{"; 
				(*magic*)
				Printf.fprintf oc "\n\t\tUSBINFORMAT_HDR_MAGIC_UOBJ,"; 
				(*num_sections*)
				Printf.fprintf oc "\n\t\t0x%08xUL," (Hashtbl.length self#get_d_sections_hashtbl);
				(*page_size*)
				Printf.fprintf oc "\n\t\t0x%08xUL," Uberspark_config.config_settings.binary_page_size; 
				(*aligned_at*)
				Printf.fprintf oc "\n\t\t0x%08xUL," Uberspark_config.config_settings.binary_page_size; 
				(*pad_to*)
				Printf.fprintf oc "\n\t\t0x%08xUL," Uberspark_config.config_settings.binary_page_size; 
				(*size*)
				Printf.fprintf oc "\n\t\t0x%08xULL," (self#get_d_size); 
				Printf.fprintf oc "\n\t},"; 
				(* load_addr *)
				Printf.fprintf oc "\n\t0x%08xULL," (self#get_d_load_addr); 
				(* load_size *)
				Printf.fprintf oc "\n\t0x%08xULL," (self#get_d_size); 
				
				(* generate uobj section defs *)
				Printf.fprintf oc "\n\t{"; 
				
				Hashtbl.iter (fun key (section_info:Defs.Basedefs.section_info_t) ->  
					Printf.fprintf oc "\n\t\t{"; 
					(* type *)
					Printf.fprintf oc "\n\t\t\t0x%08xUL," (section_info.usbinformat.f_type); 
					(* prot *)
					Printf.fprintf oc "\n\t\t\t0x%08xUL," (section_info.usbinformat.f_prot); 
					(* size *)
					Printf.fprintf oc "\n\t\t\t0x%016xULL," (section_info.usbinformat.f_size); 
					(* aligned_at *)
					Printf.fprintf oc "\n\t\t\t0x%08xUL," (section_info.usbinformat.f_aligned_at); 
					(* pad_to *)
					Printf.fprintf oc "\n\t\t\t0x%08xUL," (section_info.usbinformat.f_pad_to); 
					(* addr_start *)
					Printf.fprintf oc "\n\t\t\t0x%016xULL," (section_info.usbinformat.f_addr_start); 
					(* addr_file *)
					Printf.fprintf oc "\n\t\t\t0x%016xULL," (section_info.usbinformat.f_addr_file); 
					(* reserved *)
					Printf.fprintf oc "\n\t\t\t0ULL"; 
					Printf.fprintf oc "\n\t\t},"; 
				) self#get_d_sections_hashtbl;
				
				Printf.fprintf oc "\n\t},"; 

				(* generate epilogue *)
				Printf.fprintf oc "\n};";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";

				close_out oc;

				()
		;


			(*--------------------------------------------------------------------------*)
			(* generate uobj publicmethods info  *)
			(*--------------------------------------------------------------------------*)
			method generate_src_publicmethods_info = 

				(* open public methods info source file *)
				let oc = open_out Uberspark_config.namespace_uobj_publicmethods_info_src_filename in
				
				(* generate prologue *)
				Printf.fprintf oc "\n/* autogenerated uberSpark uobj public methods info source */";
				Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n#include <uberspark.h>";
				Printf.fprintf oc "\n#include <usbinformat.h>";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";

				Printf.fprintf oc "\n__attribute__(( section(\".pminfo\") )) __attribute__((aligned(4096))) usbinformat_uobj_publicmethod_info_t uobj_pminfo = {";

				(*num_publicmethods*)
				Printf.fprintf oc "\n\t\t0x%08xUL," (Hashtbl.length self#get_d_publicmethods_hashtbl);
				
				(* generate uobj public methods defs *)
				Printf.fprintf oc "\n\t{"; 
				
				Hashtbl.iter (fun key (pm_info:uobj_publicmethods_t) ->  
					Printf.fprintf oc "\n\t\t{"; 
					(* name *)
					Printf.fprintf oc "\n\t\t\t\"%s\"," (pm_info.f_name); 
					(* vaddr *)
					Printf.fprintf oc "\n\t\t\t&%s," (pm_info.f_name); 
					Printf.fprintf oc "\n\t\t},"; 
				) self#get_d_publicmethods_hashtbl;
				
				Printf.fprintf oc "\n\t},"; 

				(* generate epilogue *)
				Printf.fprintf oc "\n};";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";

				close_out oc;

				()
		;



		(*--------------------------------------------------------------------------*)
		(* generate uobj intrauobjcoll-callees info  *)
		(*--------------------------------------------------------------------------*)
		method generate_src_intrauobjcoll_callees_info = 

			(* open public methods info source file *)
			let oc = open_out Uberspark_config.namespace_uobj_intrauobjcoll_callees_info_src_filename in
			
			(* generate prologue *)
			Printf.fprintf oc "\n/* autogenerated uberSpark uobj intrauobjcoll callees info source */";
			Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n#include <uberspark.h>";
			Printf.fprintf oc "\n#include <usbinformat.h>";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";

			Printf.fprintf oc "\n__attribute__(( section(\".intrauobjcollcalleesinfo\") )) __attribute__((aligned(4096))) usbinformat_uobj_intrauobjcoll_callees_info_t uobj_intrauobjcoll_callees = {";

			(*num_intrauobjcoll_callees*)
			let num_intrauobjcoll_callees = ref 0 in
			Hashtbl.iter (fun key value  ->
				num_intrauobjcoll_callees := !num_intrauobjcoll_callees + (List.length value);
			) self#get_d_callees_hashtbl;
			Printf.fprintf oc "\n\t\t0x%08xUL," !num_intrauobjcoll_callees;
			
			(* generate uobj public methods defs *)
			Printf.fprintf oc "\n\t{"; 

			let slt_ordinal = ref 0 in
			Hashtbl.iter (fun key value ->  
				List.iter (fun pm_name -> 
					Printf.fprintf oc "\n\t\t{"; 
					
					(* uobj_ns *)
					Printf.fprintf oc "\n\t\t\t\"%s\"," key; 
					(* pm_name *)
					Printf.fprintf oc "\n\t\t\t\"%s\"," pm_name; 
					(* slt_ordinal *)
					Printf.fprintf oc "\n\t\t0x%08xUL," !slt_ordinal;
					
					Printf.fprintf oc "\n\t\t},"; 
					slt_ordinal := !slt_ordinal + 1;
				) value;
			) self#get_d_callees_hashtbl;
			
			Printf.fprintf oc "\n\t},"; 

			(* generate epilogue *)
			Printf.fprintf oc "\n};";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";

			close_out oc;

			()
		;



		(*--------------------------------------------------------------------------*)
		(* generate uobj interuobjcoll-callees info  *)
		(*--------------------------------------------------------------------------*)
		method generate_src_interuobjcoll_callees_info = 

			(* open interuobjcoll callees info source file *)
			let oc = open_out Uberspark_config.namespace_uobj_interuobjcoll_callees_info_src_filename in
			
			(* generate prologue *)
			Printf.fprintf oc "\n/* autogenerated uberSpark uobj interuobjcoll callees info source */";
			Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n#include <uberspark.h>";
			Printf.fprintf oc "\n#include <usbinformat.h>";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";

			Printf.fprintf oc "\n__attribute__(( section(\".interuobjcollcalleesinfo\") )) __attribute__((aligned(4096))) usbinformat_uobj_interuobjcoll_callees_info_t uobj_interuobjcoll_callees = {";

			(*num_interuobjcoll_callees*)
			let num_interuobjcoll_callees = ref 0 in
			Hashtbl.iter (fun key value  ->
				num_interuobjcoll_callees := !num_interuobjcoll_callees + (List.length value);
			) self#get_d_interuobjcoll_callees_hashtbl;
			Printf.fprintf oc "\n\t\t0x%08xUL," !num_interuobjcoll_callees;
			
			(* generate interuobjcoll callee defs *)
			Printf.fprintf oc "\n\t{"; 

			let slt_ordinal = ref 0 in
			Hashtbl.iter (fun key value ->  
				List.iter (fun pm_name -> 
					Printf.fprintf oc "\n\t\t{"; 
					
					(* uobj_ns *)
					Printf.fprintf oc "\n\t\t\t\"%s\"," key; 
					(* pm_name *)
					Printf.fprintf oc "\n\t\t\t\"%s\"," pm_name; 
					(* slt_ordinal *)
					Printf.fprintf oc "\n\t\t0x%08xUL," !slt_ordinal;
					
					Printf.fprintf oc "\n\t\t},"; 
					slt_ordinal := !slt_ordinal + 1;
				) value;
			) self#get_d_interuobjcoll_callees_hashtbl;
			
			Printf.fprintf oc "\n\t},"; 

			(* generate epilogue *)
			Printf.fprintf oc "\n};";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";

			close_out oc;
			()
		;


		(*--------------------------------------------------------------------------*)
		(* generate uobj linker script *)
		(*--------------------------------------------------------------------------*)
		method generate_linker_script 
			(binary_origin : int)
			(binary_size : int)
			(sections_hashtbl : (int, Defs.Basedefs.section_info_t) Hashtbl.t) 
	 		 =
		
			let oc = open_out Uberspark_config.namespace_uobj_linkerscript_filename in
				Printf.fprintf oc "\n/* autogenerated uberSpark uobj linker script */";
				Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\nOUTPUT_ARCH(\"i386\")";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";

				Printf.fprintf oc "\nMEMORY";
				Printf.fprintf oc "\n{";
		
				let keys = List.sort compare (self#hashtbl_keys sections_hashtbl) in				
				List.iter (fun key ->
						let x = Hashtbl.find sections_hashtbl key in
						(* new section memory *)
						Printf.fprintf oc "\n %s (%s) : ORIGIN = 0x%08x, LENGTH = 0x%08x"
							("mem_" ^ x.f_name)
							( "rw" ^ "ail") (x.usbinformat.f_addr_start) (x.usbinformat.f_size);
						()
				) keys ;

				Printf.fprintf oc "\n}";
				Printf.fprintf oc "\n";
			
					
				Printf.fprintf oc "\nSECTIONS";
				Printf.fprintf oc "\n{";
				Printf.fprintf oc "\n";
		
				let keys = List.sort compare (self#hashtbl_keys sections_hashtbl) in				

				let i = ref 0 in 			
				while (!i < List.length keys) do
					let key = (List.nth keys !i) in
					let x = Hashtbl.find sections_hashtbl key in
						(* new section *)
						if(!i == (List.length keys) - 1 ) then 
							begin
								Printf.fprintf oc "\n %s : {" x.f_name;
								Printf.fprintf oc "\n	%s_START_ADDR = .;" x.f_name;
								List.iter (fun subsection ->
											Printf.fprintf oc "\n *(%s)" subsection;
								) x.f_subsection_list;
								Printf.fprintf oc "\n . = ORIGIN(%s) + LENGTH(%s) - 1;" ("mem_" ^ x.f_name) ("mem_" ^ x.f_name);
								Printf.fprintf oc "\n BYTE(0xAA)";
								Printf.fprintf oc "\n	%s_END_ADDR = .;" x.f_name;
								Printf.fprintf oc "\n	} >%s =0x9090" ("mem_" ^ x.f_name);
								Printf.fprintf oc "\n";
							end
						else
							begin
								Printf.fprintf oc "\n %s : {" x.f_name;
								Printf.fprintf oc "\n	%s_START_ADDR = .;" x.f_name;
								List.iter (fun subsection ->
											Printf.fprintf oc "\n *(%s)" subsection;
								) x.f_subsection_list;
								Printf.fprintf oc "\n . = ORIGIN(%s) + LENGTH(%s) - 1;" ("mem_" ^ x.f_name) ("mem_" ^ x.f_name);
								Printf.fprintf oc "\n BYTE(0xAA)";
								Printf.fprintf oc "\n	%s_END_ADDR = .;" x.f_name;
								Printf.fprintf oc "\n	} >%s =0x9090" ("mem_" ^ x.f_name);
								Printf.fprintf oc "\n";
							end
						;
				
					i := !i + 1;
				done;
							
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n	/* this is to cause the link to fail if there is";
				Printf.fprintf oc "\n	* anything we didn't explicitly place.";
				Printf.fprintf oc "\n	* when this does cause link to fail, temporarily comment";
				Printf.fprintf oc "\n	* this part out to see what sections end up in the output";
				Printf.fprintf oc "\n	* which are not handled above, and handle them.";
				Printf.fprintf oc "\n	*/";
				Printf.fprintf oc "\n	/DISCARD/ : {";
				Printf.fprintf oc "\n	*(*)";
				Printf.fprintf oc "\n	}";
				Printf.fprintf oc "\n}";
				Printf.fprintf oc "\n";
																																																																																																																										
				close_out oc;
				()
		;
		


		(*--------------------------------------------------------------------------*)
		(* consolidate sections with memory map *)
		(* uobj_load_addr = load address of uobj *)
		(*--------------------------------------------------------------------------*)
		method consolidate_sections_with_memory_map
			(uobj_load_addr : int)
			(uobjsize : int)  
			=

			let uobj_section_load_addr = ref 0 in
			self#set_d_load_addr uobj_load_addr;
			uobj_section_load_addr := uobj_load_addr;

			(* iterate over all the sections *)
			Hashtbl.iter (fun key (x:Defs.Basedefs.section_info_t)  ->
				(* compute and round up section size to section alignment *)
				let remainder_size = (x.usbinformat.f_size mod Uberspark_config.config_settings.binary_uobj_section_alignment) in
				let padding_size = ref 0 in
					if remainder_size > 0 then
						begin
							padding_size := Uberspark_config.config_settings.binary_uobj_section_alignment - remainder_size;
						end
					else
						begin
							padding_size := 0;
						end
					;
				let section_size = (x.usbinformat.f_size + !padding_size) in 


				Hashtbl.add d_sections_memory_map_hashtbl key 
					{ f_name = x.f_name;	
					 	f_subsection_list = x.f_subsection_list;	
						usbinformat = { f_type=x.usbinformat.f_type; 
														f_prot=0; 
														f_size = section_size;
														f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
														f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
														f_addr_start = !uobj_section_load_addr; 
														f_addr_file = 0;
														f_reserved = 0;
													};
					};
				Hashtbl.add d_sections_memory_map_hashtbl_byorigin !uobj_section_load_addr 
					{ f_name = x.f_name;	
					 	f_subsection_list = x.f_subsection_list;	
						usbinformat = { f_type=x.usbinformat.f_type; 
														f_prot=0; 
														f_size = section_size;
														f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
														f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
														f_addr_start = !uobj_section_load_addr; 
														f_addr_file = 0;
														f_reserved = 0;
												};
					};

				Uberspark_logger.log "section at address 0x%08x, size=0x%08x padding=0x%08x" !uobj_section_load_addr section_size !padding_size;
				uobj_section_load_addr := !uobj_section_load_addr + section_size;
			)  self#get_d_sections_hashtbl;

			(* check to see if the uobj sections fit neatly into uobj size *)
			(* if not, add a filler section to pad it to uobj size *)
			if (!uobj_section_load_addr - uobj_load_addr) > uobjsize then
				begin
					Uberspark_logger.log ~lvl:Uberspark_logger.Error "uobj total section sizes (0x%08x) span beyond uobj size (0x%08x)!" (!uobj_section_load_addr - uobj_load_addr) uobjsize;
					ignore(exit 1);
				end
			;	

			if (!uobj_section_load_addr - uobj_load_addr) < uobjsize then
				begin
					(* add padding section *)
					Hashtbl.add d_sections_memory_map_hashtbl "usuobj_padding" 
						{ f_name = "usuobj_padding";	
						 	f_subsection_list = [ ];	
							usbinformat = { f_type = Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_PADDING;
															f_prot=0; 
															f_size = (uobjsize - (!uobj_section_load_addr - uobj_load_addr));
															f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
															f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
															f_addr_start = !uobj_section_load_addr; 
															f_addr_file = 0;
															f_reserved = 0;
														};
						};
					Hashtbl.add d_sections_memory_map_hashtbl_byorigin !uobj_section_load_addr 
						{ f_name = "usuobj_padding";	
						 	f_subsection_list = [ ];	
							usbinformat = { f_type = Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_PADDING;
															f_prot=0; 
															f_size = (uobjsize - (!uobj_section_load_addr - uobj_load_addr));
															f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
															f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
															f_addr_start = !uobj_section_load_addr; 
															f_addr_file = 0;
															f_reserved = 0;
														};
						};
				end
			;	
						
			self#set_d_size uobjsize;
			()
		;



		(*--------------------------------------------------------------------------*)
		(* initialize *)
		(*--------------------------------------------------------------------------*)
		method initialize	
			(target_def: Defs.Basedefs.target_def_t)
			= 
			(* set target definition *)
			self#set_d_target_def target_def;	

			(* debug dump the target spec and definition *)		
			Uberspark_logger.log ~lvl:Uberspark_logger.Debug "uobj target spec => %s:%s:%s" 
					(self#get_d_hdr).f_platform (self#get_d_hdr).f_arch (self#get_d_hdr).f_cpu;
			Uberspark_logger.log ~lvl:Uberspark_logger.Debug "uobj target definition => %s:%s:%s" 
					(self#get_d_target_def).f_platform (self#get_d_target_def).f_arch (self#get_d_target_def).f_cpu;

			(* parse uobj slt manifest *)
			let rval = (self#parse_manifest_slt) in	
			if (rval == false) then
				begin
					Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to stat/parse uobj slt manifest!";
					ignore (exit 1);
				end
			;


			(* generate slt for callees *)
			let callees_list = ref [] in 
			Hashtbl.iter (fun key value  ->
				callees_list := !callees_list @ value;
			) self#get_d_callees_hashtbl;
			Uberspark_logger.log "total callees=%u" (List.length !callees_list);

			let rval = (self#generate_slt !callees_list ".uobjslt_callees_tcode" ".uobjslt_callees_tdata" Uberspark_config.namespace_uobjslt_callees_output_filename) in	
			if (rval == false) then
				begin
					Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to generate slt for callees!";
					ignore (exit 1);
				end
			;


			(* generate slt for interuobjcoll callees *)
			let interuobjcoll_callees_list = ref [] in
			Hashtbl.iter (fun key value ->
				interuobjcoll_callees_list := !interuobjcoll_callees_list @ value;
			)self#get_d_interuobjcoll_callees_hashtbl;
			Uberspark_logger.log "total interuobjcoll callees=%u" (List.length !interuobjcoll_callees_list);

			let rval = (self#generate_slt !interuobjcoll_callees_list ".uobjslt_exitcallees_tcode" ".uobjslt_exitcallees_tdata" Uberspark_config.namespace_uobjslt_exitcallees_output_filename) in	
			if (rval == false) then
				begin
					Uberspark_logger.log ~lvl:Uberspark_logger.Error "unable to generate slt for exitcallees!";
					ignore (exit 1);
				end
			;
			
			(* add default uobj sections *)
			Hashtbl.add d_sections_hashtbl "uobj_hdr" 
				{ f_name = "uobj_hdr";	
				 	f_subsection_list = [ ".hdr" ];	
					usbinformat = { f_type= Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_HDR; 
													f_prot=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_addr_start=0; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				};

			Hashtbl.add d_sections_hashtbl "uobj_ustack" 
				{ f_name = "uobj_ustack";	
				 	f_subsection_list = [ ".ustack" ];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_USTACK; 
													f_prot=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment;
													f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_addr_start=0; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				};

			Hashtbl.add d_sections_hashtbl "uobj_tstack" 
				{ f_name = "uobj_tstack";	
				 	f_subsection_list = [ ".tstack"; ".stack" ];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_TSTACK; 
													f_prot=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment;
													f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_addr_start=0; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				};

			Hashtbl.add d_sections_hashtbl "uobj_code" 
				{ f_name = "uobj_code";	
				 	f_subsection_list = [ ".text" ];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_CODE; 
													f_prot=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_addr_start=0; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				};

			Hashtbl.add d_sections_hashtbl "uobj_data" 
				{ f_name = "uobj_data";	
				 	f_subsection_list = [".data"; ".rodata"];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_RWDATA; 
													f_prot=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment;
													f_addr_start=0; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				};
				
			Hashtbl.add d_sections_hashtbl "uobj_dmadata" 
				{ f_name = "uobj_dmadata";	
				 	f_subsection_list = [".dmadata"];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_DMADATA;
													f_prot=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_aligned_at = Uberspark_config.config_settings.binary_uobj_section_alignment; 
													f_pad_to = Uberspark_config.config_settings.binary_uobj_section_alignment;
													f_addr_start=0; 
													f_addr_file = 0;
													f_reserved = 0;
												};
				};

			(* consolidate uboj section memory map *)
			Uberspark_logger.log "Consolidating uobj section memory map...";
			self#consolidate_sections_with_memory_map self#get_d_load_addr self#get_d_size;
			Uberspark_logger.log "uobj section memory map initialized";

			(* generate uobj binary header source *)
			Uberspark_logger.log ~crlf:false "Generating uobj binary header source...";
			self#generate_src_binhdr;
			Uberspark_logger.log ~tag:"" "[OK]";

			(* generate uobj binary public methods info source *)
			Uberspark_logger.log ~crlf:false "Generating uobj binary public methods info source...";
			self#generate_src_publicmethods_info;
			Uberspark_logger.log ~tag:"" "[OK]";

			(* generate uobj binary intrauobjcoll callees info source *)
			Uberspark_logger.log ~crlf:false "Generating uobj binary intrauobjcoll callees info source...";
			self#generate_src_intrauobjcoll_callees_info;
			Uberspark_logger.log ~tag:"" "[OK]";

			(* generate uobj binary interuobjcoll callees info source *)
			Uberspark_logger.log ~crlf:false "Generating uobj binary interuobjcoll callees info source...";
			self#generate_src_interuobjcoll_callees_info;
			Uberspark_logger.log ~tag:"" "[OK]";

			(* generate uobj binary linker script *)
			Uberspark_logger.log ~crlf:false "Generating uobj binary linker script...";
			self#generate_linker_script self#get_d_load_addr self#get_d_size self#get_d_sections_memory_map_hashtbl_byorigin;
			Uberspark_logger.log ~tag:"" "[OK]";


			()	
		;


end;;





(*---------------------------------------------------------------------------*)
(* to be absorbed *)
(*---------------------------------------------------------------------------*)


(*




		(*--------------------------------------------------------------------------*)
		(* consolidate sections with memory map *)
		(* uobj_load_addr = load address of uobj *)
		(*--------------------------------------------------------------------------*)
		method consolidate_sections_with_memory_map
			(uobj_load_addr : int)
			(uobjsize : int)  
			: int =

			let uobj_section_load_addr = ref 0 in
			o_uobj_load_addr := uobj_load_addr;
			uobj_section_load_addr := uobj_load_addr;

			(* iterate over sentinels *)
			Hashtbl.iter (fun key (x:sentinel_info_t)  ->
				(* compute and round up section size to section alignment *)
				let remainder_size = (x.s_length mod Uberspark_config.config_settings.section_alignment) in
				let padding_size = ref 0 in
					if remainder_size > 0 then
						begin
							padding_size := Uberspark_config.config_settings.section_alignment - remainder_size;
						end
					else
						begin
							padding_size := 0;
						end
					;
				let section_size = (x.s_length + !padding_size) in 
				
				Hashtbl.add uobj_sections_memory_map_hashtbl key 
					{ f_name = key;	
					 	f_subsection_list = [ ("." ^ key) ];	
						usbinformat = { f_type = int_of_string(x.s_type_id);
														f_prot=0; 
														f_addr_start = !uobj_section_load_addr; 
														(*f_size = x.s_length;*)
														f_size = section_size;
														f_addr_file = 0;
														f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
													};
					};
				Hashtbl.add uobj_sections_memory_map_hashtbl_byorigin !uobj_section_load_addr 
					{ f_name = key;	
					 	f_subsection_list = [ ("." ^ key) ];	
						usbinformat = { f_type = int_of_string(x.s_type_id); 
														f_prot=0; 
														f_addr_start = !uobj_section_load_addr; 
														(* f_size = x.s_length; *)
														f_size = section_size;
														f_addr_file = 0;
														f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
					};
			
				(* uobj_section_load_addr := !uobj_section_load_addr + x.s_length; *)
				Uberspark_logger.logf log_tag Uberspark_logger.Info "section at address 0x%08x, size=0x%08x padding=0x%08x" !uobj_section_load_addr section_size !padding_size;
				uobj_section_load_addr := !uobj_section_load_addr + section_size;
			)  o_uobj_publicmethods_sentinels_hashtbl;

			(* iterate over regular sections *)
			Hashtbl.iter (fun key (x:Defs.Basedefs.section_info_t)  ->
				(* compute and round up section size to section alignment *)
				let remainder_size = (x.usbinformat.f_size mod Uberspark_config.config_settings.section_alignment) in
				let padding_size = ref 0 in
					if remainder_size > 0 then
						begin
							padding_size := Uberspark_config.config_settings.section_alignment - remainder_size;
						end
					else
						begin
							padding_size := 0;
						end
					;
				let section_size = (x.usbinformat.f_size + !padding_size) in 


				Hashtbl.add uobj_sections_memory_map_hashtbl key 
					{ f_name = x.f_name;	
					 	f_subsection_list = x.f_subsection_list;	
						usbinformat = { f_type=x.usbinformat.f_type; 
														f_prot=0; 
														f_addr_start = !uobj_section_load_addr; 
														(*f_size = x.usbinformat.f_size;*)
														f_size = section_size;
														f_addr_file = 0;
														f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
													};
					};
				Hashtbl.add uobj_sections_memory_map_hashtbl_byorigin !uobj_section_load_addr 
					{ f_name = x.f_name;	
					 	f_subsection_list = x.f_subsection_list;	
						usbinformat = { f_type=x.usbinformat.f_type; 
														f_prot=0; 
														f_addr_start = !uobj_section_load_addr; 
														(*f_size = x.usbinformat.f_size;*)
														f_size = section_size;
														f_addr_file = 0;
														f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
					};

				(*uobj_section_load_addr := !uobj_section_load_addr + x.usbinformat.f_size;*)
				Uberspark_logger.logf log_tag Uberspark_logger.Info "section at address 0x%08x, size=0x%08x padding=0x%08x" !uobj_section_load_addr section_size !padding_size;
				uobj_section_load_addr := !uobj_section_load_addr + section_size;
			)  o_uobj_sections_hashtbl;

			(* check to see if the uobj sections fit neatly into uobj size *)
			(* if not, add a filler section to pad it to uobj size *)
			if (!uobj_section_load_addr - uobj_load_addr) > uobjsize then
				begin
					Uberspark_logger.logf log_tag Uberspark_logger.Error "uobj total section sizes (0x%08x) span beyond uobj size (0x%08x)!" (!uobj_section_load_addr - uobj_load_addr) uobjsize;
					ignore(exit 1);
				end
			;	

			if (!uobj_section_load_addr - uobj_load_addr) < uobjsize then
				begin
					(* add padding section *)
					Hashtbl.add uobj_sections_memory_map_hashtbl "usuobj_padding" 
						{ f_name = "usuobj_padding";	
						 	f_subsection_list = [ ];	
							usbinformat = { f_type = Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_PADDING;
															f_prot=0; 
															f_addr_start = !uobj_section_load_addr; 
															f_size = (uobjsize - (!uobj_section_load_addr - uobj_load_addr));
															f_addr_file = 0;
															f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
														};
						};
					Hashtbl.add uobj_sections_memory_map_hashtbl_byorigin !uobj_section_load_addr 
						{ f_name = "usuobj_padding";	
						 	f_subsection_list = [ ];	
							usbinformat = { f_type = Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_PADDING;
															f_prot=0; 
															f_addr_start = !uobj_section_load_addr; 
															f_size = (uobjsize - (!uobj_section_load_addr - uobj_load_addr));
															f_addr_file = 0;
															f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
														};
						};
				end
			;	
						
			o_uobj_size := uobjsize;
			(!o_uobj_size)
		;





		(*--------------------------------------------------------------------------*)
		(* compile a uobj cfile *)
		(* cfile_list = list of cfiles *)
		(* cc_includedirs_list = list of include directories *)
		(* cc_defines_list = list of definitions *)
		(*--------------------------------------------------------------------------*)
		method compile_cfile_list cfile_list cc_includedirs_list cc_defines_list =
			List.iter (fun x ->  
									Uberspark_logger.logf log_tag Uberspark_logger.Info "Compiling: %s" x;
									(*let (pestatus, pesignal, cc_outputfilename) = 
										(Usextbinutils.compile_cfile x (x ^ ".o") cc_includedirs_list cc_defines_list) in
											begin
												if (pesignal == true) || (pestatus != 0) then
													begin
															(* Uberspark_logger.logf log_mpf Uberspark_logger.Info "output lines:%u" (List.length poutput); *)
															(* List.iter (fun y -> Uberspark_logger.logf log_mpf Uberspark_logger.Info "%s" !y) poutput; *) 
															(* Uberspark_logger.logf log_mpf Uberspark_logger.Info "%s" !(List.nth poutput 0); *)
															Uberspark_logger.logf log_tag Uberspark_logger.Error "in compiling %s!" x;
															ignore(exit 1);
													end
												else
													begin
															Uberspark_logger.logf log_tag Uberspark_logger.Info "Compiled %s successfully" x;
													end
											end*)
								) cfile_list;
								
			()
		;

		(*--------------------------------------------------------------------------*)
		(* consolidate h-files and embed sentinel declarations *)
		(*--------------------------------------------------------------------------*)
		method generate_uobj_hfile
			() = 
			Uberspark_logger.logf log_tag Uberspark_logger.Info "Generating uobj hfile...";

			(* create uobj hfile *)
			let uobj_hfilename = 
					(self#get_d_path_ns ^ "/" ^ 
						(Uberspark_config.get_uobj_hfilename ()) ^ ".h") in
			let oc = open_out uobj_hfilename in
			
			(* generate hfile prologue *)
			Printf.fprintf oc "\n/* autogenerated uberSpark uobj top-level header */";
			Printf.fprintf oc "\n/* author: amit vasudevan (amitvasudevan@acm.org) */";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n#ifndef __%s_h__" self#get_o_usmf_hdr_id;
			Printf.fprintf oc "\n#define __%s_h__" self#get_o_usmf_hdr_id;
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";

			(* bring in all the contents of the individual h-files *)
			List.iter (fun x ->
				let hfilename = (self#get_d_path_ns ^ "/" ^ x) in 
				(* Uberspark_logger.logf log_tag Uberspark_logger.Info "h-file: %s" x; *)

				Printf.fprintf oc "\n#ifndef __%s_%s_h__" self#get_o_usmf_hdr_id (Filename.chop_extension x);
				Printf.fprintf oc "\n#define __%s_%s_h__" self#get_o_usmf_hdr_id (Filename.chop_extension x);
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";

				let ic = open_in hfilename in
				try
    			while true do
      			let line = input_line ic in
      			Printf.fprintf oc "%s\n" line;
    			done
  			with End_of_file -> ();				
				close_in ic;
	
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n#endif //__%s_%s_h__" self#get_o_usmf_hdr_id (Filename.chop_extension x);
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n";
			) self#get_d_sources_h_file_list;

		  (* plug in sentinel declarations *)
			Printf.fprintf oc "\n/* sentinel declarations follow */";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n#ifndef __ASSEMBLY__";

			Hashtbl.iter (fun key (x:sentinel_info_t)  ->
				Uberspark_logger.logf log_tag Uberspark_logger.Info "key=%s" key;
				let sentinel_fname = x.s_fname ^ 
													"_" ^	x.s_type ^ "_" ^ !o_usmf_hdr_platform ^ "_" ^
													!o_usmf_hdr_cpu ^ "_" ^ !o_usmf_hdr_arch in

				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n#ifdef %s" self#get_o_pp_definition;
				Printf.fprintf oc "\n\t%s %s %s;" x.s_retvaldecl x.s_fname
						x.s_fparamdecl;	
				Printf.fprintf oc "\n#else";
				let sentinel_type_definition_string = 
					List.assoc x.s_type (Uberspark_config.get_sentinel_types ()) in	
				Printf.fprintf oc "\n";
				Printf.fprintf oc "\n\t%s %s %s;" x.s_retvaldecl sentinel_fname
						x.s_fparamdecl;

				Printf.fprintf oc "\n#ifdef %s" ("ENFORCE_" ^ sentinel_type_definition_string);
					Printf.fprintf oc "\n#define %s %s" x.s_fname sentinel_fname;
				Printf.fprintf oc "\n#endif //%s" ("ENFORCE_" ^ sentinel_type_definition_string);
				
				Printf.fprintf oc "\n#endif //%s" self#get_o_pp_definition;
				Printf.fprintf oc "\n";

			) self#get_o_uobj_publicmethods_sentinels_hashtbl;

			(* now print out the last entry of the sentinel equal to the call *)


			Printf.fprintf oc "\n#endif //__ASSEMBLY__";
			Printf.fprintf oc "\n";

			(* generate hfile epilogue *)
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n#endif //__%s_h__" self#get_o_usmf_hdr_id;
			Printf.fprintf oc "\n";
			Printf.fprintf oc "\n";
				
			(* close uobj hfile *)	
			close_out oc;
			Uberspark_logger.logf log_tag Uberspark_logger.Info "Generated uobj hfile.";
			(uobj_hfilename)
		;






		(*--------------------------------------------------------------------------*)
		(* generate uobj sentinels *)
		(*--------------------------------------------------------------------------*)
		method generate_sentinels 
			() = 
			Uberspark_logger.logf log_tag Uberspark_logger.Info "Generating sentinels for target (%s-%s-%s)...\r\n"
				!o_usmf_hdr_platform !o_usmf_hdr_cpu !o_usmf_hdr_arch;

			Hashtbl.iter (fun key (x:sentinel_info_t)  ->
				let sentinel_fname = "sentinel-" ^ x.s_type ^ "-" ^ 
						!o_usmf_hdr_platform ^ "-" ^ !o_usmf_hdr_cpu ^ "-" ^ 
						!o_usmf_hdr_arch ^ ".S" in
				let target_sentinel_fname = "sentinel-" ^ x.s_fname ^ "-" ^ x.s_type ^ "-" ^ 
						!o_usmf_hdr_platform ^ "-" ^ !o_usmf_hdr_cpu ^ "-" ^ 
						!o_usmf_hdr_arch ^ ".S" in
					
				let (pp_retval, _) = Usextbinutils.preprocess 
											((Uberspark_config.get_sentinel_dir ()) ^ "/" ^ sentinel_fname) 
											(self#get_d_path_ns ^ "/" ^ target_sentinel_fname) 
											(Uberspark_config.get_std_incdirs ())
											(Uberspark_config.get_std_defines () @ 
												Uberspark_config.get_std_define_asm () @
												[ self#get_o_pp_definition ] @
												[ "UOBJ_ENTRY_POINT_FNAME=" ^ x.s_fname 
												] @
												[ "UOBJ_SENTINEL_SECTION_NAME=." ^ key
												] @
												[ "UOBJ_SENTINEL_ENTRY_POINT_FNAME=" ^ x.s_fname ^ 
													"_" ^	x.s_type ^ "_" ^ !o_usmf_hdr_platform ^ "_" ^
													!o_usmf_hdr_cpu ^ "_" ^ !o_usmf_hdr_arch
												]) in
					if (pp_retval != 0) then
						begin
								Uberspark_logger.logf log_tag Uberspark_logger.Error "in generating sentinel: %s"
									target_sentinel_fname;
								ignore(exit 1);
						end
					;
				
				
				o_sentinels_source_file_list := !o_sentinels_source_file_list @ 
					[ target_sentinel_fname ];

			) o_uobj_publicmethods_sentinels_hashtbl;

			Uberspark_logger.logf log_tag Uberspark_logger.Info "Generated sentinels.";
			()
		;
		

		(*--------------------------------------------------------------------------*)
		(* generate uobj sentinels lib *)
		(*--------------------------------------------------------------------------*)
		method generate_sentinels_lib 
			() = 
			Uberspark_logger.logf log_tag Uberspark_logger.Info "Generating sentinels lib for target (%s-%s-%s)..."
				!o_usmf_hdr_platform !o_usmf_hdr_cpu !o_usmf_hdr_arch;

			Hashtbl.iter (fun key (x:sentinel_info_t)  ->
				let sentinel_libfname = "libsentinel-" ^ x.s_type ^ "-" ^ 
						!o_usmf_hdr_platform ^ "-" ^ !o_usmf_hdr_cpu ^ "-" ^ 
						!o_usmf_hdr_arch ^ ".S" in
				let target_sentinel_libfname = "libsentinel-" ^ x.s_fname ^ "-" ^ x.s_type ^ "-" ^ 
						!o_usmf_hdr_platform ^ "-" ^ !o_usmf_hdr_cpu ^ "-" ^ 
						!o_usmf_hdr_arch ^ ".S" in
				let x_v = Hashtbl.find uobj_sections_memory_map_hashtbl key in
				
				let (pp_retval, _) = Usextbinutils.preprocess 
											((Uberspark_config.get_sentinel_dir ()) ^ "/" ^ sentinel_libfname) 
											(self#get_d_path_ns ^ "/" ^ target_sentinel_libfname) 
											(Uberspark_config.get_std_incdirs ())
											(Uberspark_config.get_std_defines () @ 
												Uberspark_config.get_std_define_asm () @
												[ self#get_o_pp_definition ] @
												[ "UOBJ_SENTINEL_ENTRY_POINT=" ^ 
													(Printf.sprintf "0x%08x" x_v.usbinformat.f_addr_start)
												] @
												[ "UOBJ_SENTINEL_SECTION_NAME=.text"
												] @
												[ "UOBJ_SENTINEL_ENTRY_POINT_FNAME=" ^ x.s_fname ^ 
													"_" ^	x.s_type ^ "_" ^ !o_usmf_hdr_platform ^ "_" ^
													!o_usmf_hdr_cpu ^ "_" ^ !o_usmf_hdr_arch
												]) in
					if (pp_retval != 0) then
						begin
								Uberspark_logger.logf log_tag Uberspark_logger.Error "in generating sentinel lib: %s"
									target_sentinel_libfname;
								ignore(exit 1);
						end
					;
				
												
				o_uobj_publicmethods_sentinels_lib_source_file_list := !o_uobj_publicmethods_sentinels_lib_source_file_list @ 
					[ target_sentinel_libfname ];
						
			) o_uobj_publicmethods_sentinels_hashtbl;

			Uberspark_logger.logf log_tag Uberspark_logger.Info "Generated sentinels lib.";
			()
		;





		(*--------------------------------------------------------------------------*)
		(* compile uobj sentinels *)
		(*--------------------------------------------------------------------------*)
		method compile_sentinels 
			() = 
			Uberspark_logger.logf log_tag Uberspark_logger.Info "Building sentinels for target (%s-%s-%s)...\r\n"
				!o_usmf_hdr_platform !o_usmf_hdr_cpu !o_usmf_hdr_arch;

			(* compile all the sentinel source files *)							
			self#compile_cfile_list !o_sentinels_source_file_list
					(Uberspark_config.get_std_incdirs ())
					(Uberspark_config.get_std_defines () @ 
					[ self#get_o_pp_definition ] @
								Uberspark_config.get_std_define_asm ());

			Uberspark_logger.logf log_tag Uberspark_logger.Info "Built sentinels.";
			()
		;


		(*--------------------------------------------------------------------------*)
		(* compile uobj sentinels lib *)
		(*--------------------------------------------------------------------------*)
		method compile_sentinels_lib 
			() = 
			(*let uobj_sentinels_lib_name = "lib" ^ (self#get_o_usmf_hdr_id) ^ "-" ^
				!o_usmf_hdr_platform ^ "-" ^ !o_usmf_hdr_cpu ^ "-" ^ !o_usmf_hdr_arch in*)
				
			Uberspark_logger.logf log_tag Uberspark_logger.Info "Building sentinels lib: %s...\r\n"
				self#get_o_uobj_publicmethods_sentinels_libname;

			(* compile all the sentinel lib source files *)							
			self#compile_cfile_list !o_uobj_publicmethods_sentinels_lib_source_file_list
					(Uberspark_config.get_std_incdirs ())
					(Uberspark_config.get_std_defines () @
					[ self#get_o_pp_definition ] @ 
								Uberspark_config.get_std_define_asm ());

(*						
			(* now create the lib archive *)
			let (pestatus, pesignal) = 
					(Usextbinutils.mklib  
						!o_uobj_publicmethods_sentinels_lib_source_file_list
						(self#get_o_uobj_publicmethods_sentinels_libname ^ ".a")
					) in
					if (pesignal == true) || (pestatus != 0) then
						begin
								Uberspark_logger.logf log_tag Uberspark_logger.Error "in building sentinel lib!";
								ignore(exit 1);
						end
					else
						begin
								Uberspark_logger.logf log_tag Uberspark_logger.Info "Built sentinels lib.";
						end
					;
*)
		
			()
		;




		(*--------------------------------------------------------------------------*)
		(* compile a uobj *)
		(* build_dir = directory to use for building *)
		(* keep_temp_files = true if temporary files need to be preserved in build_dir *)
		(*--------------------------------------------------------------------------*)
		method compile 
			(build_dir : string)
			(keep_temp_files : bool) = 
	
			Uberspark_logger.logf log_tag Uberspark_logger.Info "Starting compilation in '%s' [%b]\n" build_dir keep_temp_files;
			
			Uberspark_logger.logf log_tag Uberspark_logger.Info "cfiles_count=%u, casmfiles_count=%u\n"
						(List.length !d_sources_c_file_list) 
						(List.length !d_sources_casm_file_list);

			(* generate uobj top-level header *)
			self#generate_uobj_hfile ();
	
			(* generate sentinels *)
			(* TBD: hook in later *)
			(* self#generate_sentinels (); *)

			(* generate sentinels lib *)
			(* TBD: hook in later *)
			(* self#generate_sentinels_lib (); *)

			(* compile all sentinels *)							
			self#compile_sentinels ();
									
			(* compile sentinels lib *)
			self#compile_sentinels_lib ();						

			(* compile all the cfiles *)
			(* TBD: hook in later *)
			(*							
			self#compile_cfile_list (!o_usmf_sources_c_files) 
					(Uberspark_config.get_std_incdirs ())
					(Uberspark_config.get_std_defines () @ [ self#get_o_pp_definition ]);
			*)			

			Uberspark_logger.logf log_tag Uberspark_logger.Info "Compilation finished.\r\n";
			()
		;



	(*--------------------------------------------------------------------------*)
	(* generate uobj info table *)
	(*--------------------------------------------------------------------------*)
	method generate_uobj_info ochannel = 
		let i = ref 0 in 
		
		Printf.fprintf ochannel "\n";
    Printf.fprintf ochannel "\n	//%s" (!o_usmf_hdr_id);
    Printf.fprintf ochannel "\n	{";

	  (* total_sentinels *)
  	Printf.fprintf ochannel "\n\t0x%08xUL, " (Hashtbl.length o_uobj_publicmethods_sentinels_hashtbl);
		
		(* plug in the sentinels *)
		Printf.fprintf ochannel "\n\t{";
		Hashtbl.iter (fun key (x:sentinel_info_t)  ->
			let x_v = Hashtbl.find uobj_sections_memory_map_hashtbl key in
			Printf.fprintf ochannel "\n\t\t{";
		  	Printf.fprintf ochannel "\n\t\t\t0x%08xUL, " (int_of_string(x.s_type_id));
		  	Printf.fprintf ochannel "\n\t\t\t0x%08xUL, " (0);
		  	Printf.fprintf ochannel "\n\t\t\t0x%08xUL, " (x_v.usbinformat.f_va_offset);
		  	Printf.fprintf ochannel "\n\t\t\t0x%08xUL " (x.s_length);
			Printf.fprintf ochannel "\n\t\t},";
		)  o_uobj_publicmethods_sentinels_hashtbl;
		Printf.fprintf ochannel "\n\t},";

		(*ustack_tos*)
    let info = Hashtbl.find uobj_sections_memory_map_hashtbl 
			(Uberspark_config.get_section_name_ustack()) in
		let ustack_size = (Uberspark_config.get_sizeof_uobj_ustack()) in
		let ustack_tos = ref 0 in
		ustack_tos := info.usbinformat.f_va_offset + ustack_size;
		Printf.fprintf ochannel "\n\t{";
		i := 0;
		while (!i < (Uberspark_config.get_std_max_platform_cpus ())) do
		    Printf.fprintf ochannel "\n\t\t0x%08xUL," !ustack_tos;
				i := !i + 1;
				ustack_tos := !ustack_tos + ustack_size;
		done;
    Printf.fprintf ochannel "\n\t},";

		(*tstack_tos*)
    let info = Hashtbl.find uobj_sections_memory_map_hashtbl 
			(Uberspark_config.get_section_name_tstack()) in
		let tstack_size = (Uberspark_config.get_sizeof_uobj_tstack()) in
		let tstack_tos = ref 0 in
		tstack_tos := info.usbinformat.f_va_offset + tstack_size;
		Printf.fprintf ochannel "\n\t{";
		i := 0;
		while (!i < (Uberspark_config.get_std_max_platform_cpus ())) do
		    Printf.fprintf ochannel "\n\t\t0x%08xUL," !tstack_tos;
				i := !i + 1;
				tstack_tos := !tstack_tos + tstack_size;
		done;
    Printf.fprintf ochannel "\n\t},";
																								
    Printf.fprintf ochannel "\n	}";
		Printf.fprintf ochannel "\n";

		()
	;




	(*--------------------------------------------------------------------------*)
	(* install uobj *)
	(*--------------------------------------------------------------------------*)
	method install 
			(install_dir : string) 
			=
			
			(* create uobj installation folder if not already existing *)
			let uobj_install_dir = (install_dir ^ "/" ^ !o_usmf_hdr_id) in
				Uberspark_logger.logf log_tag Uberspark_logger.Info "Installing uobj: '%s'..." uobj_install_dir;
			let (retval, retecode, retemsg) = Uberspark_osservices.mkdir uobj_install_dir 0o755 in
				if (retval == false) && (retecode != Unix.EEXIST) then 
				begin
					Uberspark_logger.logf log_tag Uberspark_logger.Error "error in creating directory: %s" retemsg;
				end
				;

			(* copy uobj manifest *)
			Uberspark_osservices.file_copy (!d_path_ns ^ "/" ^ !d_mf_filename)
				(uobj_install_dir ^ "/" ^ Uberspark_config.std_uobj_usmf_name); 
			
			(* copy uobj header file *)
			Uberspark_osservices.file_copy (!d_path_ns ^ "/" ^ 
															Uberspark_config.uobj_hfilename ^ ".h")
				(install_dir ^ "/" ^ !o_usmf_hdr_id ^ ".h"); 
	
			(* copy sentinels lib *)
			Uberspark_osservices.file_copy (!d_path_ns ^ "/" ^ 
															self#get_o_uobj_publicmethods_sentinels_libname ^ ".a")
				(uobj_install_dir ^ "/" ^ self#get_o_uobj_publicmethods_sentinels_libname ^ ".a"); 
			
							
		()
	; 

end ;;


*)


(*---------------------------------------------------------------------------*)
(* potpourri *)
(*---------------------------------------------------------------------------*)


				(*let x_v = Hashtbl.find uobj_sections_memory_map_hashtbl key in

				Uberspark_logger.logf log_tag Uberspark_logger.Info "%s/%s at 0x%08x" 
					(Uberspark_config.get_sentinel_dir ()) sentinel_fname x_v.s_origin;
				*)



(*


		(*--------------------------------------------------------------------------*)
		(* initialize *)
		(* sentineltypes_hashtbl = hash table of sentinel types *)
		(*--------------------------------------------------------------------------*)
		method initialize 
			(sentineltypes_hashtbl : ((string, Defs.Basedefs.uobjcoll_sentineltypes_t) Hashtbl.t) ) 
			= 
				
			(* copy over sentineltypes hash table into uobj sentineltypes hash table*)
			Hashtbl.iter (fun key (st:Defs.Basedefs.uobjcoll_sentineltypes_t)  ->
					Hashtbl.add o_sentineltypes_hashtbl key st;
			) sentineltypes_hashtbl;

			(* iterate over sentineltypes hash table to construct sentinels hash table*)
			Hashtbl.iter (fun st_key (st:Defs.Basedefs.uobjcoll_sentineltypes_t)  ->
						Hashtbl.iter (fun pm_key (pm: uobj_publicmethods_t) ->
				
						let sentinel_name = ref "" in
							sentinel_name := "sentinel_" ^ st.s_type ^ "_" ^ pm.f_name; 

						Hashtbl.add o_uobj_publicmethods_sentinels_hashtbl !sentinel_name 
							{
								s_type = st.s_type;
								s_type_id = st.s_type_id;
								s_retvaldecl = pm.f_retvaldecl;
								s_fname = pm.f_name;
								s_fparamdecl = pm.f_paramdecl;
								s_fparamdwords = pm.f_paramdwords;
								s_attribute = (Uberspark_config.get_sentinel_prot ());
								s_origin = 0;
								s_length = Uberspark_config.config_settings.section_size_sentinel;
							};
			
						) d_publicmethods_hashtbl;
			) o_sentineltypes_hashtbl;


			(* add default uobj sections *)
			Hashtbl.add o_uobj_sections_hashtbl "uobj_hdr" 
				{ f_name = "uobj_hdr";	
				 	f_subsection_list = [ ".hdr" ];	
					usbinformat = { f_type= Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_HDR; f_prot=0; 
													f_addr_start=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_addr_file = 0;
													f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
				};
			Hashtbl.add o_uobj_sections_hashtbl "uobj_ustack" 
				{ f_name = "uobj_ustack";	
				 	f_subsection_list = [ ".ustack" ];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_USTACK; f_prot=0; 
													f_addr_start=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_addr_file = 0;
													f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
				};
			Hashtbl.add o_uobj_sections_hashtbl "uobj_tstack" 
				{ f_name = "uobj_tstack";	
				 	f_subsection_list = [ ".tstack"; ".stack" ];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_TSTACK; f_prot=0; 
													f_addr_start=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_addr_file = 0;
													f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
				};
			Hashtbl.add o_uobj_sections_hashtbl "uobj_code" 
				{ f_name = "uobj_code";	
				 	f_subsection_list = [ ".text" ];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_CODE; f_prot=0; 
													f_addr_start=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_addr_file = 0;
								f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
				};
			Hashtbl.add o_uobj_sections_hashtbl "uobj_data" 
				{ f_name = "uobj_data";	
				 	f_subsection_list = [".data"; ".rodata"];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_RWDATA; f_prot=0; 
													f_addr_start=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_addr_file = 0;
													f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
				};
				
			Hashtbl.add o_uobj_sections_hashtbl "uobj_dmadata" 
				{ f_name = "uobj_dmadata";	
				 	f_subsection_list = [".dmadata"];	
					usbinformat = { f_type=Defs.Basedefs.def_USBINFORMAT_SECTION_TYPE_UOBJ_DMADATA; f_prot=0; 
													f_addr_start=0; 
													f_size = Uberspark_config.config_settings.binary_uobj_default_section_size;
													f_addr_file = 0;
													f_aligned_at = Uberspark_config.config_settings.section_alignment; f_pad_to = Uberspark_config.config_settings.section_alignment; f_reserved = 0;
												};
				};
			
			()	
		;



*)




(*		
						(*slab_tos*)
    Printf.fprintf oc "\n\t{";
		i := 0;
		while (!i < Uberspark_config.get_std_max_platform_cpus) do
		    (* Printf.fprintf oc "\n\t\t   %s + (1*XMHF_SLAB_STACKSIZE)," (Hashtbl.find slab_idtostack_addrstart !i);*)
		    Printf.fprintf oc "\n\t\t0x00000000UL,";
				i := !i + 1;
		done;
    Printf.fprintf oc "\n\t},";

		Printf.fprintf oc "\n\t0x00000000UL, ";    (*slab_callcaps*)
    Printf.fprintf oc "\n\ttrue,";             (*slab_uapisupported*)
		
		(*slab_uapicaps*)
    Printf.fprintf oc "\n\t{";
		i := 0;
		while (!i < total_uobjs) do
		    Printf.fprintf oc "\n\t\t0x00000000UL,";
				i := !i + 1;
		done;
    Printf.fprintf oc "\n\t},";

		Printf.fprintf oc "\n\t0x00000000UL, ";    (*slab_memgrantreadcaps*)
		Printf.fprintf oc "\n\t0x00000000UL, ";    (*slab_memgrantwritecaps*)

		(*incl_devices*)
    Printf.fprintf oc "\n\t{";
		i := 0;
		while (!i < get_std_max_incldevlist_entries) do
		    Printf.fprintf oc "\n\t\t{0x00000000UL,0x00000000UL},";
				i := !i + 1;
		done;
    Printf.fprintf oc "\n\t},";

		Printf.fprintf oc "\n\t0x00000000UL, ";    (*incl_devices_count*)

		(*excl_devices*)
    Printf.fprintf oc "\n\t{";
		i := 0;
		while (!i < get_std_max_excldevlist_entries) do
		    Printf.fprintf oc "\n\t\t{0x00000000UL,0x00000000UL},";
				i := !i + 1;
		done;
    Printf.fprintf oc "\n\t},";
		
		Printf.fprintf oc "\n\t0x00000000UL, ";    (*excl_devices_count*)

		(*excl_devices*)
    Printf.fprintf oc "\n\t{";
		i := 0;
		while (!i < get_std_max_excldevlist_entries) do
		    Printf.fprintf oc "\n\t\t{0x00000000UL,0x00000000UL},";
				i := !i + 1;
		done;
    Printf.fprintf oc "\n\t},";
*)

(*
 		type section_info_t = 
			{
				origin: int;
				length: int;	
				subsection_list : string list;
			};;
		val uobj_sections_memory_map_hashtbl = ((Hashtbl.create 32) : ((string, section_info_t)  Hashtbl.t)); 
	
			Hashtbl.add uobj_sections_hashtbl "sample" { origin=0; length=0; subsection_list = ["one"; "two"; "three"]};
			let mysection = Hashtbl.find uobj_sections_hashtbl "sample" in
				Uberspark_logger.logf log_tag Uberspark_logger.Info "origin=%u" mysection.origin;
*)
