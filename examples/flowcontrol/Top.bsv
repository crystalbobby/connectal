// bsv libraries
import Vector::*;
import FIFO::*;
import Connectable::*;

// portz libraries
import Portal::*;
import Directory::*;
import CtrlMux::*;
import Portal::*;
import Leds::*;


// generated by tool
import SinkIndicationProxy::*;
import SinkRequestWrapper::*;

// defined by user
import Sink::*;

typedef enum {SinkIndication, SinkRequest} IfcNames deriving (Eq,Bits);

module mkPortalTop(StdPortalTop#(addrWidth));

   // instantiate user portals
   SinkIndicationProxy sinkIndicationProxy <- mkSinkIndicationProxy(SinkIndication);
   SinkRequest sinkRequest <- mkSinkRequest(sinkIndicationProxy.ifc);
   SinkRequestWrapper sinkRequestWrapper <- mkSinkRequestWrapper(SinkRequest,sinkRequest);
   
   Vector#(2,StdPortal) portals;
   portals[0] = sinkIndicationProxy.portalIfc;
   portals[1] = sinkRequestWrapper.portalIfc; 
   let interrupt_mux <- mkInterruptMux(portals);
   
   // instantiate system directory
   Directory dir <- mkDirectoryDbg(portals,interrupt_mux);
   Vector#(1,StdPortal) directories;
   directories[0] = dir.portalIfc;
   
   // when constructing the ctrl mux, directories must be the first argument
   let ctrl_mux <- mkAxiSlaveMux(directories,portals);
   
   interface ReadOnly interrupt = interrupt_mux;
   interface StdAxi3Slave ctrl = ctrl_mux;
   interface LEDS leds = ?;
   interface Axi3Client m_axi = ?;

endmodule : mkPortalTop
