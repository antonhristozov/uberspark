{
	"uobj-name": "uobj2",
	"uobj-type": "VfT_SLAB",
	"uobj-subtype": "UAPI",

	"uobj-uapifunctions":[
		{ 
			"uapifunction-id": "1",
			"uapifunction-definition" : 
				"void _slabmempgtbl_initmempgtbl(xmhfgeec_uapi_slabmempgtbl_initmempgtbl_params_t *initmempgtblp)", 
			"uapifunction-drivercode" : 
				"{xmhfgeec_uapi_slabmempgtbl_initmempgtbl_params_t initmempgtblp; initmempgtblp.dst_slabid = framac_nondetu32(); _slabmempgtbl_initmempgtbl(&initmempgtblp);}"
		},
		{ 
			"uapifunction-id": "2",
			"uapifunction-definition" : "void _slabmempgtbl_setentryforpaddr(xmhfgeec_uapi_slabmempgtbl_setentryforpaddr_params_t *setentryforpaddrp)", 
			"uapifunction-drivercode" : "{xmhfgeec_uapi_slabmempgtbl_setentryforpaddr_params_t setentryforpaddrp; setentryforpaddrp.dst_slabid = framac_nondetu32(); setentryforpaddrp.gpa = framac_nondetu32(); setentryforpaddrp.entry = framac_nondetu32(); _slabmempgtbl_setentryforpaddr(&setentryforpaddrp);}"
		}
	],	

	"uobj-callees": "",

	"uobj-uapicallees":[],

	"uobj-resource-devices":[
		{ 
			"type": "include",
			"opt1" : "0xdead",
			"opt2" : "0xbeef" 
		}
	],	

	"uobj-resource-memory":[],

	"uobj-exportfunctions": "",

	"uobj-binary-sections":[
		{ 
			"section-name": "code",
			"section-size": "4096"
		},
		{ 
			"section-name": "data",
			"section-size": "4096"
		},
		{ 
			"section-name": "stack",
			"section-size": "4096"
		},
		{ 
			"section-name": "dmadata",
			"section-size": "4096"
		}
	],	

	
	"c-files":	"a1.c
				 a2.c
				 a3.c
				 a4.c		",
	
	
	"v-harness": [
	    { "file": "a1.c", "options" : "--option1" },
	    { "file": "a2.c", "options" : "--option2" },
	    { "file": "a3.c", "options" : "--option3" }
	  ]
		
	
}