require 'spec_helper'

describe "Debugger" do
  class AFileLinker < GDI::Debugger::Files::Base
  end

  class ADebugger < GDI::Debugger
    Commandline = "debug -at "

    display_name "Friendly Name"
    html_elements({:partial => "part"})
    file_linker AFileLinker
    prompt_ready? {|stdout| stdout.end_with? "prompt:" }
    src_extensions /_spec\.rb/
  end

  class BDebugger < GDI::Debugger
  end


  it "should connect the process to the frontend, and allow access to process controller and output controller" do
    oc = mock("GDI::OutputController")
    pc = mock("GDI::ProcessController")
    dbg = GDI::Debugger.new(oc, pc)
    dbg.output.should == oc
    dbg.process.should == pc
  end

  it "should report a human readable name set via :display_name dsl method, or the class name" do
    ADebugger.display_name.should == "Friendly Name"
    BDebugger.display_name.should == BDebugger.name
  end

  it "should allow defining the html view via :html_elements" do
    ADebugger.html_elements.should == [:partial => "part"]
  end

  it "should allow setting a file linker implementation via :file_linker" do
    ADebugger.file_linker.should == AFileLinker
  end

  it "should provide a default file linker implementation" do
    BDebugger.file_linker.should == GDI::Debugger::Files::DefaultLinker
  end

  it "should allow prompt recognition via a :prompt_ready? proc" do
    ADebugger.prompt_ready?("prompt:").should == true
    ADebugger.prompt_ready?("text\n").should == false
  end

  it "should keep the breakpoints set for the debugged file type" do
    pending
  end

  it "should add new breakpoints to running instances" do
    pending
  end

  it "should know which extensions to match for src files via :src_extensions" do
    ("some_spec.rb" =~ ADebugger.src_extensions).should_not == nil
    ("nospec.rb" =~ ADebugger.src_extensions).should == nil
  end
end
