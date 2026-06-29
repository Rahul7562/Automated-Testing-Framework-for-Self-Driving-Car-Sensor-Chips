import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from pyuvm import *
import random
import sys
import os

# Append model to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'model'))
from ekf_reference import EKFReferenceModel

class SensorItem(uvm_sequence_item):
    def __init__(self, name, data=0):
        super().__init__(name)
        self.data = data

class SensorSeq(uvm_sequence):
    async def body(self):
        # We need to run 100,000 test scenarios
        for _ in range(100_000):
            item = SensorItem("item", random.randint(0, 0xFFFFFFFFFFFFFFFF))
            await self.start_item(item)
            await self.finish_item(item)

class SensorDriver(uvm_driver):
    async def run_phase(self):
        self.dut.s_axis_tvalid.value = 0
        while True:
            item = await self.seq_item_port.get_next_item()
            await RisingEdge(self.dut.aclk)
            self.dut.s_axis_tdata.value = item.data
            self.dut.s_axis_tvalid.value = 1
            await RisingEdge(self.dut.aclk)
            while not self.dut.s_axis_tready.value:
                await RisingEdge(self.dut.aclk)
            self.dut.s_axis_tvalid.value = 0
            self.seq_item_port.item_done()

class SensorMonitor(uvm_monitor):
    def __init__(self, name, parent, method_name):
        super().__init__(name, parent)
        self.method_name = method_name

    def build_phase(self):
        self.ap = uvm_analysis_port("ap", self)

    async def run_phase(self):
        while True:
            await RisingEdge(self.dut.aclk)
            if self.method_name == 'input':
                if self.dut.s_axis_tvalid.value == 1 and self.dut.s_axis_tready.value == 1:
                    self.ap.write(int(self.dut.s_axis_tdata.value))
            elif self.method_name == 'output':
                if self.dut.m_axis_tvalid.value == 1:
                    self.ap.write(int(self.dut.m_axis_tdata.value))

class SensorScoreboard(uvm_component):
    def build_phase(self):
        self.in_export = uvm_analysis_export("in_export", self)
        self.out_export = uvm_analysis_export("out_export", self)
        self.in_fifo = uvm_tlm_analysis_fifo("in_fifo", self)
        self.out_fifo = uvm_tlm_analysis_fifo("out_fifo", self)
        self.model = EKFReferenceModel()
        self.passed = True
        self.count = 0

    def connect_phase(self):
        pass

    async def run_phase(self):
        while True:
            in_data = await self.in_fifo.get()
            out_data = await self.out_fifo.get()
            expected = self.model.step(in_data)

            if expected != out_data:
                self.logger.error(f"Mismatch! In: {hex(in_data)}, Exp: {hex(expected)}, Got: {hex(out_data)}")
                self.passed = False
            self.count += 1
            if self.count % 10000 == 0:
                self.logger.info(f"Processed {self.count} transactions...")

    def check_phase(self):
        self.logger.info(f"Total transactions verified: {self.count}")
        if not self.passed or self.count < 100_000:
            self.logger.error("TEST FAILED")
            assert False, "Scoreboard mismatch or insufficient transaction count"
        else:
            self.logger.info("TEST PASSED")

class SensorEnv(uvm_env):
    def build_phase(self):
        self.drv = SensorDriver("drv", self)
        self.sqr = uvm_sequencer("sqr", self)
        self.mon_in = SensorMonitor("mon_in", self, 'input')
        self.mon_out = SensorMonitor("mon_out", self, 'output')
        self.scb = SensorScoreboard("scb", self)

    def connect_phase(self):
        self.drv.seq_item_port.connect(self.sqr.seq_item_export)
        self.mon_in.ap.connect(self.scb.in_fifo.analysis_export)
        self.mon_out.ap.connect(self.scb.out_fifo.analysis_export)

class SensorTest(uvm_test):
    def build_phase(self):
        self.env = SensorEnv("env", self)

    def end_of_elaboration_phase(self):
        self.env.drv.dut = cocotb.top
        self.env.mon_in.dut = cocotb.top
        self.env.mon_out.dut = cocotb.top

    async def run_phase(self):
        self.raise_objection()
        seq = SensorSeq("seq")
        await seq.start(self.env.sqr)

        # Drain pipeline
        for _ in range(15):
            await RisingEdge(cocotb.top.aclk)

        self.drop_objection()

@cocotb.test()
async def ekf_test(dut):
    clock = Clock(dut.aclk, 10, units="ns")
    cocotb.start_soon(clock.start())

    dut.aresetn.value = 0
    await Timer(20, units="ns")
    dut.aresetn.value = 1
    await Timer(20, units="ns")

    await uvm_root().run_test("SensorTest")
