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
import DmaDebugRequest::*;
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
   NandSim nandSim <- mkNandSim(nandSimIndicationProxy.ifc);
   NandSimRequestWrapper nandSimRequestWrapper <- mkNandSimRequestWrapper(NandSimRequest,nandSim.request);
   
   // strstr algo
   StrstrIndicationProxy strstrIndicationProxy <- mkStrstrIndicationProxy(AlgoIndication);
   Strstr#(1,64) strstr <- mkStrstr(strstrIndicationProxy.ifc);
   StrstrRequestWrapper strstrRequestWrapper <- mkStrstrRequestWrapper(AlgoRequest,strstr.request);
   
   // backing store sglist
   MMUConfigIndicationProxy backingStoreMMUConfigIndicationProxy <- mkMMUConfigIndicationProxy(BackingStoreMMUConfigIndication);
   MMU#(PhysAddrWidth) backingStoreSGList <- mkMMU(0, True, backingStoreMMUConfigIndicationProxy.ifc);
   MMUConfigRequestWrapper backingStoreMMUConfigRequestWrapper <- mkMMUConfigRequestWrapper(BackingStoreMMUConfigRequest, backingStoreSGList.request);

   // algo sglist
   MMUConfigIndicationProxy algoMMUConfigIndicationProxy <- mkMMUConfigIndicationProxy(AlgoMMUConfigIndication);
   MMU#(PhysAddrWidth) algoSGList <- mkMMU(1, True, algoMMUConfigIndicationProxy.ifc);
   MMUConfigRequestWrapper algoMMUConfigRequestWrapper <- mkMMUConfigRequestWrapper(AlgoMMUConfigRequest, algoSGList.request);
   
   // nandsim sglist
   MMUConfigIndicationProxy nandsimMMUConfigIndicationProxy <- mkMMUConfigIndicationProxy(NandsimMMUConfigIndication);
   MMU#(PhysAddrWidth) nandsimSGList <- mkMMU(0, False, nandsimMMUConfigIndicationProxy.ifc);
   MMUConfigRequestWrapper nandsimMMUConfigRequestWrapper <- mkMMUConfigRequestWrapper(NandsimMMUConfigRequest, nandsimSGList.request);
   
   // host memory dma server
   DmaDebugIndicationProxy hostDmaDebugIndicationProxy <- mkDmaDebugIndicationProxy(HostDmaDebugIndication);
   let rcs = cons(strstr.config_read_client,cons(nandSim.readClient, nil));
   MemServer#(PhysAddrWidth,64,1) hostDma <- mkMemServerRW(hostMMUConfigIndicationProxy.ifc, hostDmaDebugIndicationProxy.ifc, rcs, cons(nandSim.writeClient, nil), cons(backingStoreSGList,cons(algoSGList,nil)));
   DmaDebugRequestWrapper hostDmaDebugRequestWrapper <- mkDmaDebugRequestWrapper(HostDmaDebugRequest, hostDma.request);

   // nandsim memory dma server
   DmaDebugIndicationProxy nandsimDmaDebugIndicationProxy <- mkDmaDebugIndicationProxy(NandsimDmaDebugIndication);   
   MemServer#(PhysAddrWidth,64,1) nandsimDma <- mkMemServerR(nandsimDmaDebugIndicationProxy.ifc, cons(strstr.haystack_read_client,nil), cons(nandsimSGList,nil));
   DmaDebugRequestWrapper nandsimDmaRequestWrapper <- mkDmaDebugRequestWrapper(NandsimDmaDebugRequest, nandsimDma.request);
   mkConnection(nandsimDma.masters[0], nandSim.memSlave);
   
   Vector#(14,StdPortal) portals;

   portals[0] = nandSimRequestWrapper.portalIfc;
   portals[1] = nandSimIndicationProxy.portalIfc; 

   portals[2] = strstrRequestWrapper.portalIfc;
   portals[3] = strstrIndicationProxy.portalIfc; 
   
   portals[4] = backingStoreMMUConfigRequestWrapper.portalIfc;
   portals[5] = backingStoreMMUConfigIndicationProxy.portalIfc;

   portals[6] = nandsimMMUConfigRequestWrapper.portalIfc;
   portals[7] = nandsimMMUConfigIndicationProxy.portalIfc;
   
   portals[8] = hostDmaDebugRequestWrapper.portalIfc;
   portals[9] = hostDmaDebugIndicationProxy.portalIfc; 

   portals[10] = nandsimDmaRequestWrapper.portalIfc;
   portals[11] = nandsimDmaDebugIndicationProxy.portalIfc; 
   
   portals[12] = algoMMUConfigRequestWrapper.portalIfc;
   portals[13] = algoMMUConfigIndicationProxy.portalIfc;

   let ctrl_mux <- mkSlaveMux(portals);
   
   interface interrupt = getInterruptVector(portals);
   interface slave = ctrl_mux;
   interface masters = hostDma.masters;
   interface leds = default_leds;
      
endmodule : mkConnectalTop
