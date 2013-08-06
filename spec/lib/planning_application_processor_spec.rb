require 'spec_helper'

describe PlanningApplicationsProcessor do
  let(:config) do
    {host: "mail.example.com", user_name: "user@example.com", password: "secret",
      authentication: "PLAIN", mailbox: "INBOX", mail_processor: "MailProcessor"}
  end

  describe "fetching zipfile" do
    # This should have some kind of whizz-bang test to ensure
    # that the file is streamed to disk, rather than being read
    # into memory.
    it "should stream to disk" do
      pending
    end
  end

  describe "unzipping the file" do
    it "should work" do
      pending
    end
  end

  describe "processing dummy csv" do

    # Here's a hint that this might need refactoring
    before do
      f = Tempfile.new('foo').path
      subject.instance_variable_set(:@csv_path, f)
      $stderr.stub(:write)
    end

    it "should turn off logging" do
      ActiveRecord::Base.should_receive(:logger=)
      subject.process_csv
    end

    it "should have a progressbar" do
      ProgressBar.should_receive(:new).and_call_original
      subject.process_csv
    end
  end

  describe "processing example csv" do
    before do
      subject.instance_variable_set(:@csv_path, planning_applications_path)
      ProgressBar.stub(:new).and_return(double("pbar", :inc => nil, :finish => nil))
    end

    it "should add new records" do
      subject.process_csv
      PlanningApplication.count.should eql(2)
      plan = PlanningApplication.find_by_openlylocal_id(261)
      plan.should_not be_nil
      plan.postcode.should eql("SW12 0AH")
    end

    it "should update old records with new information"
  end
end
