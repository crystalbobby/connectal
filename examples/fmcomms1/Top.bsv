// Copyright (c) 2014 Quanta Research Cambridge, Inc.

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import Vector::*;
import GetPut::*;
import Connectable :: *;
import Clocks :: *;
import FIFO::*;
import Portal::*;
import HostInterface::*;
import CtrlMux::*;
import Leds::*;
import MemTypes::*;
import MemServer::*;
import MMU::*;
import PS7LIB::*;

// generated by tool
import FMComms1Request::*;
import FMComms1Indication::*;
import MemServerRequest::*;
import MMURequest::*;
import MemServerIndication::*;
import MMUIndication::*;

// defined by user
import XilinxCells::*;
import ConnectalXilinxCells::*;

import FMComms1ADC::*;
import FMComms1DAC::*;
import FMComms1::*;
import extraXilinxCells::*;

typedef enum { FMComms1Request, FMComms1Indication, HostMemServerIndication, HostMemServerRequest, HostMMURequest, HostMMUIndication} IfcNames deriving (Eq,Bits);

interface FMComms1Pins;
   interface FMComms1ADCPins adcpins;
   interface FMComms1DACPins dacpins;
   method Bit#(1) ad9548_ref_p();
   method Bit#(1) ad9548_ref_n();
   
//   (* prefix="" *)
endinterface

/* clk1 is the FCLKCLK1 controlled by software */

module mkConnectalTop#(HostType host)(ConnectalTop#(PhysAddrWidth,64,FMComms1Pins,1));

   Clock clk1 = host.ps7.fclkclk[1];
   C2B ref_clk_as_bit <- mkC2B(clk1);
   Wire#(Bit#(1)) ref_clk_wire <- mkDWire(0);
   
   rule senddown_clk;
      ref_clk_wire <= ref_clk_as_bit.o();
   endrule

   DiffOut ref_clk <- mkxOBUFDS(ref_clk_wire);

   FMComms1ADC adc <- mkFMComms1ADC();
   FMComms1DAC dac <- mkFMComms1DAC();
   
   FMComms1IndicationProxy fmcomms1IndicationProxy <- mkFMComms1IndicationProxy(FMComms1Indication);
   FMComms1 fmcomms1 <- mkFMComms1(fmcomms1IndicationProxy.ifc, dac.dac, adc.adc);
   FMComms1RequestWrapper fmcomms1RequestWrapper <- mkFMComms1RequestWrapper(FMComms1Request, fmcomms1.request);

   Vector#(1,  MemReadClient#(64))   readClients = cons(fmcomms1.readDmaClient, nil);
   Vector#(1, MemWriteClient#(64))  writeClients = cons(fmcomms1.writeDmaClient, nil);
   MMUIndicationProxy hostMMUIndicationProxy <- mkMMUIndicationProxy(HostMMUIndication);
   MMU#(PhysAddrWidth) hostMMU <- mkMMU(0, True, hostMMUIndicationProxy.ifc);
   MMURequestWrapper hostMMURequestWrapper <- mkMMURequestWrapper(HostMMURequest, hostMMU.request);

   MemServerIndicationProxy hostMemServerIndicationProxy <- mkMemServerIndicationProxy(HostMemServerIndication);
   MemServer#(PhysAddrWidth,64,1) dma <- mkMemServerRW(hostMemServerIndicationProxy.ifc, readClients, writeClients, cons(hostMMU,nil));
   MemServerRequestWrapper hostMemServerRequestWrapper <- mkMemServerRequestWrapper(HostMemServerRequest, dma.request);

   Vector#(6,StdPortal) portals;
   portals[0] = fmcomms1RequestWrapper.portalIfc;
   portals[1] = fmcomms1IndicationProxy.portalIfc; 
   portals[2] = hostMemServerRequestWrapper.portalIfc;
   portals[3] = hostMemServerIndicationProxy.portalIfc; 
   portals[4] = hostMMURequestWrapper.portalIfc;
   portals[5] = hostMMUIndicationProxy.portalIfc;
   let ctrl_mux <- mkSlaveMux(portals);
   


   
   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
   interface masters = dma.masters;
   interface leds = default_leds;
   interface FMComms1Pins pins;
      interface FMCOmms1ADCPins adcpins = adc.pins;
      interface FMCOmms1ADCPins dacpins = dac.pins;
      method Bit#(1) ad9548_ref_p();
	 return(ref_clk.read_p());
      endmethod
   
      method Bit#(1) ad9548_ref_n();
	 return(ref_clk.read_n());
      endmethod
   endinterface
endmodule : mkConnectalTop
