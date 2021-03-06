(* uberspark front-end command processing logic for command: bridges *)
(* author: amit vasudevan (amitvasudevan@acm.org) *)

open Uberspark
open Cmdliner

type opts = { 
  ar_bridge: bool;
  as_bridge: bool;
  cc_bridge: bool;
  ld_bridge: bool;
  pp_bridge: bool;
  vf_bridge: bool;
  build: bool;
  output_directory: string option;
  bridge_exectype : string option;
};;

(* fold all bridges options into type opts *)
let cmd_bridge_opts_handler 
  (ar_bridge: bool)
  (as_bridge: bool)
  (cc_bridge: bool)
  (ld_bridge: bool)
  (pp_bridge: bool)
  (vf_bridge: bool)
  (build : bool)
  (output_directory: string option)
  (bridge_exectype : string option)
  : opts = 
  { ar_bridge=ar_bridge;
    as_bridge=as_bridge;
    cc_bridge=cc_bridge;
    ld_bridge=ld_bridge;
    pp_bridge=pp_bridge;
    vf_bridge=vf_bridge;
    build=build;
    output_directory=output_directory;
    bridge_exectype=bridge_exectype;
  }
;;

(* handle bridges command options *)
let cmd_bridge_opts_t =
  let docs = "ACTION OPTIONS" in
  
  let ar_bridge =
  let doc = "Select archiver (ar) bridge namespace prefix." in
  Arg.(value & flag & info ["ar"; "ar-bridge"] ~doc ~docs)
  in

  let as_bridge =
  let doc = "Select assembler (as) bridge namespace prefix." in
  Arg.(value & flag & info ["as"; "as-bridge"] ~doc ~docs)
  in

  let cc_bridge =
  let doc = "Select compiler (cc) bridge namespace prefix." in
  Arg.(value & flag & info ["cc"; "cc-bridge"] ~doc ~docs)
  in

  let ld_bridge =
  let doc = "Select linker (ld) bridge namespace prefix." in
  Arg.(value & flag & info ["ld"; "ld-bridge"] ~doc ~docs)
  in

  let pp_bridge =
  let doc = "Select pre-processor (pp) bridge namespace prefix." in
  Arg.(value & flag & info ["pp"; "pp-bridge"] ~doc ~docs)
  in

  let vf_bridge =
  let doc = "Select verification (vf) bridge namespace prefix." in
  Arg.(value & flag & info ["vf"; "vf-bridge"] ~doc ~docs)
  in

  let build =
  let doc = "Build the bridge if bridge execution type is 'container'" in
  Arg.(value & flag & info ["b"; "build"] ~doc ~docs)
  in

  let output_directory =
    let doc = "Select output directory, $(docv)."  in
      Arg.(value & opt (some string) None & info ["o"; "output-directory"] ~docs ~docv:"DIR" ~doc)
  in

  let bridge_exectype =
    let doc = "Select bridge execution $(docv)."  in
      Arg.(value & opt (some string) None & info ["bet"; "bridge-exectype"] ~docs ~docv:"TYPE" ~doc)
  in


  Term.(const cmd_bridge_opts_handler $ ar_bridge $ as_bridge $ cc_bridge $ ld_bridge $ pp_bridge $ vf_bridge $ build $ output_directory $ bridge_exectype)




(* bridges create action *)
let handler_bridges_action_create 
  (copts : Commonopts.opts)
  (cmd_bridges_opts: opts)
  (path_ns : string option)
  : [> `Error of bool * string | `Ok of unit ] = 

  let retval : [> `Error of bool * string | `Ok of unit ] ref = ref (`Ok ()) in

  (* perform common initialization *)
  Commoninit.initialize copts;

  (* check to see if we have path_ns spcified *)
  let l_path_ns = ref "" in
  match path_ns with
  | None -> 
    begin
      retval := `Error (true, "need $(i,PATH) to bridge definition file");
      (!retval)
    end


  | Some sname -> 
    begin
        l_path_ns := sname;
        let processed_bridge = ref false in

        (* process cc-bridge *)
        if cmd_bridges_opts.cc_bridge then begin
          if (Uberspark.Bridge.Cc.load_from_file !l_path_ns) then begin
              
            Uberspark.Bridge.Cc.store ();
        
            if (cmd_bridges_opts.build) then begin
              ignore (Uberspark.Bridge.Cc.build ());
            end;
            
            retval := `Ok();
          end else begin
            retval := `Error (false, "could not load cc-bridge!");
          end;
        
          processed_bridge := true;
        end;


        if not !processed_bridge then begin
          retval := `Error (true, "need one of the following action options: $(b,-ar), $(b,-as), $(b,-cc), $(b,-ld), $(b,-pp), and $(b,-vf)");
        end;
        
      (!retval)
    end
  


;;


(* bridges dump action *)
let handler_bridges_action_dump 
  (copts : Commonopts.opts)
  (cmd_bridges_opts: opts)
  (path_ns : string option)
  : [> `Error of bool * string | `Ok of unit ] = 

    let retval : [> `Error of bool * string | `Ok of unit ] ref = ref (`Ok ()) in

    (* perform common initialization *)
    Commoninit.initialize copts;

    (* check to see if we have path_ns spcified *)
    let l_path_ns = ref "" in
    let l_output_directory = ref "" in
    let l_bridge_exectype = ref "" in

    let bridge_ns_prefix = ref "" in

    match path_ns with
    | None -> 
        begin
          retval := `Error (true, "need bridge $(i,NAMESPACE) argument");
          (!retval)
        end

    | Some path_ns_qname -> 
        begin
          l_path_ns := path_ns_qname;

          match cmd_bridges_opts.output_directory with
          | None -> 
              begin
                retval := `Error (true, "need $(b,--output-directory) action option");
                (!retval)
              end

          | Some output_directory_qname -> 
              begin
                l_output_directory := output_directory_qname;

                match cmd_bridges_opts.bridge_exectype with
                | None -> 
                    begin
                      retval := `Error (true, "need $(b,--bridge-exectype) action option");
                      (!retval)
                    end

                | Some bridge_exectype_qname -> 
                    begin
                      l_bridge_exectype := bridge_exectype_qname;

                      let action_options_unspecified = ref false in 

                      if cmd_bridges_opts.ar_bridge then begin            
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_ar_bridge; end
                      else if cmd_bridges_opts.as_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_as_bridge; end
                      else if cmd_bridges_opts.cc_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_cc_bridge; end
                      else if cmd_bridges_opts.ld_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_ld_bridge; end
                      else if cmd_bridges_opts.pp_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_pp_bridge; end
                      else if cmd_bridges_opts.vf_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_vf_bridge; end
                      else begin
                        action_options_unspecified := true; end
                      ;                   

                      if(!l_bridge_exectype = "container" || !l_bridge_exectype = "native") then
                        begin

                          if (!action_options_unspecified) then
                            begin
                              retval := `Error (true, "need one of the following action options: $(b,-ar), $(b,-as), $(b,-cc), $(b,-ld), $(b,-pp), and $(b,-vf)");
                            end
                          else
                            begin
                              (* dump the bridge configuration and container files if any *)          
                              let bridge_ns_path = (!bridge_ns_prefix ^ "/" ^ !l_bridge_exectype ^ 
                              "/" ^ !l_path_ns) in 
                                Uberspark.Bridge.dump bridge_ns_path ~bridge_exectype:!l_bridge_exectype !l_output_directory;
                              Uberspark.Logger.log "Successfully dumped bridge definitions to directory: '%s'" !l_output_directory;
                            end
                          ;              

                        end
                      else
                        begin
                          retval := `Error (true, "--bridge-type needs to be 'container' or 'native'");
                        end
                      ;


                      (!retval)

                    end
              end
        end

;;


let helper_bridges_action_config_do
  (bridge_type : string)
  (bridge_ns : string)
  (cmd_bridges_opts : opts )
  : [> `Error of bool * string | `Ok of unit ] = 

  let retval : [> `Error of bool * string | `Ok of unit ] ref = ref (`Ok ()) in

  if (cmd_bridges_opts.build) then
    begin
      match bridge_type with 
        | "cc-bridge" -> 

          if (Uberspark.Bridge.Cc.load bridge_ns) then begin
            Uberspark.Logger.log "loaded cc-bridge settings";
            if ( Uberspark.Bridge.Cc.build () ) then begin
              retval := `Ok();
            end else begin
              retval := `Error (false, "could not build cc-bridge!");
            end;
          end else begin
            retval := `Error (false, "unable to load cc-bridge settings!");
          end
          ;  

        | "as-bridge" -> 

          if (Uberspark.Bridge.As.load bridge_ns) then begin
            Uberspark.Logger.log "loaded as-bridge settings";
            if ( Uberspark.Bridge.As.build () ) then begin
              retval := `Ok();
            end else begin
              retval := `Error (false, "could not build as-bridge!");
            end;
          end else begin
            retval := `Error (false, "unable to load as-bridge settings!");
          end
          ;  

        | "ld-bridge" -> 

          if (Uberspark.Bridge.Ld.load bridge_ns) then begin
            Uberspark.Logger.log "loaded ld-bridge settings";
            if ( Uberspark.Bridge.Ld.build () ) then begin
              retval := `Ok();
            end else begin
              retval := `Error (false, "could not build ld-bridge!");
            end;
          end else begin
            retval := `Error (false, "unable to load ld-bridge settings!");
          end
          ;  


        | _ ->
            retval := `Error (false, "unknown bridge type!");
      ;
    end
  else  
    begin
      retval := `Error (true, "you must specify --build");
    end
  ;

  (!retval)
;;

(* bridges config action *)
let handler_bridges_action_config 
  (copts : Commonopts.opts)
  (cmd_bridges_opts: opts)
  (path_ns : string option)
  : [> `Error of bool * string | `Ok of unit ] = 

    let retval : [> `Error of bool * string | `Ok of unit ] ref = ref (`Ok ()) in

    (* perform common initialization *)
    Commoninit.initialize copts;

    let l_path_ns = ref "" in
    let bridge_ns_prefix = ref "" in
    let bridge_type = ref [] in 

    match path_ns with
    | None -> 
        begin
          retval := `Error (true, "need bridge $(i,NAMESPACE) argument");
          (!retval)
        end

    | Some path_ns_qname -> 
        begin
          l_path_ns := path_ns_qname;

          let bridge_ns = "container/" ^ !l_path_ns in 

          if cmd_bridges_opts.cc_bridge then begin
              retval := helper_bridges_action_config_do Uberspark.Namespace.namespace_bridge_cc_bridge_name bridge_ns cmd_bridges_opts;

          end else if cmd_bridges_opts.as_bridge then begin
              retval := helper_bridges_action_config_do Uberspark.Namespace.namespace_bridge_as_bridge_name bridge_ns cmd_bridges_opts;

          end else if cmd_bridges_opts.ld_bridge then begin
              retval := helper_bridges_action_config_do Uberspark.Namespace.namespace_bridge_ld_bridge_name bridge_ns cmd_bridges_opts;

          end else begin
              retval := `Error (true, "need one of the following action options: $(b,-ar), $(b,-as), $(b,-cc), $(b,-ld), $(b,-pp), and $(b,-vf)");
          end;


          (*
            bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_cc_bridge; 
            bridge_type := [ Uberspark.Namespace.namespace_bridge_cc_bridge_name ]; end
          
          
          
          let action_options_unspecified = ref false in 

          if cmd_bridges_opts.ar_bridge then begin            
            bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_ar_bridge; 
            bridge_type := [ Uberspark.Namespace.namespace_bridge_ar_bridge_name ]; end
          else if cmd_bridges_opts.as_bridge then begin
            bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_as_bridge; 
            bridge_type := [ Uberspark.Namespace.namespace_bridge_as_bridge_name ]; end
          else if cmd_bridges_opts.cc_bridge then begin
            bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_cc_bridge; 
            bridge_type := [ Uberspark.Namespace.namespace_bridge_cc_bridge_name ]; end
          else if cmd_bridges_opts.ld_bridge then begin
            bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_ld_bridge; 
            bridge_type := [ Uberspark.Namespace.namespace_bridge_ld_bridge_name ]; end
          else if cmd_bridges_opts.pp_bridge then begin
            bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_pp_bridge; 
            bridge_type := [ Uberspark.Namespace.namespace_bridge_pp_bridge_name ]; end
          else if cmd_bridges_opts.vf_bridge then begin
            bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_vf_bridge; 
            bridge_type := [ Uberspark.Namespace.namespace_bridge_vf_bridge_name ]; end
          else begin
            action_options_unspecified := true; end
          ;                   

          if (!action_options_unspecified) then
            begin
              retval := `Error (true, "need one of the following action options: $(b,-ar), $(b,-as), $(b,-cc), $(b,-ld), $(b,-pp), and $(b,-vf)");
            end
          else
            begin
              (* load bridge from namespace *)
              let bridge_ns = !bridge_ns_prefix ^ "/container/" ^ !l_path_ns in 
              let dummy = ref 0 in 
                dummy := 5;
              (*if ( Uberspark.Bridge.load bridge_ns ) then 
                begin
                  (* check if build option is specified and if so then build the bridge *)
                  if (cmd_bridges_opts.build) then
                    begin
                      Uberspark.Bridge.build !bridge_type;
                    end
                  else  
                    begin
                      retval := `Error (true, "you must specify --build");
                    end
                  ;
                end
              else
                begin
                  retval := `Error (false, "could not load bridge settings");
                end
              ;*)
            
            end
          ; *)             

          (!retval)

        end
;;


(* bridges remove action *)
let handler_bridges_action_remove 
  (copts : Commonopts.opts)
  (cmd_bridges_opts: opts)
  (path_ns : string option)
  : [> `Error of bool * string | `Ok of unit ] = 

    let retval : [> `Error of bool * string | `Ok of unit ] ref = ref (`Ok ()) in

    (* perform common initialization *)
    Commoninit.initialize copts;

    let l_path_ns = ref "" in
    let l_bridge_exectype = ref "" in

    let bridge_ns_prefix = ref "" in

    match path_ns with
    | None -> 
        begin
          retval := `Error (true, "need bridge $(i,NAMESPACE) argument");
          (!retval)
        end

    | Some path_ns_qname -> 
        begin
          l_path_ns := path_ns_qname;

                match cmd_bridges_opts.bridge_exectype with
                | None -> 
                    begin
                      retval := `Error (true, "need $(b,--bridge-exectype) action option");
                      (!retval)
                    end

                | Some bridge_exectype_qname -> 
                    begin
                      l_bridge_exectype := bridge_exectype_qname;

                      let action_options_unspecified = ref false in 

                      if cmd_bridges_opts.ar_bridge then begin            
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_ar_bridge; end
                      else if cmd_bridges_opts.as_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_as_bridge; end
                      else if cmd_bridges_opts.cc_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_cc_bridge; end
                      else if cmd_bridges_opts.ld_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_ld_bridge; end
                      else if cmd_bridges_opts.pp_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_pp_bridge; end
                      else if cmd_bridges_opts.vf_bridge then begin
                        bridge_ns_prefix := Uberspark.Namespace.namespace_bridge_vf_bridge; end
                      else begin
                        action_options_unspecified := true; end
                      ;                   

                      if(!l_bridge_exectype = "container" || !l_bridge_exectype = "native") then
                        begin

                          if (!action_options_unspecified) then
                            begin
                              retval := `Error (true, "need one of the following action options: $(b,-ar), $(b,-as), $(b,-cc), $(b,-ld), $(b,-pp), and $(b,-vf)");
                            end
                          else
                            begin
                              (* remove the bridge configuration and container files if any *)          
                              let bridge_ns_path = (!bridge_ns_prefix ^ "/" ^ !l_bridge_exectype ^ 
                              "/" ^ !l_path_ns) in 
                                Uberspark.Bridge.remove bridge_ns_path;
                              Uberspark.Logger.log "Successfully removed bridge '%s'" bridge_ns_path;
                            end
                          ;              

                        end
                      else
                        begin
                          retval := `Error (true, "--bridge-type needs to be 'container' or 'native'");
                        end
                      ;


                      (!retval)

                    end
        end

;;



 


(* main handler for bridges command *)
let handler_bridge 
  (copts : Commonopts.opts)
  (cmd_bridges_opts: opts)
  (action : [> `Config | `Create | `Dump | `Remove] as 'a)
  (path_ns : string option)
  : [> `Error of bool * string | `Ok of unit ] = 

  let retval : [> `Error of bool * string | `Ok of unit ] ref = ref (`Ok ()) in

  match action with
    | `Config -> 
 
      retval := handler_bridges_action_config copts cmd_bridges_opts path_ns;

    | `Create -> 
      retval := handler_bridges_action_create copts cmd_bridges_opts path_ns;

    | `Dump ->

      retval := handler_bridges_action_dump copts cmd_bridges_opts path_ns;


    | `Remove -> 

      retval := handler_bridges_action_remove copts cmd_bridges_opts path_ns;

  ;

    (!retval)


;;