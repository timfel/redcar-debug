require 'spec_helper'

describe "Debugger" do
  it "should connect the process to the frontend, and allow access to process controller and output controller" do
    oc = mock("GDI::OutputController")
    pc = mock("GDI::ProcessController")
    dbg = GDI::Debugger.new(oc, pc)
    dbg.output.should == oc
    dbg.process.should == pc
  end
end
