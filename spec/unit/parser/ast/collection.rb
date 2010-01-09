#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../../spec_helper'

describe Puppet::Parser::AST::Collection do
    before :each do
        @scope = stub_everything 'scope'
        @compiler = stub_everything 'compile'
        @scope.stubs(:compiler).returns(@compiler)

        @overrides = stub_everything 'overrides'
        @overrides.stubs(:is_a?).with(Puppet::Parser::AST).returns(true)

    end

    it "should evaluate its query" do
        query = mock 'query'
        collection = Puppet::Parser::AST::Collection.new :query => query, :form => :virtual, :scope => @scope
        query.expects(:safeevaluate)
        collection.evaluate
    end

    it "should instantiate a Collector for this type" do
        collection = Puppet::Parser::AST::Collection.new :form => :virtual, :type => "test", :scope => @scope

        Puppet::Parser::Collector.expects(:new).with(@scope, "test", nil, nil, :virtual)

        collection.evaluate
    end

    it "should tell the compiler about this collector" do
        collection = Puppet::Parser::AST::Collection.new :form => :virtual, :type => "test", :scope => @scope
        Puppet::Parser::Collector.stubs(:new).returns("whatever")

        @compiler.expects(:add_collection).with("whatever")

        collection.evaluate
    end

    it "should evaluate overriden paramaters" do
        collector = stub_everything 'collector'
        collection = Puppet::Parser::AST::Collection.new :form => :virtual, :type => "test", :override => @overrides, :scope => @scope
        Puppet::Parser::Collector.stubs(:new).returns(collector)

        @overrides.expects(:safeevaluate)

        collection.evaluate
    end

    it "should tell the collector about overrides" do
        collector = mock 'collector'
        collection = Puppet::Parser::AST::Collection.new :form => :virtual, :type => "test", :override => @overrides, :scope => @scope
        Puppet::Parser::Collector.stubs(:new).returns(collector)

        collector.expects(:add_override)

        collection.evaluate
    end


end