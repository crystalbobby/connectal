// bsv libraries
import SpecialFIFOs::*;
import Vector::*;
import StmtFSM::*;
import FIFO::*;

// portz libraries
import AxiClientServer::*;
import Directory::*;
import CtrlMux::*;
import Portal::*;
import PortalMemory::*;
import PortalRMemory::*;
import AxiRDMA::*;

// generated by tool
import RingIndicationProxy::*;
import RingRequestWrapper::*;
import DMARequestWrapper::*;
import DMAIndicationProxy::*;

// defined by user
import Ring::*;

typedef enum {RingIndication, RingRequest, DmaRequest, DmaIndication} IfcNames deriving (Eq,Bits);

module mkPortalTop(StdPortalTop#(addrWidth));
   
   // instantiate DMA infrastructure
   DMAIndicationProxy dmaIndicationProxy <- mkDMAIndicationProxy(DMAIndication);
   DMAReadBuffer#(64,8) dma_read_chan <- mkDMAReadBuffer();
   DMAWriteBuffer#(64,8) dma_write_chan <- mkDMAWriteBuffer();
   DMAReadBuffer#(64,8) cmd_read_chan <- mkDMAReadBuffer();
   DMAWriteBuffer#(64,8) cmd_write_chan <- mkDMAWriteBuffer();
   
   Vector#(2, DMAReadClient#(64)) readClients = newVector();
   readClients[0] = dma_read_chan.dmaClient;
   readClients[1] = cmd_read_chan.dmaClient;

   Vector#(2, DMAWriteClient#(64)) writeClients = newVector();
   writeClients[0] = dma_write_chan.dmaClient;
   writeClients[1] = cmd_write_chan.dmaClient;

   DMAIndicationProxy dmaIndicationProxy <- mkDMAIndicationProxy(DMAIndication);
   Integer numRequests = 8;   
   AxiDMA#(Bit#(64))   dma <- mkAxiDMA(dmaIndication.ifc, numRequests, readClients, writeClients);
   DMARequestWrapper dmaRequestWrapper <- mkDMARequestWrapper(DMARequest,dma.request);
   
   // instantiate user portals
   RingIndicationProxy ringIndicationProxy <- mkRingIndicationProxy(RingIndication);
   RingRequest ringRequest <- mkRingRequestInternal(ringIndicationProxy.ifc, dma_read_chan, dma_write_chan, cmd_read_chan, cmd_write_chan);
   RingRequestWrapper ringRequestWrapper <- mkRingRequestWrapper(RingRequest, ringRequest);
   
   Vector#(4,StdPortal) portals;
   portals[0] = ringIndicationProxy.portalIfc;
   portals[1] = ringRequestWrapper.portalIfc; 
   portals[2] = dmaIndicationProxy.portalIfc;
   portals[3] = dmaRequestWrapper.portalIfc; 

   let interrupt_mux <- mkInterruptMux(portals);
   
   // instantiate system directory
   Directory dir <- mkDirectoryDbg(portals,interrupt_mux);
   Vector#(1,StdPortal) directories;
   directories[0] = dir.portalIfc;
   
   // when constructing the ctrl mux, directories must be the first argument
   let ctrl_mux <- mkAxiSlaveMux(directories,portals);
   interface ReadOnly interrupt = interrupt_mux;
   interface StdAxi3Slave ctrl = ctrl_mux;
   interface Vector m_axi = replicate(dma.m_axi);
   interface LEDS leds = ?;
endmodule : mkPortalTop
