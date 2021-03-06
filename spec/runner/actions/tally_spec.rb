require File.dirname(__FILE__) + '/../../spec_helper'
require 'mspec/expectations/expectations'
require 'mspec/runner/actions/tally'
require 'mspec/runner/mspec'
require 'mspec/runner/state'

describe Tally do
  before :each do
    @tally = Tally.new
  end

  it "responds to #files! by incrementing the count returned by #files" do
    @tally.files! 3
    @tally.files.should == 3
    @tally.files!
    @tally.files.should == 4
  end

  it "responds to #examples! by incrementing the count returned by #examples" do
    @tally.examples! 2
    @tally.examples.should == 2
    @tally.examples! 2
    @tally.examples.should == 4
  end

  it "responds to #expectations! by incrementing the count returned by #expectations" do
    @tally.expectations!
    @tally.expectations.should == 1
    @tally.expectations! 3
    @tally.expectations.should == 4
  end

  it "responds to #failures! by incrementing the count returned by #failures" do
    @tally.failures! 1
    @tally.failures.should == 1
    @tally.failures!
    @tally.failures.should == 2
  end

  it "responds to #errors! by incrementing the count returned by #errors" do
    @tally.errors!
    @tally.errors.should == 1
    @tally.errors! 2
    @tally.errors.should == 3
  end

  it "responds to #format by returning a formatted string of counts" do
    @tally.files!
    @tally.examples! 2
    @tally.expectations! 4
    @tally.errors!
    @tally.format.should == "1 file, 2 examples, 4 expectations, 0 failures, 1 error"
  end
end

describe TallyAction do
  before :each do
    @tally = TallyAction.new
    @state = SpecState.new("describe", "it")
    @state.exceptions << ["msg", Exception.new("it broke")]
    @state.exceptions << ["msg", ExpectationNotMetError.new("disappointment")]
  end

  it "responds to #counter by returning the Tally object" do
    @tally.counter.should be_kind_of(Tally)
  end

  it "responds to #load by incrementing the count returned by Tally#files" do
    @tally.load
    @tally.counter.files.should == 1
  end

  it "responds to #expectation by incrementing the count returned by Tally#expectations" do
    @tally.expectation @state
    @tally.counter.expectations.should == 1
  end

  it "responds to #after by incrementing counts returned by Tally#examples, #failures, #errors" do
    @tally.after @state
    @tally.counter.examples.should == 1
    @tally.counter.expectations.should == 0
    @tally.counter.failures.should == 1
    @tally.counter.errors.should == 1
  end

  it "responds to #format by returning a readable string of counts" do
    @tally.load
    @tally.after @state
    @tally.expectation @state
    @tally.expectation @state
    @tally.format.should == "1 file, 1 example, 2 expectations, 1 failure, 1 error"
  end

  it "responds to #register by registering itself with MSpec for appropriate actions" do
    MSpec.should_receive(:register).with(:load, @tally)
    MSpec.should_receive(:register).with(:after, @tally)
    MSpec.should_receive(:register).with(:expectation, @tally)
    @tally.register
  end

  it "responds to #unregister by unregistering itself with MSpec for appropriate actions" do
    MSpec.should_receive(:unregister).with(:load, @tally)
    MSpec.should_receive(:unregister).with(:after, @tally)
    MSpec.should_receive(:unregister).with(:expectation, @tally)
    @tally.unregister
  end
end
