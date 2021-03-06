require 'spec_helper'

describe Collector::Handler::Router do
  let(:historian) { FakeHistorian.new }
  let(:timestamp) { 123456789 }
  let(:handler) { Collector::Handler::LoggregatorRouter.new(historian, "job") }
  let(:context) { Collector::HandlerContext.new(1, timestamp, varz) }

  describe "process" do
    let(:varz) do
      {
          "name" => "LoggregatorTrafficcontroller",
          "numCPUS" => 1,
          "numGoRoutines" => 1,
          "tags" => {
              "ip" => "10.10.10.10"
          },
          "memoryStats" => {
            "numBytesAllocatedHeap" => 1024,
            "numBytesAllocatedStack" => 4096,
            "numBytesAllocated" => 2048,
            "numMallocs" => 3,
            "numFrees" => 10,
            "lastGCPauseTimeNS" => 1000
          },
          "contexts" => [
              {"name" => "agentListener",
               "metrics" => [
                   {"name" => "currentBufferCount", "value" => 12},
                   {"name" => "receivedMessageCount", "value" => 45},
                   {"name" => "receivedByteCount", "value" => 6}]},
              {"name" => "sinkServer",
               "metrics" => [
                   {"name" => "numberOfSinks", "value" => 9, "tags" => {"tag1" => "tagValue1", "tag2" => "tagValue2"}}
               ]
              }
          ]
      }
    end


    it "sends the metrics" do
      handler.process(context)
      historian.should have_sent_data("LoggregatorTrafficcontroller.numCpus", 1)
      historian.should have_sent_data("LoggregatorTrafficcontroller.numGoRoutines", 1)
      historian.should have_sent_data("LoggregatorTrafficcontroller.memoryStats.numBytesAllocatedHeap", 1024)
      historian.should have_sent_data("LoggregatorTrafficcontroller.memoryStats.numBytesAllocatedStack", 4096)
      historian.should have_sent_data("LoggregatorTrafficcontroller.memoryStats.numBytesAllocated", 2048)
      historian.should have_sent_data("LoggregatorTrafficcontroller.memoryStats.numMallocs", 3)
      historian.should have_sent_data("LoggregatorTrafficcontroller.memoryStats.numFrees", 10)
      historian.should have_sent_data("LoggregatorTrafficcontroller.memoryStats.lastGCPauseTimeNS", 1000)
      historian.should have_sent_data("LoggregatorTrafficcontroller.agentListener.currentBufferCount", 12)
      historian.should have_sent_data("LoggregatorTrafficcontroller.agentListener.receivedMessageCount", 45)
      historian.should have_sent_data("LoggregatorTrafficcontroller.agentListener.receivedByteCount", 6)
      historian.should have_sent_data("LoggregatorTrafficcontroller.sinkServer.numberOfSinks", 9, {ip: "10.10.10.10", tag1: "tagValue1", tag2: "tagValue2"})
    end
  end
end
