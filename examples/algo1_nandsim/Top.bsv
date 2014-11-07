// bsv libraries
import SpecialFIFOs::*;
import Vector::*;
import StmtFSM::*;
import FIFO::*;
import BRAM::*;
import DefaultValue::*;
import Connectable::*;

// portz libraries
import Leds::*;
import CtrlMux::*;
import Portal::*;
import ConnectalMemory::*;
import MemTypes::*;
import MemServer::*;
import MemServerInternal::*;
import MMU::*;


// generated by tool
import NandSimRequest::*;
import MMUConfigRequest::*;
import StrstrRequest::*;

import NandSimIndication::*;
import DmaDebugIndication::*;
import MMUConfigIndication::*;
import StrstrIndication::*;

// defined by user
import NandSim::*;
import NandSimNames::*;
import Strstr::*;

module mkConnectalTop(StdConnectalDmaTop#(PhysAddrWidth));
   
   // nandsim 
   NandSimIndicationProxy nandSimIndicationProxy <- mkNandSimIndicationProxy(NandSimIndication);
   NandSim#(1) nandSim <- mkNandSim(nandSimIndicationProxy.ifc);
   NandSimRequestWrapper nandSimRequestWrapper <- mkNandSimRequestWrapper(NandSimRequest,nandSim.request);
   
   // strstr algo
   StrstrIndicationProxy strstrIndicationProxy <- mkStrstrIndicationProxy(AlgoIndication);
   Strstr#(64) strstr <- mkStrstr(strstrIndicationProxy.ifc);
   StrstrRequestWrapper strstrRequestWrapper <- mkStrstrRequestWrapper(AlgoRequest,strstr.request);
   
   // backing store mmu
   MMUConfigIndicationProxy backingStoreMMUConfigIndicationProxy <- mkMMUConfigIndicationProxy(BackingStoreMMUConfigIndication);
   MMU#(PhysAddrWidth) backingStoreMMU <- mkMMU(0, True, backingStoreMMUConfigIndicationProxy.ifc);
   MMUConfigRequestWrapper backingStoreMMUConfigRequestWrapper <- mkMMUConfigRequestWrapper(BackingStoreMMUConfigRequest, backingStoreMMU.request);

   // algo mmu
   MMUConfigIndicationProxy algoMMUConfigIndicationProxy <- mkMMUConfigIndicationProxy(AlgoMMUConfigIndication);
   MMU#(PhysAddrWidth) algoMMU <- mkMMU(1, True, algoMMUConfigIndicationProxy.ifc);
   MMUConfigRequestWrapper algoMMUConfigRequestWrapper <- mkMMUConfigRequestWrapper(AlgoMMUConfigRequest, algoMMU.request);
   
   // nandsim mmu
   MMUConfigIndicationProxy nandsimMMUConfigIndicationProxy <- mkMMUConfigIndicationProxy(NandsimMMU0ConfigIndication);
   MMU#(PhysAddrWidth) nandsimMMU <- mkMMU(0, False, nandsimMMUConfigIndicationProxy.ifc);
   MMUConfigRequestWrapper nandsimMMUConfigRequestWrapper <- mkMMUConfigRequestWrapper(NandsimMMU0ConfigRequest, nandsimMMU.request);
   
   // host memory dma server
   DmaDebugIndicationProxy hostDmaDebugIndicationProxy <- mkDmaDebugIndicationProxy(HostDmaDebugIndication);
   let rcs = cons(strstr.config_read_client,cons(nandSim.readClient, nil));
   MemServer#(PhysAddrWidth,64,1) hostDma <- mkMemServerRW(backingStoreMMUConfigIndicationProxy.ifc, hostDmaDebugIndicationProxy.ifc, 
							   rcs, cons(nandSim.writeClient, nil), cons(backingStoreMMU,cons(algoMMU,nil)));

   // nandsim memory dma server
   DmaDebugIndicationProxy nandsimDmaDebugIndicationProxy <- mkDmaDebugIndicationProxy(NandsimDma0DebugIndication);   
   MemServer#(PhysAddrWidth,64,1) nandsimDma <- mkMemServerR(nandsimMMUConfigIndicationProxy.ifc, nandsimDmaDebugIndicationProxy.ifc, 
							     cons(strstr.haystack_read_clients[0],nil), cons(nandsimMMU,nil));
   mkConnection(nandsimDma.masters[0], nandSim.memSlaves[0]);
   
   Vector#(10,StdPortal) portals;

   portals[0] = nandSimRequestWrapper.portalIfc;
   portals[1] = nandSimIndicationProxy.portalIfc; 

   portals[2] = strstrRequestWrapper.portalIfc;
   portals[3] = strstrIndicationProxy.portalIfc; 
   
   portals[4] = backingStoreMMUConfigRequestWrapper.portalIfc;
   portals[5] = backingStoreMMUConfigIndicationProxy.portalIfc;

   portals[6] = nandsimMMUConfigRequestWrapper.portalIfc;
   portals[7] = nandsimMMUConfigIndicationProxy.portalIfc;
   
   portals[8] = algoMMUConfigRequestWrapper.portalIfc;
   portals[9] = algoMMUConfigIndicationProxy.portalIfc;
   
   let ctrl_mux <- mkSlaveMux(portals);
   
   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
   interface masters = hostDma.masters;
   interface leds = default_leds;
      
endmodule : mkConnectalTop
