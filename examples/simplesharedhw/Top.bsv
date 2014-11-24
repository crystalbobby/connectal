/* Copyright (c) 2014 Quanta Research Cambridge, Inc
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
import Vector::*;
import FIFO::*;
import Connectable::*;
import CtrlMux::*;
import Portal::*;
import HostInterface::*;
import Leds::*;
import MMU::*;
import MemServer::*;
import MemPortal::*;
import SharedMemoryPortal::*;

// generated by tool
import Simple::*;
import MMURequest::*;
import MMUIndication::*;
import MMUIndication::*;
import SharedMemoryPortalConfig::*;
import MemServerIndication::*;

// defined by user
import SimpleIF::*;

typedef enum {SimpleIndication, SimpleRequest,
	      MMURequest, MMUIndication, MemServerIndication, ReqConfigWrapper, IndConfigWrapper} IfcNames deriving (Eq,Bits);

module mkConnectalTop(StdConnectalDmaTop#(PhysAddrWidth));

   // instantiate user portals
   SimpleProxyPortal simpleIndicationProxy <- mkSimpleProxyPortal(SimpleIndication);
   Simple simpleRequest <- mkSimple(simpleIndicationProxy.ifc);
   SimpleWrapperPortal simpleRequestWrapper <- mkSimpleWrapperPortal(SimpleRequest,simpleRequest);
   
   SharedMemoryPortal#(64) echoRequestSharedMemoryPortal <- mkSharedMemoryPortal(simpleRequestWrapper.portalIfc);
   SharedMemoryPortalConfigWrapper reqConfigWrapper <- mkSharedMemoryPortalConfigWrapper(ReqConfigWrapper, echoRequestSharedMemoryPortal.cfg);

   SharedMemoryPortal#(64) echoIndicationSharedMemoryPortal <- mkSharedMemoryPortal(simpleIndicationProxy.portalIfc);
   SharedMemoryPortalConfigWrapper indConfigWrapper <- mkSharedMemoryPortalConfigWrapper(IndConfigWrapper, echoIndicationSharedMemoryPortal.cfg);

   let readClients = cons(echoRequestSharedMemoryPortal.readClient,
			  cons(echoIndicationSharedMemoryPortal.readClient, nil));
   let writeClients = cons(echoRequestSharedMemoryPortal.writeClient,
			   cons(echoIndicationSharedMemoryPortal.writeClient, nil));

   MemServerIndicationProxy memServerIndicationProxy <- mkMemServerIndicationProxy(MemServerIndication);
   MMUIndicationProxy mmuIndicationProxy <- mkMMUIndicationProxy(MMUIndication);
   MMU#(PhysAddrWidth) mmu <- mkMMU(0, True, mmuIndicationProxy.ifc);
   MMURequestWrapper mmuRequestWrapper <- mkMMURequestWrapper(MMURequest, mmu.request);
   MemServer#(PhysAddrWidth,64,1) dma <- mkMemServerRW(memServerIndicationProxy.ifc, readClients, writeClients, cons(mmu,nil));

   Vector#(5,StdPortal) portals;
   portals[0] = mmuRequestWrapper.portalIfc;
   portals[1] = mmuIndicationProxy.portalIfc;
   portals[2] = reqConfigWrapper.portalIfc;
   portals[3] = indConfigWrapper.portalIfc;
   portals[4] = memServerIndicationProxy.portalIfc;
   let ctrl_mux <- mkSlaveMux(portals);
   
   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
   interface masters = dma.masters;
   interface leds = default_leds;

endmodule : mkConnectalTop


