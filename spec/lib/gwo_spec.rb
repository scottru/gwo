require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/gwo'

describe GWO do
  include GWO::Helper

  describe "google analytics stuff" do
    it "should create correct google analytics stuff for default urls"
    it "should create correct google analytics stuff for static urls"
    it "should create correct google analytics stuff for several sections"
    it "should not create google analytics stuff if option is disabled"
  end

  describe "gwo_start method" do
    it "should produce correct output" do
      gwo_start("gwo_id", "section_name").should =~ /utmx section name='section_name'/
      gwo_start("gwo_id", "section_name").should =~ /utmx\(\"variation_content\", \"section_name\"\)/
      gwo_start("gwo_id", "section_name").should =~ /utmx\(\"variation_number\", \"section_name\"\)/
      gwo_start("gwo_id", "section_name").should =~ /k='gwo_id'/
    end

    it "should work with just the id parameter set" do
      gwo_start("gwo_id").should =~ /k='gwo_id'/
      gwo_start("gwo_id").should =~ /utmx section name='gwo_section'/
      gwo_start("gwo_id").should =~ /utmx\(\"variation_content\", \"gwo_section\"\)/
      gwo_start("gwo_id").should =~ /utmx\(\"variation_number\", \"gwo_section\"\)/
      gwo_start("gwo_id", nil).should =~ /utmx section name='gwo_section'/
    end

    it "should work with one single section ... section is a symbol" do
      gwo_start("gwo_id", :section_name).should =~ /utmx section name='section_name'/
      gwo_start("gwo_id", :section_name).should =~ /utmx\(\"variation_content\", \"section_name\"\)/
      gwo_start("gwo_id", :section_name).should =~ /utmx\(\"variation_number\", \"section_name\"\)/
      gwo_start("gwo_id", :section_name).should =~ /k='gwo_id'/
    end

    it "should work with an array of section" do
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='body'/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='content'/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx section name='footer'/

      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_content\", \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_content\", \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_content\", \"footer\"\)/

      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_number\", \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_number\", \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"]).should =~ /utmx\(\"variation_number\", \"footer\"\)/
    end

    it "should return nothing when ignore is set to true" do
      gwo_start("id", [], true).should == "" 
      gwo_start("gwo_id", ["body",:content,"footer"], true).should == ""

      gwo_start("gwo_id", ["body",:content,"footer"], true).should_not =~ /utmx\(\"variation_content\", \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], true).should_not =~ /utmx\(\"variation_content\", \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], true).should_not =~ /utmx\(\"variation_content\", \"footer\"\)/
      
      gwo_start("gwo_id", ["body",:content,"footer"], true).should_not =~ /utmx\(\"variation_number\",  \"body\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], true).should_not =~ /utmx\(\"variation_number\",  \"content\"\)/
      gwo_start("gwo_id", ["body",:content,"footer"], true).should_not =~ /utmx\(\"variation_number\",  \"footer\"\)/
    end
  end

  describe "gwo_end method" do
    it "should produce correct output" do
      gwo_end("gwo_id", "gwo_uacct").should =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_end("gwo_id", "gwo_uacct").should =~ /trackPageview\(\"\/gwo_id\/test\"\)/
    end

    it "should return nothing if ignore is set to true" do
      gwo_end("gwo_id", "gwo_uacct", true).should_not =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_end("gwo_id", "gwo_uacct", true).should == ""
    end
  end

  describe "gw_conversion method" do
    it "should produce correct output" do
      gwo_conversion("gwo_id", "gwo_uacct").should =~ /getTracker\(\"gwo_uacct\"\)/
      gwo_conversion("gwo_id", "gwo_uacct").should =~ /trackPageview\(\"\/gwo_id\/goal\"\)/
    end

    it "should return nothing when ignore is set to true" do
      gwo_conversion("gwo_id", "gwo_uacct", true).should == ""
    end
  end

  describe "gwo_section method" do
      
    it "should return nothing when ignore is set to true and the variation is not the original" do
      gwo_section("gwo_section", ["foo","bar"], true).should == ""
    end

    it "should return original output without javascript if ignore is true and original is the variation " do
      gwo_section("gwo_section", :original, true) { "this is the content" }.should == "this is the content"
    end

    it "should return original output with javascript if ignore is unset and original is the variation " do
      gwo_section("gwo_section", :original) { "this is the content" }.should =~ /this is the content/
      gwo_section("gwo_section", :original) { "this is the content" }.should =~ /( GWO_gwo_section_name != \"original\" )/
    end

    it "should only write one javascript block if the section is used for original and variations" do
      gwo_section("section", [:original, :variation1, :variation2]) { "this is the content" }.should     =~ /this is the content/
      gwo_section("section", [:original, :variation1, :variation2]) { "this is the content" }.should     =~ /( GWO_section_name != \"original\" && GWO_section_name != \"variation1\" && GWO_section_name != \"variation2\" )/
    end

    it "should write block for one variant" do
      gwo_section("section",:testing) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",:testing) { "this is the content" }.should_not =~ /utmx\(\"variation_content\", \"section\"\)/
      gwo_section("section",:testing) { "this is the content" }.should     =~ /( GWO_section_name == \"testing\" )/
    end

    it "should write one block but enabled for all given variants " do
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should     =~ /this is the content/ 
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should_not =~ /utmx\(\"variation_content\", \"section\"\)/
      gwo_section("section",[:testing, :still_testing]) { "this is the content" }.should     =~ /( GWO_section_name == \"testing\" || GWO_section_name == \"still_testing\" )/
    end
  end
  
end
