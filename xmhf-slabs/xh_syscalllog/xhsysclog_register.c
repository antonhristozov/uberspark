/*
 * @XMHF_LICENSE_HEADER_START@
 *
 * eXtensible, Modular Hypervisor Framework (XMHF)
 * Copyright (c) 2009-2012 Carnegie Mellon University
 * Copyright (c) 2010-2012 VDG Inc.
 * All Rights Reserved.
 *
 * Developed by: XMHF Team
 *               Carnegie Mellon University / CyLab
 *               VDG Inc.
 *               http://xmhf.org
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 *
 * Neither the names of Carnegie Mellon or VDG Inc, nor the names of
 * its contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * @XMHF_LICENSE_HEADER_END@
 */

// syscalllog hypapp main module
// author: amit vasudevan (amitvasudevan@acm.org)

#include <xmhf.h>
#include <xmhfgeec.h>
#include <xmhf-debug.h>

#include <xc.h>
#include <uapi_gcpustate.h>
//#include <uapi_slabmemacc.h>
#include <uapi_slabmempgtbl.h>

#include <xh_syscalllog.h>




//register a syscall handler code page (at gpa)
void sysclog_register(u32 cpuindex, u32 guest_slab_index, u64 gpa){
        slab_params_t spl;
        //xmhf_hic_uapi_physmem_desc_t *pdesc = (xmhf_hic_uapi_physmem_desc_t *)&spl.in_out_params[2];
        //xmhf_uapi_slabmemacc_params_t *smemaccp = (xmhf_uapi_slabmemacc_params_t *)spl.in_out_params;

        _XDPRINTF_("%s[%u]: starting...\n", __func__, (u16)cpuindex);
        spl.src_slabid = XMHFGEEC_SLAB_XH_SYSCALLLOG;
        //spl.dst_slabid = XMHFGEEC_SLAB_UAPI_SLABMEMACC;
        spl.cpuid = cpuindex;
        //spl.in_out_params[0] = XMHF_HIC_UAPI_PHYSMEM;

        //copy code page at gpa
        //smemaccp->dst_slabid = guest_slab_index;
        //smemaccp->addr_to = &_sl_pagebuffer;
        //smemaccp->addr_from = gpa;
        //smemaccp->numbytes = sizeof(_sl_pagebuffer);
        // spl.dst_uapifn = XMHF_HIC_UAPI_PHYSMEM_PEEK;
        //XMHF_SLAB_CALLNEW(&spl);
	CASM_FUNCCALL(xmhfhw_sysmemaccess_copy, &_sl_pagebuffer,
		gpa, sizeof(_sl_pagebuffer));

        _XDPRINTF_("%s[%u]: grabbed page contents at gpa=%016llx\n",
               __func__, (u16)cpuindex, gpa);

        //compute SHA-1 of the syscall page
        sha1(&_sl_pagebuffer, sizeof(_sl_pagebuffer), _sl_syscalldigest);


        _XDPRINTF_("%s[%u]: computed SHA-1: %*D\n",
               __func__, (u16)cpuindex, SHA_DIGEST_LENGTH, _sl_syscalldigest, " ");

        _sl_registered=true;
}

