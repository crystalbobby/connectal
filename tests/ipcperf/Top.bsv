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
import Portal::*;
import CtrlMux::*;
import MemTypes::*;
import HostInterface::*;
import IpcTestIndication::*;
import IpcTestRequest::*;
import IpcTest::*;

typedef enum {IfcNames_IpcTestIndication, IfcNames_IpcTestRequest} IfcNames deriving (Eq,Bits);

module mkConnectalTop#(HostInterface host)(ConnectalTop#(PhysAddrWidth,64,Empty,0));
   IpcTestIndicationProxy echoIndicationProxy <- mkIpcTestIndicationProxy(IfcNames_IpcTestIndication);
   IpcTestRequestInternal echoRequestInternal <- mkIpcTestRequestInternal(echoIndicationProxy.ifc);
   IpcTestRequestWrapper echoRequestWrapper <- mkIpcTestRequestWrapper(IfcNames_IpcTestRequest,echoRequestInternal.ifc);
   
   Vector#(2,StdPortal) portals;
   portals[0] = echoRequestWrapper.portalIfc; 
   portals[1] = echoIndicationProxy.portalIfc;
   let ctrl_mux <- mkSlaveMux(portals);
   
   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
endmodule : mkConnectalTop
