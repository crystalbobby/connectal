// Copyright (c) 2013 Quanta Research Cambridge, Inc.

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

import DDS::*;
import FixedPoint::*;
import Complex::*;
import Pipe::*;
import DDSTestInterfaces::*;

module mkDDSTestRequest#(DDSTestIndication indication) (DDSTestRequest);
   DDS dds <- mkDDS();

   method Action setCoeff(Bit#(11) addr, Bit#(32) valueRe, Bit#(32) valueIm);
    FixedPoint#(2, 23) re = unpack(pack(truncate(valueRe)));
    FixedPoint#(2, 23) im = unpack(pack(truncate(valueIm)));
      cs.setCoeff(addr, Complex{rel: re, img:im});
      indication.setConfigResp();
   endmethod

   method Action setPhaseAdvance(Bit#(32) i, Bit#(32) f);
    dds.setPhaseAdvance(PhaseType{i: truncate(i), f: truncate(f)});
      indication.setConfigResp();
   endmethod
   
   method Action getData();
      PhaseType p = dds.getPhase();
      DDSOutType d = dds.osc.first();
      indication.ddsData(zeroExtend(p.i), zeroExtend(pack(d.re)), zeroExtend(pack(d.im)));
   endmethod
endmodule


