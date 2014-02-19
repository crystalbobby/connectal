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

import Clocks :: *;
import Vector            :: *;
import Connectable       :: *;
import Portal            :: *;
import Leds              :: *;
import Top               :: *;
import AxiMasterSlave    :: *;
import XbsvXilinxCells   :: *;
import PS7LIB::*;
import XADC::*;

(* always_ready, always_enabled *)
interface ZynqTop#(type pins);
   (* prefix="" *)
   interface ZynqPins zynq;
   (* prefix="GPIO" *)
   interface LEDS             leds;
   (* prefix="XADC" *)
   interface XADC             xadc;
   interface pins             pins;
   interface Clock unused_clock;
   interface Reset unused_reset;
endinterface

typedef (function Module#(PortalTop#(32, 64, ipins)) mkpt()) MkPortalTop#(type ipins);

module [Module] mkZynqTopFromPortal#(MkPortalTop#(ipins) constructor)(ZynqTop#(ipins));
   B2C mainclock <- mkB2C();
   PS7 ps7 <- mkPS7(mainclock.c, mainclock.r, clocked_by mainclock.c, reset_by mainclock.r);
   let top <- constructor(clocked_by mainclock.c, reset_by mainclock.r);
   Reg#(Bit#(1)) bozoReg <- mkReg(0, clocked_by mainclock.c, reset_by mainclock.r);
   Reg#(Bit#(1)) intReg <- mkReg(0, clocked_by mainclock.c, reset_by mainclock.r);

   mkConnection(ps7.m_axi_gp[0].client, top.ctrl);
   mkConnection(top.m_axi, ps7.s_axi_hp[0].axi.server);
   rule send_int_rule;
       ps7.interrupt(top.interrupt ? 1'b1 : 1'b0);
   endrule
   rule bozorule;
       bozoReg <= bozoReg + 1;
       intReg <= top.interrupt ? 1'b1 : 1'b0;
   endrule

   rule b2c_rule;
       mainclock.inputclock(ps7.fclkclk()[0]);
       mainclock.inputreset(ps7.fclkresetn()[0]);
   endrule

   interface zynq = ps7.pins;
   interface leds = top.leds;
   interface XADC xadc;
       method Bit#(4) gpio;
           return {intReg, ps7.debugif[3], ps7.debugif[2], ps7.debugif[1]};
       endmethod
   endinterface
   interface pins = top.pins;
   interface unused_clock = mainclock.c;
   interface unused_reset = mainclock.r;
endmodule

module mkZynqTop(ZynqTop#(Empty));
   let top <- mkZynqTopFromPortal(mkPortalTop);
   return top;
endmodule
