describe "Speedbar" do
  class ADebugger < GDI::Debugger
    Commandline = "debug -at "
  end

  it "should pass the commandline, the connection spec and any additional arguments to the process controller" do
    pcc = mock("GDI::ProcessController::Class")
    pc = mock("GDI::ProcessController")
    pcc.should_receive(:new).with({:model => ADebugger,
      :arguments => "4242",
      :connection => "some args"}).and_return(pc)
    pc.should_receive(:run)
    GDI::Speedbar.new(ADebugger).debug("4242", "some args")
  end

  it "should complain if no connection information was provided" do
    pending
  end
end