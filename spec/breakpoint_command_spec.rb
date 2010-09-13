describe "BreakpointCommand" do
  it "should set a breakpoint if executed" do
    @bps = []
    dbg = mock("GDI::Debugger::Class")
    dbg.should_receive(:breakpoints).and_return(@bps)
    breakpoint = {:file => "file", :line => 1}
    GDI::BreakpointCommand.new.set_breakpoint(dbg, breakpoint)
    @bps.include?(breakpoint).should == true
  end
end
