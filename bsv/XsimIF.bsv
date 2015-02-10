// Copyright (c) 2015 Quanta Research Cambridge, Inc.

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

typedef enum { XsimMemSlaveRequest, XsimMemSlaveIndication } XsimIfcNames;

interface XsimMemSlaveRequest;
   method Action connect();
   method Action enableint(Bit#(32) fpgaId, Bit#(1) val);
   method Action read(Bit#(32) fpgaId, Bit#(32) addr);
   method Action write(Bit#(32) fpgaId, Bit#(32) addr, Bit#(32) data);
   // for bluenoc top
   method Action msgSink(Bit#(32) data);
endinterface
interface XsimMemSlaveIndication;
   method Action directory(Bit#(32) fpgaNumber, Bit#(32) fpgaId, Bit#(1) last);
   method Action readData(Bit#(32) data);
   method Action interrupt(Bit#(4) intrNum);
   // for bluenoc top
   method Action msgSource(Bit#(32) data);
endinterface