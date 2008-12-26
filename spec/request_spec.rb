require File.dirname(__FILE__) + '/spec_helper'

require 'request_log_analyzer/file_format'
require 'request_log_analyzer/request'


describe RequestLogAnalyzer::Request, :single_line do
  
  before(:each) do
    @single_line_request = RequestLogAnalyzer::Request.new(TestFileFormat)
    @single_line_request << { :line_type => :test_line, :lineno => 1, :test_capture => 'awesome!' }
  end
  
  it "should be single if only one line has been added" do
    @single_line_request.should be_single_line
    @single_line_request.should_not be_empty
    @single_line_request.should_not be_combined    
  end
  
  it "should not be a completed request" do
    @single_line_request.should_not be_completed
  end  
  
  it "should take the line type of the first line as global line_type" do
    @single_line_request.line_type.should == :test_line
    @single_line_request.should =~ :test_line    
  end
  
  it "should return the correct field value" do
    @single_line_request[:test_capture].should == 'awesome!'
  end
  
  it "should return nil if no such field is present" do
    @single_line_request[:nonexisting].should be_nil
  end
end  


describe RequestLogAnalyzer::Request, :combined do
  
  before(:each) do
    @combined_request = RequestLogAnalyzer::Request.new(TestFileFormat)
    @combined_request << { :line_type => :first_line, :lineno =>  1, :name => 'first line!' }    
    @combined_request << { :line_type => :test_line,  :lineno =>  4, :test_capture => 'testing' }        
    @combined_request << { :line_type => :test_line,  :lineno =>  7, :test_capture => 'testing some more' }            
    @combined_request << { :line_type => :last_line,  :lineno => 10, :time => 0.03 }
  end
  
  it "should be a combined request when more lines are added" do
    @combined_request.should be_combined
    @combined_request.should_not be_single_line
    @combined_request.should_not be_empty
  end
  
  it "should be a completed request" do
    @combined_request.should be_completed
  end
  
  it "should recognize all line types" do
    [:first_line, :test_line, :last_line].each { |type| @combined_request.should =~ type }
  end
  
  it "should detect the correct field value" do
    @combined_request[:name].should == 'first line!'
    @combined_request[:time].should == 0.03
  end
  
  it "should detect the first correct field value" do  
    @combined_request[:test_capture].should == 'testing'
  end
end