#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../../spec_helper'

describe Puppet::Parser::AST::Minus do
    before :each do
        @scope = Puppet::Parser::Scope.new()
    end

    it "should evaluate its argument" do
        value = stub "value"
        value.expects(:safeevaluate).returns(123)

        operator = Puppet::Parser::AST::Minus.new :value => value
        operator.evaluate
    end

    it "should fail if argument is not a string or integer" do
        array_ast = stub 'array_ast', :safeevaluate => [2]
        operator = Puppet::Parser::AST::Minus.new :value => array_ast
        lambda { operator.evaluate }.should raise_error
    end

    it "should work with integer as string" do
        string = stub 'string', :safeevaluate => "123"
        operator = Puppet::Parser::AST::Minus.new :value => string
        operator.evaluate.should == -123
    end

    it "should work with integers" do
        int = stub 'int', :safeevaluate => 123
        operator = Puppet::Parser::AST::Minus.new :value => int
        operator.evaluate.should == -123
    end

end